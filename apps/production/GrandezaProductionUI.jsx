import React, { useState, useEffect, useMemo } from 'react';
import { ArrowLeft } from 'lucide-react';
import { CONFIG } from '../pos/config';

/**
 * PRODUCCIÓN GRANDEZA
 * 
 * Suite de estimación de producción basada en:
 * - Ruta del día seleccionado (regular o extraordinaria)
 * - Historial de ventas por cliente (últimas N visitas)
 * - Promedio por producto → redondeado hacia arriba
 */
export const GrandezaProductionUI = ({ onBack }) => {
    const API = CONFIG.API_BASE_URL;
    const LOGO_URL = `${API.replace('/api/v1', '')}/static/images/grandeza/logo.png`;

    // Default: mañana en hora de México
    const getTomorrow = () => {
        const d = new Date();
        d.setDate(d.getDate() + 1);
        return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
    };

    const [targetDate, setTargetDate] = useState(getTomorrow());
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [expandedClient, setExpandedClient] = useState(null);

    const dayName = useMemo(() => {
        const days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
        return days[new Date(targetDate + 'T12:00:00').getDay()];
    }, [targetDate]);

    useEffect(() => {
        const load = async () => {
            setLoading(true);
            try {
                const res = await fetch(`${API}/grandeza/production-estimate/${targetDate}`);
                if (res.ok) setData(await res.json());
                else setData(null);
            } catch(e) { console.error(e); setData(null); }
            finally { setLoading(false); }
        };
        load();
    }, [targetDate]);

    const totalPiezas = data?.totals?.reduce((s, t) => s + t.total_estimated, 0) || 0;

    return (
        <div 
            style={{ 
                backgroundColor: '#b2b2b2',
                backgroundImage: 'radial-gradient(circle at center, #d1d1d1 0%, #b2b2b2 100%)'
            }}
            className="flex-1 flex flex-col h-full animate-in fade-in duration-700 overflow-hidden relative"
        >
            <div className="absolute inset-0 opacity-[0.05] pointer-events-none" />

            <div className="flex-1 flex flex-col h-full bg-black/10 backdrop-blur-md relative z-10 p-8 pt-6">

            {/* Header */}
            <div className="relative z-20 flex items-center justify-between p-6 md:p-8 border-b border-black/10 bg-white/75 backdrop-blur-3xl shadow-sm -mx-8 -mt-8 mb-8">
                <div className="flex items-center gap-4 md:gap-6">
                    <div className="w-14 h-14 md:w-20 md:h-20 rounded-2xl overflow-hidden shadow-2xl shadow-orange-500/20 border-2 border-orange-500/30 flex items-center justify-center shrink-0">
                        <img src={LOGO_URL} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                    </div>
                    <div>
                        <h1 className="text-2xl md:text-4xl font-black italic uppercase tracking-tighter text-black leading-none">
                            PRODUCCIÓN <span className="text-orange-500">GRANDEZA</span>
                        </h1>
                        <p className="text-[9px] md:text-[10px] font-bold text-black/40 uppercase tracking-[0.4em] mt-1">
                            Estimación de piezas • Basado en historial
                        </p>
                    </div>
                </div>
                <button onClick={onBack} className="px-5 py-3 bg-black/5 border border-black/10 rounded-2xl text-sm font-black uppercase tracking-widest text-black/60 hover:bg-black/10 transition-all flex items-center gap-2 shrink-0">
                    <ArrowLeft size={16} /> Volver
                </button>
            </div>

            <div className="flex-1 overflow-auto custom-scrollbar relative z-10 space-y-6">

            {/* Selector de fecha + info */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2 bg-white/80 border border-black/10 rounded-2xl px-4 py-3 shadow-sm">
                        <span className="text-xs font-black text-black/60 uppercase">Fecha de reparto:</span>
                        <input
                            type="date"
                            value={targetDate}
                            onChange={e => setTargetDate(e.target.value)}
                            className="bg-transparent text-black font-bold outline-none text-sm"
                        />
                    </div>
                    <span className="text-sm font-black text-black/40 uppercase">{dayName}</span>
                </div>

                {data && (
                    <div className="flex items-center gap-3">
                        <span className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-widest border ${
                            data.route_type === 'EXTRAORDINARIA' 
                                ? 'bg-purple-500/10 border-purple-500/30 text-purple-600' 
                                : 'bg-blue-500/10 border-blue-500/30 text-blue-600'
                        }`}>
                            {data.route_type === 'EXTRAORDINARIA' ? '⚡ Ruta Extraordinaria' : '📋 Ruta Regular'}
                            {data.route_label && ` — ${data.route_label}`}
                        </span>
                        <span className="text-xs font-bold text-black/50">{data.client_count} clientes</span>
                    </div>
                )}
            </div>

            {loading ? (
                <div className="flex-1 flex items-center justify-center h-64">
                    <div className="text-center space-y-4">
                        <div className="text-5xl animate-pulse">🍞</div>
                        <p className="text-black/50 font-bold uppercase tracking-widest text-sm animate-pulse">Calculando estimación...</p>
                    </div>
                </div>
            ) : !data || data.client_count === 0 ? (
                <div className="max-w-xl mx-auto">
                    <div className="bg-white/70 border-2 border-dashed border-black/10 rounded-[32px] p-12 text-center space-y-4">
                        <div className="text-5xl">📭</div>
                        <h2 className="text-xl font-black text-black/60">No hay ruta para {dayName} {targetDate}</h2>
                        <p className="text-sm text-black/40 font-medium">No hay clientes asignados en la ruta regular ni extraordinaria para esta fecha.</p>
                    </div>
                </div>
            ) : (
                <>
                    {/* Tabla Resumen — Total por Producto */}
                    <div className="bg-white/80 backdrop-blur-md border border-black/10 rounded-[24px] overflow-hidden shadow-lg">
                        <div className="p-5 md:p-6 border-b border-black/5 flex items-center justify-between">
                            <div>
                                <h3 className="text-lg font-black italic uppercase tracking-tight text-black">
                                    🍞 Piezas a <span className="text-orange-500">Producir</span>
                                </h3>
                                <p className="text-[9px] font-bold text-black/40 uppercase tracking-[0.3em] mt-1">
                                    Basado en promedio de las últimas 10 visitas por cliente
                                </p>
                            </div>
                            <div className="bg-orange-500/10 border border-orange-500/20 rounded-2xl px-5 py-3 text-center shrink-0">
                                <div className="text-3xl font-black text-orange-500">{totalPiezas}</div>
                                <div className="text-[8px] font-black text-orange-500/60 uppercase tracking-widest">Total Piezas</div>
                            </div>
                        </div>
                        <div className="p-4 md:p-6">
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                {data.totals.filter(t => t.total_estimated > 0).map(t => (
                                    <div key={t.product_id} className="flex items-center justify-between bg-black/[0.03] rounded-2xl p-4 border border-black/5">
                                        <div className="flex-1 min-w-0">
                                            <div className="font-bold text-sm text-black truncate">{t.product_name}</div>
                                            <div className="text-[10px] text-black/40 font-bold">Promedio: {t.total_avg} pz</div>
                                        </div>
                                        <div className="text-2xl font-black text-orange-500 ml-3">{t.total_estimated}</div>
                                    </div>
                                ))}
                                {data.totals.every(t => t.total_estimated === 0) && (
                                    <p className="col-span-full text-center text-black/40 font-bold py-4">Sin historial de ventas aún</p>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Desglose por Cliente — Tabla con columnas por producto */}
                    <div className="bg-white/80 backdrop-blur-md border border-black/10 rounded-[24px] overflow-hidden shadow-lg">
                        <div className="p-5 md:p-6 border-b border-black/5">
                            <h3 className="text-sm font-black italic uppercase tracking-tight text-black">
                                👥 Desglose por <span className="text-orange-500">Cliente</span>
                            </h3>
                            <p className="text-[9px] font-bold text-black/40 uppercase tracking-[0.3em] mt-1">
                                Piezas estimadas por producto para cada cliente de la ruta
                            </p>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-xs md:text-sm min-w-[500px]">
                                <thead>
                                    <tr className="text-[8px] md:text-[9px] font-black uppercase text-black/40 bg-black/[0.03] border-b border-black/10">
                                        <th className="text-center py-3 px-2 w-8">#</th>
                                        <th className="text-left py-3 px-3">Cliente</th>
                                        {data.totals.map(t => (
                                            <th key={t.product_id} className="text-center py-3 px-2 text-orange-500">
                                                {t.product_name.length > 10 ? t.product_name.substring(0, 10) + '…' : t.product_name}
                                            </th>
                                        ))}
                                        <th className="text-center py-3 px-2 text-black/60">Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {data.clients.map((c, i) => {
                                        const totalClient = c.products.reduce((s, p) => s + p.estimated_qty, 0);
                                        return (
                                            <tr key={c.client_id} className="border-t border-black/5 hover:bg-black/[0.02] transition-colors">
                                                <td className="py-3 px-2 text-center">
                                                    <span className="w-6 h-6 rounded-md bg-orange-500/10 border border-orange-500/20 inline-flex items-center justify-center text-[10px] font-black text-orange-500">{i + 1}</span>
                                                </td>
                                                <td className="py-3 px-3">
                                                    <div className="font-bold text-black text-xs truncate max-w-[160px]">{c.client_name}</div>
                                                    <div className="text-[9px] text-black/30 font-bold">{c.visit_count} visitas</div>
                                                </td>
                                                {data.totals.map(t => {
                                                    const prod = c.products.find(p => p.product_id === t.product_id);
                                                    const qty = prod ? prod.estimated_qty : 0;
                                                    return (
                                                        <td key={t.product_id} className={`py-3 px-2 text-center font-black ${qty > 0 ? 'text-orange-500' : 'text-black/10'}`}>
                                                            {qty > 0 ? qty : '—'}
                                                        </td>
                                                    );
                                                })}
                                                <td className="py-3 px-2 text-center font-black text-black/70">{totalClient > 0 ? totalClient : '—'}</td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                                <tfoot>
                                    <tr className="border-t-2 border-black/10 bg-orange-500/5">
                                        <td colSpan="2" className="py-3 px-3 font-black text-xs uppercase text-black/60">Total a Producir</td>
                                        {data.totals.map(t => (
                                            <td key={t.product_id} className="py-3 px-2 text-center font-black text-lg text-orange-500">
                                                {t.total_estimated > 0 ? t.total_estimated : '—'}
                                            </td>
                                        ))}
                                        <td className="py-3 px-2 text-center font-black text-lg text-black">{totalPiezas}</td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </>
            )}

            </div>
            </div>

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 4px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #1a1a1a; border-radius: 10px; }
                input[type="date"]::-webkit-calendar-picker-indicator { filter: none; }
            `}</style>
        </div>
    );
};
