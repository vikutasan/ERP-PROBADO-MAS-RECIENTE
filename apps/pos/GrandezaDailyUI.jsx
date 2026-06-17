import React, { useState, useEffect, useMemo } from 'react';
import { securityService } from './services/securityService';

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
    const [driverId, setDriverId] = useState('');
    const [saving, setSaving] = useState(false);
    const [toast, setToast] = useState(null);
    const [viewDate, setViewDate] = useState(todayStr());   // Fecha que se está viendo
    const [historyJourneys, setHistoryJourneys] = useState([]); // Para historial rápido
    const [confirmModal, setConfirmModal] = useState(null); // Modal custom
    const [drivers, setDrivers] = useState([]);
    const [pinInput, setPinInput] = useState('');

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
                setDriverId(j.driver_user_id || '');

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
                setDriverId('');
            }
            
            // 4. Cargar repartidores para el select
            try {
                const emps = await securityService.listEmployees();
                const reps = emps.filter(e => e.role && (e.role.includes('REPARTIDOR') || e.role.includes('DRIVER')));
                setDrivers(reps);
            } catch (e) { console.error("Error loading drivers", e); }
            
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

    const weekNumber = useMemo(() => {
        const d = new Date(viewDate + 'T12:00:00');
        d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay()||7));
        const yearStart = new Date(Date.UTC(d.getUTCFullYear(),0,1));
        return Math.ceil(( ( (d - yearStart) / 86400000) + 1)/7);
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
                    driver_user_id: driverId ? parseInt(driverId) : null,
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

    const handleDespacharRequest = () => {
        if (!journey) return;
        if (totalPiezas === 0) {
            showToast('⚠️ No puedes despachar sin inventario', 'error');
            return;
        }
        if (!driverId) {
            showToast('⚠️ Selecciona un repartidor primero', 'error');
            return;
        }
        setPinInput('');
        setConfirmModal(`¿Despachar ruta con ${totalPiezas} piezas y fondo de caja $${parseFloat(cashFund) || 0}?`);
    };

    const confirmDespachar = async () => {
        if (!pinInput) {
            showToast('⚠️ Ingresa el PIN del repartidor', 'error');
            return;
        }
        setSaving(true);
        try {
            // Validar PIN del repartidor
            const validation = await securityService.validatePin(pinInput);
            const selectedDriver = drivers.find(d => d.id === parseInt(driverId));
            if (validation.id !== parseInt(driverId)) {
                showToast(`❌ El PIN no pertenece a ${selectedDriver?.name || 'este repartidor'}`, 'error');
                setSaving(false);
                return;
            }

            // Primero guardar el inventario por si hay cambios de último momento
            await handleSaveInventory();

            // Cambiar estado a EN_RUTA
            await fetch(`${API_BASE}/grandeza/journeys/${journey.id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: 'EN_RUTA' })
            });

            showToast('🚗 ¡Ruta despachada! El repartidor puede iniciar');
            setConfirmModal(null);
            await loadData();
        } catch (err) {
            showToast(`❌ PIN incorrecto o error: ${err.message}`, 'error');
        } finally {
            setSaving(false);
        }
    };

    // ─── Renderizado ─────────────────────────────────────────────────────────

    const statusLabel = (status) => {
        const map = {
            'PREPARANDO': { text: 'Preparando', color: 'bg-amber-500/20 text-amber-400 border-amber-500/30' },
            'EN_RUTA': { text: 'En Ruta', color: 'bg-blue-500/20 text-blue-400 border-blue-500/30' },
            'CERRADA': { text: 'Cerrada', color: 'bg-orange-500/20 text-orange-400 border-orange-500/30' },
        };
        const s = map[status] || { text: status, color: 'bg-gray-500/20 text-white border-gray-500/30' };
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
                    <div className="w-24 h-24 rounded-3xl overflow-hidden shadow-2xl shadow-orange-500/20 border-2 border-orange-500/30 flex items-center justify-center shrink-0">
                        <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                    </div>
                    <div>
                        <h1 className="text-4xl font-black uppercase tracking-tighter text-white leading-none">
                            Gestión <span className="text-orange-400">Diaria</span>
                        </h1>
                        <p className="text-sm font-bold uppercase tracking-widest mt-1 text-white">
                            Reparto Pan Grandeza
                        </p>
                    </div>
                </div>

                    <div className="flex items-center gap-4">
                        {/* Selector de Fecha */}
                        <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-2xl px-4 py-2">
                            <span className="text-xs font-black text-white uppercase">Fecha:</span>
                            <input
                                type="date"
                                value={viewDate}
                                onChange={(e) => setViewDate(e.target.value)}
                                className="bg-transparent text-white font-bold outline-none text-sm"
                            />
                            {!isToday && (
                                <button
                                    onClick={() => setViewDate(todayStr())}
                                    className="ml-2 px-3 py-1 bg-orange-500/20 text-orange-400 rounded-lg text-xs font-bold hover:bg-orange-500/30 transition-all"
                                >
                                    Hoy
                                </button>
                            )}
                        </div>

                        <button
                            onClick={onBack}
                            className="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-white hover:text-white hover:bg-white/10 transition-all"
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
                            <p className="text-white font-bold uppercase tracking-widest text-sm animate-pulse">Cargando jornada...</p>
                        </div>
                    </div>
                ) : !journey ? (
                    /* ─── No hay jornada: Crear nueva ─── */
                    <div className="max-w-xl mx-auto">
                        <div className="bg-black/70 backdrop-blur-md border-2 border-dashed border-white/10 rounded-[32px] p-12 text-center space-y-6">
                            <div className="text-6xl">📋</div>
                            <h2 className="text-2xl font-black uppercase tracking-tighter">
                                {dayName} — {viewDate}
                            </h2>
                            <p className="text-white font-medium">
                                No hay jornada registrada para esta fecha.
                                {isToday ? ' Crea una para comenzar el reparto de hoy.' : ''}
                            </p>

                            {isToday && (
                                <button
                                    onClick={handleCreateJourney}
                                    disabled={saving}
                                    className="mt-4 px-10 py-4 bg-gradient-to-r from-orange-500 to-orange-600 rounded-2xl text-lg font-black uppercase tracking-widest text-white shadow-2xl shadow-orange-500/30 hover:scale-105 active:scale-95 transition-all disabled:opacity-50"
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
                                <div className="w-12 h-12 rounded-xl overflow-hidden shadow-lg border border-orange-500/30 flex items-center justify-center shrink-0">
                                    <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                                </div>
                                <div>
                                    <h2 className="text-xl font-black uppercase tracking-tighter text-white">
                                        {dayName} — <span className="text-orange-400">{viewDate}</span>
                                    </h2>
                                    <p className="text-xs text-white font-bold uppercase tracking-widest mt-1">
                                        Semana #{weekNumber}
                                    </p>
                                </div>
                            </div>
                            {statusLabel(journey.status)}
                        </div>

                        {/* ─── Panel de Inventario Inicial ─── */}
                        <div className="bg-black/70 backdrop-blur-md border border-white/10 rounded-[24px] overflow-hidden">
                            <div className="p-6 border-b border-white/5 flex items-center justify-between">
                                <div>
                                    <h3 className="text-lg font-black uppercase tracking-tighter text-white flex items-center gap-2">
                                        <span>📦</span> Inventario Inicial
                                    </h3>
                                    <p className="text-xs text-white font-bold uppercase tracking-widest mt-1">
                                        Piezas frescas que sube el repartidor a la camioneta
                                    </p>
                                </div>
                                <div className="flex items-center gap-3">
                                    <div className="bg-orange-500/10 border border-orange-500/20 rounded-2xl px-5 py-2 text-center">
                                        <div className="text-2xl font-black text-orange-400">{totalPiezas}</div>
                                        <div className="text-[9px] font-black text-orange-500/60 uppercase tracking-widest">Piezas Total</div>
                                    </div>
                                </div>
                            </div>

                            <div className="p-6">
                                {grandezaProducts.length === 0 ? (
                                    <p className="text-white text-center py-8 font-bold">No hay productos habilitados para Grandeza</p>
                                ) : (
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        {grandezaProducts.map(gp => (
                                            <div key={gp.product_id} className="flex items-center justify-between bg-black/70 backdrop-blur-md border border-white/5 rounded-2xl p-4 hover:border-orange-500/30 transition-all">
                                                <div className="flex-1 min-w-0">
                                                    <div className="font-bold text-white text-sm truncate">
                                                        {gp.product_name || `Producto #${gp.product_id}`}
                                                    </div>
                                                    <div className="text-xs text-white mt-0.5">
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
                                                        className="w-16 bg-black/90 border border-white/10 rounded-xl text-center text-lg font-black text-white outline-none focus:border-orange-500 transition-all"
                                                        disabled={journey.status !== 'PREPARANDO'}
                                                    />
                                                    <button
                                                        onClick={() => setInvQty(gp.product_id, getInvQty(gp.product_id) + 1)}
                                                        className="w-8 h-8 rounded-lg bg-white/5 border border-white/10 text-white font-bold hover:bg-orange-500/20 hover:border-orange-500/30 transition-all flex items-center justify-center"
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
                            <div className="bg-black/70 backdrop-blur-md border border-white/10 rounded-[24px] p-6">
                                <h3 className="text-sm font-black uppercase tracking-widest text-white flex items-center gap-2 mb-4">
                                    <span>💰</span> Fondo de Caja
                                </h3>
                                <p className="text-xs text-white mb-3">Dinero que se le entrega al repartidor para dar cambio.</p>
                                <div className="flex items-center gap-2">
                                    <span className="text-2xl text-orange-500 font-black">$</span>
                                    <input
                                        type="number"
                                        value={cashFund}
                                        onChange={(e) => setCashFund(e.target.value)}
                                        placeholder="0.00"
                                        className="flex-1 bg-black/90 border border-white/10 rounded-2xl p-4 text-2xl font-black text-white outline-none focus:border-orange-500 transition-all"
                                        disabled={journey.status !== 'PREPARANDO'}
                                    />
                                </div>
                            </div>

                            <div className="bg-black/70 backdrop-blur-md border border-white/10 rounded-[24px] p-6">
                                <h3 className="text-sm font-black uppercase tracking-widest text-white flex items-center gap-2 mb-4">
                                    <span>🧑‍✈️</span> Repartidor Asignado
                                </h3>
                                <p className="text-xs text-white mb-3">Nombre del repartidor que llevará la ruta hoy.</p>
                                <select
                                    value={driverId}
                                    onChange={(e) => setDriverId(e.target.value)}
                                    className="w-full bg-black/90 border border-white/10 rounded-2xl p-4 text-lg font-bold text-white outline-none focus:border-orange-500 transition-all appearance-none cursor-pointer"
                                    disabled={journey.status !== 'PREPARANDO'}
                                >
                                    <option value="" disabled>Selecciona un repartidor</option>
                                    {drivers.map(d => (
                                        <option key={d.id} value={d.id}>{d.name}</option>
                                    ))}
                                </select>
                            </div>
                        </div>

                        {/* ─── Acciones ─── */}
                        {journey.status === 'PREPARANDO' && (
                            <div className="flex gap-4">
                                <button
                                    onClick={handleDespacharRequest}
                                    disabled={saving || totalPiezas === 0}
                                    className="flex-1 py-4 bg-gradient-to-r from-orange-500 to-orange-600 rounded-2xl text-sm font-black uppercase tracking-widest text-white shadow-2xl shadow-orange-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-80 disabled:grayscale disabled:hover:scale-100 disabled:cursor-not-allowed"
                                >
                                    {saving ? 'Procesando...' : '🚗 Despachar Ruta'}
                                </button>
                            </div>
                        )}

                        {journey.status === 'EN_RUTA' && (
                            <CierreJornada journey={journey} API_BASE={API_BASE} showToast={showToast} onReload={loadData} cashFund={cashFund} totalPiezas={totalPiezas} />
                        )}

                        {journey.status === 'CERRADA' && (
                            <div className="bg-orange-500/5 border border-orange-500/20 rounded-[24px] p-6 text-center space-y-3">
                                <div className="text-3xl">✅</div>
                                <h3 className="text-lg font-black uppercase tracking-tighter text-orange-400">
                                    Jornada Cerrada
                                </h3>
                                <div className="grid grid-cols-3 gap-4 mt-4 max-w-lg mx-auto">
                                    <div className="bg-black/70 backdrop-blur-md p-3 rounded-xl">
                                        <div className="text-lg font-black text-white">${(journey.cash_expected || 0).toFixed(2)}</div>
                                        <div className="text-[9px] font-black text-white uppercase">Esperado</div>
                                    </div>
                                    <div className="bg-black/70 backdrop-blur-md p-3 rounded-xl">
                                        <div className="text-lg font-black text-white">${(journey.cash_received || 0).toFixed(2)}</div>
                                        <div className="text-[9px] font-black text-white uppercase">Recibido</div>
                                    </div>
                                    <div className="bg-black/70 backdrop-blur-md p-3 rounded-xl">
                                        <div className={`text-lg font-black ${(journey.cash_received || 0) >= (journey.cash_expected || 0) ? 'text-orange-400' : 'text-orange-700'}`}>
                                            ${((journey.cash_received || 0) - (journey.cash_expected || 0)).toFixed(2)}
                                        </div>
                                        <div className="text-[9px] font-black text-white uppercase">Diferencia</div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                )}
            </div>

            {/* Custom Modal */}
            {confirmModal && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
                    <div className="bg-[#2a2216] border border-white/10 rounded-3xl p-8 max-w-md w-full shadow-2xl animate-in zoom-in-95 duration-200">
                        <div className="text-4xl mb-4 text-center">🚗</div>
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white text-center mb-6">Confirmar Despacho</h3>
                        <p className="text-white text-center mb-4 font-medium">{confirmModal}</p>

                        {inventory.some(i => i.fresh_qty > 0) && (
                            <div className="mb-6 bg-black/40 rounded-xl p-4 max-h-40 overflow-y-auto custom-scrollbar border border-white/5 space-y-2">
                                {inventory.filter(i => i.fresh_qty > 0).map(item => {
                                    const prod = grandezaProducts.find(p => p.product_id === item.product_id);
                                    return (
                                        <div key={item.product_id} className="flex justify-between items-center text-sm font-bold border-b border-white/5 pb-2 last:border-0 last:pb-0">
                                            <span className="text-gray-300">{prod ? prod.product_name : `Producto #${item.product_id}`}</span>
                                            <span className="text-orange-400 bg-orange-500/10 px-2 py-0.5 rounded-md">{item.fresh_qty} pz</span>
                                        </div>
                                    );
                                })}
                            </div>
                        )}

                        <div className="mb-6">
                            <label className="text-[10px] font-black uppercase tracking-widest text-orange-400 block text-center mb-2">
                                Firma del Repartidor ({drivers.find(d => d.id === parseInt(driverId))?.name || 'Desconocido'})
                            </label>
                            <div className="bg-black/50 border border-white/10 rounded-2xl h-14 flex items-center justify-center text-2xl font-mono tracking-[0.5em] text-white mb-4">
                                {pinInput.replace(/./g, '•') || <span className="text-white/20">PIN</span>}
                            </div>
                            <div className="grid grid-cols-3 gap-2">
                                {[1, 2, 3, 4, 5, 6, 7, 8, 9, 'C', 0, '←'].map(val => (
                                    <button
                                        key={val}
                                        onClick={() => {
                                            if (val === 'C') setPinInput('');
                                            else if (val === '←') setPinInput(prev => prev.slice(0, -1));
                                            else if (pinInput.length < 8) setPinInput(prev => String(prev) + val);
                                        }}
                                        className="h-12 bg-white/5 border border-white/10 rounded-xl text-lg font-black text-white hover:bg-white/10 active:scale-95 transition-all"
                                    >
                                        {val}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div className="flex gap-4">
                            <button
                                onClick={() => setConfirmModal(null)}
                                className="flex-1 py-3 bg-white/5 border border-white/10 rounded-xl font-bold text-white hover:bg-white/10 transition-all"
                            >
                                CANCELAR
                            </button>
                            <button
                                onClick={confirmDespachar}
                                disabled={saving || !pinInput}
                                className="flex-1 py-3 bg-gradient-to-r from-orange-500 to-orange-600 rounded-xl font-black uppercase tracking-widest text-white hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50 disabled:grayscale"
                            >
                                {saving ? 'VERIFICANDO...' : 'FIRMAR Y DESPACHAR'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Toast */}
            {toast && (
                <div className={`fixed bottom-8 right-8 px-6 py-4 rounded-2xl font-black text-sm shadow-2xl z-50 transition-all animate-in slide-in-from-right duration-300
                    ${toast.type === 'error' ? 'bg-red-500 text-white' : 'bg-orange-500 text-black'}`}>
                    {toast.msg}
                </div>
            )}

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 4px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #1a1a1a; border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #f97316; }
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
    const [showConfirmModal, setShowConfirmModal] = useState(false);

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

    const handleCerrarRequest = () => setShowConfirmModal(true);

    const handleCerrar = async () => {
        setShowConfirmModal(false);
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
                        <div>
                            <h3 className="text-xl font-black uppercase tracking-tighter text-white">Ruta en <span className="text-blue-400">Curso</span></h3>
                            {journey.dispatched_at && (
                                <p className="text-[10px] font-bold uppercase tracking-widest text-blue-400 mt-1">
                                    🕒 Salida: {new Date(journey.dispatched_at + 'Z').toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', hour12: true })}
                                </p>
                            )}
                        </div>
                    </div>
                    <span className="text-xs font-bold text-white">{visits.length} visitas registradas</span>
                </div>
                <div className="grid grid-cols-3 gap-3">
                    <div className="bg-black/70 backdrop-blur-md rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-orange-400">${totalVentas.toFixed(0)}</div>
                        <div className="text-[8px] font-black text-white uppercase">Venta Total</div>
                    </div>
                    <div className="bg-black/70 backdrop-blur-md rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-amber-400">${cashExpected.toFixed(0)}</div>
                        <div className="text-[8px] font-black text-white uppercase">Efectivo Esperado</div>
                    </div>
                    <div className="bg-black/70 backdrop-blur-md rounded-xl p-3 text-center">
                        <div className="text-lg font-black text-blue-400">{freshLeftoverExpected}</div>
                        <div className="text-[8px] font-black text-white uppercase">Frescas Sobrantes</div>
                    </div>
                </div>
            </div>

            {/* Formulario de cierre */}
            <div className="bg-black/70 backdrop-blur-md border border-amber-500/20 rounded-[24px] p-6 space-y-4">
                <h3 className="text-sm font-black uppercase tracking-widest text-amber-400 flex items-center gap-2">
                    <span>🔒</span> Cierre de Jornada
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label className="text-[10px] font-black text-white uppercase block mb-1">💰 Efectivo Recibido</label>
                        <input type="number" value={cashReceived} onChange={e => setCashReceived(e.target.value)} placeholder={cashExpected.toFixed(2)}
                            className="w-full bg-black/90 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                    <div>
                        <label className="text-[10px] font-black text-white uppercase block mb-1">🔄 Piezas Cambio Recibidas</label>
                        <input type="number" value={exchangePiecesReceived} onChange={e => setExchangePiecesReceived(e.target.value)} placeholder={String(totalExchangePieces)}
                            className="w-full bg-black/90 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                    <div>
                        <label className="text-[10px] font-black text-white uppercase block mb-1">🍞 Frescas Sobrantes Recibidas</label>
                        <input type="number" value={freshLeftoverReceived} onChange={e => setFreshLeftoverReceived(e.target.value)} placeholder={String(freshLeftoverExpected)}
                            className="w-full bg-black/90 border border-white/10 rounded-xl p-3 text-lg font-black text-white outline-none focus:border-amber-500" />
                    </div>
                </div>
                <div>
                    <label className="text-[10px] font-black text-white uppercase block mb-1">📝 Notas de Retroalimentación</label>
                    <textarea value={feedbackNotes} onChange={e => setFeedbackNotes(e.target.value)} placeholder="Observaciones del gerente..." className="w-full bg-black/90 border border-white/10 rounded-xl p-3 text-sm text-white outline-none focus:border-amber-500 min-h-[60px] resize-none" />
                </div>
                <button onClick={handleCerrarRequest} disabled={saving}
                    className="w-full py-4 bg-gradient-to-r from-amber-500 to-orange-600 rounded-2xl text-sm font-black uppercase tracking-widest text-white shadow-2xl shadow-amber-500/20 hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50">
                    {saving ? 'Cerrando...' : '🔒 Cerrar Jornada'}
                </button>
            </div>

            {/* Custom Modal for Cierre */}
            {showConfirmModal && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
                    <div className="bg-[#2a2216] border border-white/10 rounded-3xl p-8 max-w-md w-full shadow-2xl animate-in zoom-in-95 duration-200">
                        <div className="text-4xl mb-4 text-center">🔒</div>
                        <h3 className="text-xl font-black uppercase tracking-tighter text-amber-400 text-center mb-6">Confirmar Cierre</h3>
                        <p className="text-white text-center mb-8 font-medium">¿Cerrar la jornada? Esta acción no se puede deshacer.</p>
                        <div className="flex gap-4">
                            <button
                                onClick={() => setShowConfirmModal(false)}
                                className="flex-1 py-3 bg-white/5 border border-white/10 rounded-xl font-bold text-white hover:bg-white/10 transition-all"
                            >
                                CANCELAR
                            </button>
                            <button
                                onClick={handleCerrar}
                                className="flex-1 py-3 bg-gradient-to-r from-amber-500 to-orange-600 rounded-xl font-black uppercase tracking-widest text-white hover:scale-[1.02] active:scale-[0.98] transition-all"
                            >
                                CERRAR
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
