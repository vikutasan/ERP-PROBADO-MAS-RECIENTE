import React, { useState, useEffect, useMemo } from 'react';

/**
 * GESTIÓN DIARIA — Reparto Pan Grandeza (Fase 2)
 * 
 * Pantalla para el Gerente:
 * 1. Abrir la jornada del día
 * 2. Registrar inventario inicial (piezas frescas por producto habilitado)
 * 3. Registrar fondo de caja
 * 4. Asignar repartidor (nombre)
 * 5. Despachar la ruta (cambiar estado a EN_RUTA)
 * 
 * También muestra el estado de jornadas anteriores y permite cerrar la jornada del día.
 */
export const GrandezaDailyUI = ({ onBack }) => {
    const API_BASE = `http://${window.location.hostname}:5001/api/v1`;

    // ─── State ───────────────────────────────────────────────────────────────
    const [loading, setLoading] = useState(true);
    const [journey, setJourney] = useState(null);          // Jornada del día
    const [grandezaProducts, setGrandezaProducts] = useState([]);  // Productos habilitados
    const [inventory, setInventory] = useState([]);         // Inventario inicial capturado
    const [cashFund, setCashFund] = useState('');
    const [driverName, setDriverName] = useState('');
    const [saving, setSaving] = useState(false);
    const [toast, setToast] = useState(null);
    const [viewDate, setViewDate] = useState(todayStr());   // Fecha que se está viendo
    const [historyJourneys, setHistoryJourneys] = useState([]); // Para historial rápido

    function todayStr() {
        const d = new Date();
        return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
    }

    const isToday = viewDate === todayStr();

    // ─── Carga inicial ───────────────────────────────────────────────────────
    useEffect(() => {
        loadData();
    }, [viewDate]);

    const loadData = async () => {
        setLoading(true);
        try {
            // 1. Productos habilitados para Grandeza
            const prodRes = await fetch(`${API_BASE}/grandeza/products`);
            if (prodRes.ok) {
                const prods = await prodRes.json();
                setGrandezaProducts(prods.filter(p => p.is_enabled));
            }

            // 2. Jornada de la fecha seleccionada
            const jRes = await fetch(`${API_BASE}/grandeza/journeys/${viewDate}`);
            if (jRes.ok) {
                const j = await jRes.json();
                setJourney(j);
                setCashFund(j.cash_fund || '');
                setDriverName(j.driver_name || '');

                // 3. Si existe jornada, cargar inventario inicial
                const invRes = await fetch(`${API_BASE}/grandeza/journeys/${j.id}/inventory?inventory_type=INITIAL`);
                if (invRes.ok) {
                    const invData = await invRes.json();
                    setInventory(invData);
                } else {
                    setInventory([]);
                }
            } else {
                setJourney(null);
                setInventory([]);
                setCashFund('');
                setDriverName('');
            }
        } catch (err) {
            console.error('Error cargando datos:', err);
        } finally {
            setLoading(false);
        }
    };

    // ─── Helpers ──────────────────────────────────────────────────────────────

    const showToast = (msg, type = 'success') => {
        setToast({ msg, type });
        setTimeout(() => setToast(null), 3000);
    };

    const getInvQty = (productId) => {
        const rec = inventory.find(i => i.product_id === productId);
        return rec ? rec.fresh_qty : 0;
    };

    const setInvQty = (productId, qty) => {
        setInventory(prev => {
            const exists = prev.find(i => i.product_id === productId);
            if (exists) {
                return prev.map(i => i.product_id === productId ? { ...i, fresh_qty: parseInt(qty) || 0 } : i);
            }
            return [...prev, { product_id: productId, fresh_qty: parseInt(qty) || 0, exchange_qty: 0, received_qty: 0 }];
        });
    };

    const totalPiezas = useMemo(() => {
        return inventory.reduce((sum, i) => sum + (i.fresh_qty || 0), 0);
    }, [inventory]);

    const dayName = useMemo(() => {
        const days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
        return days[new Date(viewDate + 'T12:00:00').getDay()];
    }, [viewDate]);

    // ─── Acciones ────────────────────────────────────────────────────────────

    const handleCreateJourney = async () => {
        setSaving(true);
        try {
            const res = await fetch(`${API_BASE}/grandeza/journeys`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    journey_date: viewDate,
                    cash_fund: parseFloat(cashFund) || 0,
                })
            });
            if (res.ok) {
                showToast('✅ Jornada creada exitosamente');
                await loadData();
            } else {
                const err = await res.json();
                showToast(`❌ ${err.detail || 'Error al crear jornada'}`, 'error');
            }
        } catch (err) {
            showToast(`❌ Error de red: ${err.message}`, 'error');
        } finally {
            setSaving(false);
        }
    };

    const handleSaveInventory = async () => {
        if (!journey) return;
        setSaving(true);
        try {
            // Guardar inventario inicial
            const items = grandezaProducts.map(p => ({
                product_id: p.product_id,
                inventory_type: 'INITIAL',
                fresh_qty: getInvQty(p.product_id),
                exchange_qty: 0,
                received_qty: 0,
            }));

            const invRes = await fetch(`${API_BASE}/grandeza/journeys/${journey.id}/inventory/INITIAL`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(items)
            });

            // Guardar fondo de caja y nombre del repartidor
            await fetch(`${API_BASE}/grandeza/journeys/${journey.id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    cash_fund: parseFloat(cashFund) || 0,
                })
            });

            if (invRes.ok) {
                showToast(`✅ Inventario guardado — ${totalPiezas} piezas`);
                await loadData();
            } else {
                showToast('❌ Error al guardar inventario', 'error');
            }
        } catch (err) {
            showToast(`❌ Error: ${err.message}`, 'error');
        } finally {
            setSaving(false);
        }
    };

    const handleDespachar = async () => {
        if (!journey) return;
        if (totalPiezas === 0) {
            showToast('⚠️ No puedes despachar sin inventario', 'error');
            return;
        }
        if (!window.confirm(`¿Despachar ruta con ${totalPiezas} piezas y fondo de caja $${parseFloat(cashFund) || 0}?`)) return;
        
        setSaving(true);
        try {
            // Primero guardar el inventario por si hay cambios de último momento
            await handleSaveInventory();

            // Cambiar estado a EN_RUTA
            await fetch(`${API_BASE}/grandeza/journeys/${journey.id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: 'EN_RUTA' })
            });

            showToast('🚗 ¡Ruta despachada! El repartidor puede iniciar');
            await loadData();
        } catch (err) {
            showToast(`❌ Error: ${err.message}`, 'error');
        } finally {
            setSaving(false);
        }
    };

    // ─── Renderizado ─────────────────────────────────────────────────────────

    const statusLabel = (status) => {
        const map = {
            'PREPARANDO': { text: 'Preparando', color: 'bg-amber-500/20 text-amber-400 border-amber-500/30' },
            'EN_RUTA': { text: 'En Ruta', color: 'bg-blue-500/20 text-blue-400 border-blue-500/30' },
            'CERRADA': { text: 'Cerrada', color: 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30' },
        };
        const s = map[status] || { text: status, color: 'bg-gray-500/20 text-gray-400 border-gray-500/30' };
        return (
            <span className={`px-3 py-1 rounded-full text-xs font-black uppercase tracking-widest border ${s.color}`}>
                {s.text}
            </span>
        );
    };

    return (
        <div className="h-full flex flex-col text-white overflow-hidden relative" style={{ backgroundColor: '#3a2e1e' }}>
            {/* Fondo de madera */}
            <div className="absolute inset-0 z-0 pointer-events-none" style={{
                backgroundImage: 'url("/assets/wood_bg.jpg")',
                backgroundSize: 'cover',
                backgroundPosition: 'center'
            }} />

            {/* Header */}
            <div className="relative z-20 pt-6 px-8 pb-6 bg-black border-b border-white/10 shadow-2xl flex items-center justify-between">
                <div className="flex items-center gap-6">
                    <div className="w-24 h-24 rounded-3xl overflow-hidden shadow-2xl shadow-emerald-500/20 border-2 border-emerald-500/30 flex items-center justify-center shrink-0">
                        <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                    </div>
                    <div>
                        <h1 className="text-4xl font-black uppercase tracking-tighter text-white leading-none">
                            Gestión <span className="text-emerald-400">Diaria</span>
                        </h1>
                        <p className="text-sm font-bold uppercase tracking-widest mt-1 text-gray-400">
                            Reparto Pan Grandeza
                        </p>
                    </div>
                </div>

                    <div className="flex items-center gap-4">
                        {/* Selector de Fecha */}
                        <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-2xl px-4 py-2">
                            <span className="text-xs font-black text-gray-500 uppercase">Fecha:</span>
                            <input
                                type="date"
                                value={viewDate}
                                onChange={(e) => setViewDate(e.target.value)}
                                className="bg-transparent text-white font-bold outline-none text-sm"
                            />
                            {!isToday && (
                                <button
                                    onClick={() => setViewDate(todayStr())}
                                    className="ml-2 px-3 py-1 bg-emerald-500/20 text-emerald-400 rounded-lg text-xs font-bold hover:bg-emerald-500/30 transition-all"
                                >
                                    Hoy
                                </button>
                            )}
                        </div>

                        <button
                            onClick={onBack}
                            className="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-400 hover:text-white hover:bg-white/10 transition-all"
                        >
                            ← Volver
                        </button>
                    </div>
                </div>

            {/* Contenido Principal */}
            <div className="relative z-10 flex-1 overflow-y-auto p-8 pt-4 space-y-6 custom-scrollbar">
                {loading ? (
                    <div className="flex-1 flex items-center justify-center h-64">
                        <div className="text-center space-y-4">
                            <div className="text-4xl animate-pulse">📅</div>
                            <p className="text-gray-500 font-bold uppercase tracking-widest text-sm animate-pulse">Cargando jornada...</p>
                        </div>
                    </div>
                ) : !journey ? (
                    /* ─── No hay jornada: Crear nueva ─── */
                    <div className="max-w-xl mx-auto">
                        <div className="bg-white/[0.02] border-2 border-dashed border-white/10 rounded-[32px] p-12 text-center space-y-6">
                            <div className="text-6xl">📋</div>
                            <h2 className="text-2xl font-black uppercase tracking-tighter">
                                {dayName} — {viewDate}
                            </h2>
                            <p className="text-gray-500 font-medium">
                                No hay jornada registrada para esta fecha.
                                {isToday ? ' Crea una para comenzar el reparto de hoy.' : ''}
                            </p>

                            {isToday && (
                                <button
                                    onClick={handleCreateJourney}
                                    disabled={saving}
                                    className="mt-4 px-10 py-4 bg-gradient-to-r from-emerald-500 to-green-600 rounded-2xl text-lg font-black uppercase tracking-widest text-white shadow-2xl shadow-emerald-500/30 hover:scale-105 active:scale-95 transition-all disabled:opacity-50"
                                >
                                    {saving ? 'Creando...' : '🚀 Abrir Jornada de Hoy'}
                                </button>
                            )}
                        </div>
                    </div>
                ) : (
                    /* ─── Jornada existe ─── */
                    <div className="max-w-4xl mx-auto space-y-6">
                        {/* Banner de Estado */}
                        <div className="flex items-center justify-between bg-black border border-white/10 rounded-[24px] p-6 shadow-xl">
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 rounded-xl overflow-hidden shadow-lg border border-emerald-500/30 flex items-center justify-center shrink-0">
                                    <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                                </div>
                                <div>
                                    <h2 className="text-xl font-black uppercase tracking-tighter text-white">
                                        {dayName} — <span className="text-emerald-400">{viewDate}</span>
                                    </h2>
                                    <p className="text-xs text-gray-500 font-bold uppercase tracking-widest mt-1">
                                        Jornada #{journey.id}
                                    </p>
                                </div>
                            </div>
                            {statusLabel(journey.status)}
                        </div>

                        {/* ─── Panel de Inventario Inicial ─── */}
                        <div className="bg-white/[0.02] border border-white/10 rounded-[24px] overflow-hidden">
                            <div className="p-6 border-b border-white/5 flex items-center justify-between">
                                <div>
                                    <h3 className="text-lg font-black uppercase tracking-tighter text-white flex items-center gap-2">
                                        <span>📦</span> Inventario Inicial
                                    </h3>
                                    <p className="text-xs text-gray-500 font-bold uppercase tracking-widest mt-1">
                                        Piezas frescas que sube el repartidor a la camioneta
                                    </p>
                                </div>
                                <div className="flex items-center gap-3">
                                    <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-2xl px-5 py-2 text-center">
                                        <div className="text-2xl font-black text-emerald-400">{totalPiezas}</div>
                                        <div className="text-[9px] font-black text-emerald-500/60 uppercase tracking-widest">Piezas Total</div>
                                    </div>
                                </div>
                            </div>

                            <div className="p-6">
                                {grandezaProducts.length === 0 ? (
                                    <p className="text-gray-500 text-center py-8 font-bold">No hay productos habilitados para Grandeza</p>
                                ) : (
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        {grandezaProducts.map(gp => (
                                            <div key={gp.product_id} className="flex items-center justify-between bg-black/20 border border-white/5 rounded-2xl p-4 hover:border-emerald-500/30 transition-all">
                                                <div className="flex-1 min-w-0">
                                                    <div className="font-bold text-white text-sm truncate">
                                                        {gp.product_name || `Producto #${gp.product_id}`}
                                                    </div>
                                                    <div className="text-xs text-gray-500 mt-0.5">
                                                        {gp.product_sku || '---'} • B2B: ${gp.b2b_price?.toFixed(2)}
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-2 ml-4">
                                                    <button
                                                        onClick={() => setInvQty(gp.product_id, Math.max(0, getInvQty(gp.product_id) - 1))}
                                                        className="w-8 h-8 rounded-lg bg-white/5 border border-white/10 text-white font-bold hover:bg-red-500/20 hover:border-red-500/30 transition-all flex items-center justify-center"
                                                        disabled={journey.status !== 'PREPARANDO'}
                                                    >−</button>
                                                    <input
                                                        type="number"
                                                        value={getInvQty(gp.product_id)}
                                                        onChange={(e) => setInvQty(gp.product_id, e.target.value)}
                                                        className="w-16 bg-black/40 border border-white/10 rounded-xl text-center text-lg font-black text-white outline-none focus:border-emerald-500 transition-all"
                                                        disabled={journey.status !== 'PREPARANDO'}
                                                    />
                                                    <button
                                                        onClick={() => setInvQty(gp.product_id, getInvQty(gp.product_id) + 1)}
                                                        className="w-8 h-8 rounded-lg bg-white/5 border border-white/10 text-white font-bold hover:bg-emerald-500/20 hover:border-emerald-500/30 transition-all flex items-center justify-center"
                                                        disabled={journey.status !== 'PREPARANDO'}
                                                    >+</button>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>
                        </div>

                        {/* ─── Fondo de Caja ─── */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div className="bg-white/[0.02] border border-white/10 rounded-[24px] p-6">
                                <h3 className="text-sm font-black uppercase tracking-widest text-gray-400 flex items-center gap-2 mb-4">
                                    <span>💰</span> Fondo de Caja
                                </h3>
                                <p className="text-xs text-gray-600 mb-3">Dinero que se le entrega al repartidor para dar cambio.</p>
                                <div className="flex items-center gap-2">
                                    <span className="text-2xl text-emerald-500 font-black">$</span>
                                    <input
                                        type="number"
                                        value={cashFund}
                                        onChange={(e) => setCashFund(e.target.value)}
                                        placeholder="0.00"
                                        className="flex-1 bg-black/40 border border-white/10 rounded-2xl p-4 text-2xl font-black text-white outline-none focus:border-emerald-500 transition-all"
                                        disabled={journey.status !== 'PREPARANDO'}
                                    />
                                </div>
                            </div>

                            <div className="bg-white/[0.02] border border-white/10 rounded-[24px] p-6">
                                <h3 className="text-sm font-black uppercase tracking-widest text-gray-400 flex items-center gap-2 mb-4">
                                    <span>🧑‍✈️</span> Repartidor Asignado
                                </h3>
                                <p className="text-xs text-gray-600 mb-3">Nombre del repartidor que llevará la ruta hoy.</p>
                                <input
                                    type="text"
                                    value={driverName}
                                    onChange={(e) => setDriverName(e.target.value)}
                                    placeholder="Nombre del repartidor"
                                    className="w-full bg-black/40 border border-white/10 rounded-2xl p-4 text-lg font-bold text-white outline-none focus:border-emerald-500 transition-all"
                                    disabled={journey.status !== 'PREPARANDO'}
                                />
                            </div>
                        </div>

                        {/* ─── Acciones ─── */}
                        {journey.status === 'PREPARANDO' && (
                            <div className="flex gap-4">
                                <button
                                    onClick={handleSaveInventory}
                                    disabled={saving}
                                    className="flex-1 py-4 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-300 hover:bg-white/10 hover:text-white transition-all disabled:opacity-50"
                                >
                                    {saving ? 'Guardando...' : '💾 Guardar Inventario'}
                                </button>
                                <button
                                    onClick={handleDespachar}
                                    disabled={saving || totalPiezas === 0}
                                    className="flex-1 py-4 bg-gradient-to-r from-emerald-500 to-green-600 rounded-2xl text-sm font-black uppercase tracking-widest text-white shadow-2xl shadow-emerald-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50 disabled:hover:scale-100"
                                >
                                    {saving ? 'Despachando...' : '🚗 Despachar Ruta'}
                                </button>
                            </div>
                        )}

                        {journey.status === 'EN_RUTA' && (
                            <CierreJornada journey={journey} API_BASE={API_BASE} showToast={showToast} onReload={loadData} cashFund={cashFund} totalPiezas={totalPiezas} />
                        )}

                        {journey.status === 'CERRADA' && (
                            <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-[24px] p-6 text-center space-y-3">
                                <div className="text-3xl">✅</div>
                                <h3 className="text-lg font-black uppercase tracking-tighter text-emerald-400">
                                    Jornada Cerrada
                                </h3>
                                <div className="grid grid-cols-3 gap-4 mt-4 max-w-lg mx-auto">
                                    <div className="bg-black/20 p-3 rounded-xl">
                                        <div className="text-lg font-black text-white">${(journey.cash_expected || 0).toFixed(2)}</div>
                                        <div className="text-[9px] font-black text-gray-500 uppercase">Esperado</div>
                                    </div>
                                    <div className="bg-black/20 p-3 rounded-xl">
                                        <div className="text-lg font-black text-white">${(journey.cash_received || 0).toFixed(2)}</div>
                                        <div className="text-[9px] font-black text-gray-500 uppercase">Recibido</div>
                                    </div>
                                    <div className="bg-black/20 p-3 rounded-xl">
                                        <div className={`text-lg font-black ${(journey.cash_received || 0) >= (journey.cash_expected || 0) ? 'text-emerald-400' : 'text-red-400'}`}>
                                            ${((journey.cash_received || 0) - (journey.cash_expected || 0)).toFixed(2)}
                                        </div>
                                        <div className="text-[9px] font-black text-gray-500 uppercase">Diferencia</div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                )}
            </div>

            {/* Toast */}
            {toast && (
                <div className={`fixed bottom-8 right-8 px-6 py-4 rounded-2xl font-black text-sm shadow-2xl z-50 transition-all animate-in slide-in-from-right duration-300
                    ${toast.type === 'error' ? 'bg-red-500 text-white' : 'bg-emerald-500 text-black'}`}>
                    {toast.msg}
                </div>
            )}

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 4px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #1a1a1a; border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #10b981; }
                input[type="date"]::-webkit-calendar-picker-indicator { filter: invert(1); }
            `}</style>
        </div>
    );
};

// ─── Sub-componente: Cierre de Jornada ───────────────────────────────────────
const CierreJornada = ({ journey, API_BASE, showToast, onReload, cashFund, totalPiezas }) => {
    const [visits, setVisits] = useState([]);
    const [cashReceived, setCashReceived] = useState('');
    const [exchangePiecesReceived, setExchangePiecesReceived] = useState('');
    const [freshLeftoverReceived, setFreshLeftoverReceived] = useState('');
    const [feedbackNotes, setFeedbackNotes] = useState('');
    const [saving, setSaving] = useState(false);
    const [loaded, setLoaded] = useState(false);

    useEffect(() => {
        const load = async () => {
            try {
                const res = await fetch(`${API_BASE}/grandeza/journeys/${journey.id}/visits`);
                if (res.ok) setVisits(await res.json());
            } catch(e) {}
            setLoaded(true);
        };
        load();
    }, [journey.id]);

    // Cálculos esperados
    const totalVentas = visits.reduce((s,v) => s + (v.sale_amount || 0), 0);
    const totalCobrado = visits.reduce((s,v) => s + (v.payment_received || 0), 0);
    const totalCambiosDado = visits.reduce((s,v) => s + (v.change_given || 0), 0);
    const cashExpected = parseFloat(cashFund || 0) + totalCobrado - totalCambiosDado;
    const totalExchangePieces = visits.reduce((s,v) => (v.items||[]).reduce((ss,it) => ss + (it.exchange_qty||0), s), 0);
    const totalFreshSold = visits.reduce((s,v) => (v.items||[]).reduce((ss,it) => ss + (it.actual_fresh_qty||0), s), 0);
    const freshLeftoverExpected = totalPiezas - totalFreshSold;

    const handleCerrar = async () => {
        if (!window.confirm('¿Cerrar la jornada? Esta acción no se puede deshacer.')) return;
        setSaving(true);
        try {
            await fetch(`${API_BASE}/grandeza/journeys/${journey.id}`, {
                method: 'PATCH', headers: {'Content-Type':'application/json'},
                body: JSON.stringify({
                    status: 'CERRADA',
                    cash_expected: cashExpected,
                    cash_received: parseFloat(cashReceived) || 0,
                    exchange_pieces_expected: totalExchangePieces,
                    exchange_pieces_received: parseInt(exchangePiecesReceived) || 0,
                    fresh_leftover_expected: freshLeftoverExpected,
                    fresh_leftover_received: parseInt(freshLeftoverReceived) || 0,
                    feedback_notes: feedbackNotes || null,
                })
            });
            showToast('✅ Jornada cerrada exitosamente');
            onReload();
        } catch(e) { showToast('❌ Error al cerrar', 'error'); }
        finally { setSaving(false); }
    };

    if (!loaded) return <div className="text-center py-8"><div className="text-2xl animate-pulse">⏳</div></div>;

    return (
        <div className="space-y-4">
            {/* Estado en ruta */}
            <div className="bg-black border border-blue-500/20 rounded-[24px] p-6 shadow-xl">
                <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl overflow-hidden shadow-lg border border-blue-500/30 flex items-center justify-center shrink-0">
                            <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                        </div>
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white">Ruta en <span className="text-blue-400">Curso</span></h3>
                    </div>
                    <span className="text-xs font-bold text-gray-500">{visits.length} visitas registradas</span>
                </div>
                <div className="grid grid-cols-3 gap-3">
                    <div className="bg-black/20 rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-emerald-400">${totalVentas.toFixed(0)}</div>
                        <div className="text-[8px] font-black text-gray-500 uppercase">Venta Total</div>
                    </div>
                    <div className="bg-black/20 rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-amber-400">${cashExpected.toFixed(0)}</div>
                        <div className="text-[8px] font-black text-gray-500 uppercase">Efectivo Esperado</div>
                    </div>
                    <div className="bg-black/20 rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-blue-400">{freshLeftoverExpected}</div>
                        <div className="text-[8px] font-black text-gray-500 uppercase">Frescas Sobrantes</div>
                    </div>
                </div>
            </div>

            {/* Formulario de cierre */}
            <div className="bg-white/[0.02] border border-amber-500/20 rounded-[24px] p-6 space-y-4">
                <h3 className="text-sm font-black uppercase tracking-widest text-amber-400 flex items-center gap-2">
                    <span>🔒</span> Cierre de Jornada
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label className="text-[10px] font-black text-gray-500 uppercase block mb-1">💰 Efectivo Recibido</label>
                        <input type="number" value={cashReceived} onChange={e => setCashReceived(e.target.value)} placeholder={cashExpected.toFixed(2)}
                            className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                    <div>
                        <label className="text-[10px] font-black text-gray-500 uppercase block mb-1">🔄 Piezas Cambio Recibidas</label>
                        <input type="number" value={exchangePiecesReceived} onChange={e => setExchangePiecesReceived(e.target.value)} placeholder={String(totalExchangePieces)}
                            className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                    <div>
                        <label className="text-[10px] font-black text-gray-500 uppercase block mb-1">🍞 Frescas Sobrantes Recibidas</label>
                        <input type="number" value={freshLeftoverReceived} onChange={e => setFreshLeftoverReceived(e.target.value)} placeholder={String(freshLeftoverExpected)}
                            className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                </div>
                <div>
                    <label className="text-[10px] font-black text-gray-500 uppercase block mb-1">📝 Notas de Retroalimentación</label>
                    <textarea value={feedbackNotes} onChange={e => setFeedbackNotes(e.target.value)} placeholder="Observaciones del gerente..." className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-sm text-white outline-none focus:border-amber-500 min-h-[60px] resize-none" />
                </div>
                <button onClick={handleCerrar} disabled={saving}
                    className="w-full py-4 bg-gradient-to-r from-amber-500 to-orange-600 rounded-2xl text-sm font-black uppercase tracking-widest text-white shadow-2xl shadow-amber-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50">
                    {saving ? 'Cerrando...' : '🔒 Cerrar Jornada'}
                </button>
            </div>
        </div>
    );
};
