import React, { useState, useEffect } from 'react';
import { 
    Activity, Table, PieChart as PieChartIcon, 
    Lock, Eye, BarChart2, Settings
} from 'lucide-react';

const API_BASE = `http://${window.location.hostname}:5001/api/v1`;
// Vibrant Flat Colors from SaaS Image
const COLORS = ['#FBBF24', '#10B981', '#3B82F6', '#8B5CF6', '#F97316', '#06B6D4', '#EF4444'];

export const EstadisticasVentasUI = ({ userPermissions = {} }) => {
    const [viewMode, setViewMode] = useState('chart'); // 'list' | 'chart'
    const [period, setPeriod] = useState(30); 
    
    const canViewMonetary = userPermissions.all === 'full' || !!userPermissions.analytics_financial_data;
    const [showMonetary, setShowMonetary] = useState(canViewMonetary);
    
    const [excludeAtypical, setExcludeAtypical] = useState(true);
    const [stats, setStats] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [showContextModal, setShowContextModal] = useState(false);
    const [sortConfig, setSortConfig] = useState({ key: 'total_revenue', direction: 'desc' });

    const loadData = async () => {
        setIsLoading(true);
        try {
            const resp = await fetch(`${API_BASE}/analytics/rankings?days=${period}`);
            if (resp.ok) {
                const data = await resp.json();
                setStats(data.all || []);
            }
        } catch (e) {
            console.error(e);
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, [period, excludeAtypical]);

    const handleSort = (key) => {
        let direction = 'desc';
        if (sortConfig.key === key && sortConfig.direction === 'desc') {
            direction = 'asc';
        }
        setSortConfig({ key, direction });
    };

    const sortedStats = [...stats].sort((a, b) => {
        if (a[sortConfig.key] < b[sortConfig.key]) {
            return sortConfig.direction === 'asc' ? -1 : 1;
        }
        if (a[sortConfig.key] > b[sortConfig.key]) {
            return sortConfig.direction === 'asc' ? 1 : -1;
        }
        return 0;
    });

    const totalRev = stats.reduce((acc, p) => acc + (p.total_revenue || 0), 0);
    const totalUnits = stats.reduce((acc, p) => acc + (p.total_quantity || 0), 0);
    const validMargins = stats.filter(p => typeof p.margin_percentage === 'number');
    const avgMargin = validMargins.length ? validMargins.reduce((acc, p) => acc + p.margin_percentage, 0) / validMargins.length : 0;

    const chartDataRevenue = [...stats].sort((a,b) => b.total_revenue - a.total_revenue).slice(0, 10);
    const chartDataVolume = [...stats].sort((a,b) => b.total_quantity - a.total_quantity).slice(0, 10);
    
    const categoryStats = stats.reduce((acc, curr) => {
        const cat = curr.category_name || 'Sin Categoría';
        if(!acc[cat]) acc[cat] = 0;
        acc[cat] += curr.total_revenue;
        return acc;
    }, {});
    const pieData = Object.keys(categoryStats).map(key => ({ name: key, value: categoryStats[key] }));

    return (
        <div className="flex flex-col h-full bg-[#FAFBFA] text-slate-700 font-sans tracking-tight">
            
            {/* Header Limpio y Simplificado */}
            <header className="flex flex-wrap items-center justify-between px-10 py-5 bg-white border-b border-slate-100/50 shadow-[0_2px_15px_rgba(0,0,0,0.02)] z-20">
                <div className="flex items-center gap-12">
                    <div>
                        <h1 className="text-2xl font-black tracking-tight text-slate-800 flex items-center gap-2">
                            Inteligencia Comercial
                        </h1>
                        <p className="text-xs font-semibold text-slate-400 mt-0.5">Analítica de rendimiento y proyección de valor</p>
                    </div>
                </div>

                <div className="flex items-center gap-5">
                    {/* Botón Periodo Moderno */}
                    <div className="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-lg p-1">
                        <select 
                            value={period} 
                            onChange={e => setPeriod(Number(e.target.value))}
                            className="bg-transparent text-slate-600 font-semibold text-sm rounded px-3 py-1.5 focus:outline-none cursor-pointer"
                        >
                            <option value={7}>Últimos 7 Días</option>
                            <option value={30}>Últimos 30 Días</option>
                            <option value={90}>Últimos 90 Días</option>
                        </select>
                    </div>

                    <div className="h-6 w-px bg-slate-200" />

                    {/* View Switch SaaS Style */}
                    <div className="flex items-center bg-slate-100 p-1.5 rounded-xl shadow-inner border border-slate-200/60">
                        <button 
                            onClick={() => setViewMode('list')}
                            className={`flex justify-center items-center p-1.5 px-3 rounded-lg text-sm font-bold transition-all ${
                                viewMode === 'list' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-400 hover:text-slate-600'
                            }`}
                        >
                            Tabla
                        </button>
                        <button 
                            onClick={() => setViewMode('chart')}
                            className={`flex justify-center items-center p-1.5 px-3 rounded-lg text-sm font-bold transition-all ${
                                viewMode === 'chart' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-400 hover:text-slate-600'
                            }`}
                        >
                            Gráficos
                        </button>
                    </div>

                    {/* Financial Security Toggle (Modern) */}
                    <button 
                        disabled={!canViewMonetary}
                        onClick={() => setShowMonetary(!showMonetary)}
                        className={`flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-bold transition-all ${
                            !canViewMonetary 
                                ? 'text-slate-400 bg-slate-100 cursor-not-allowed opacity-60' 
                                : showMonetary 
                                    ? 'bg-[#E0F2FE] text-[#0284C7] shadow-sm' 
                                    : 'bg-slate-100 text-slate-500 hover:bg-slate-200'
                        }`}
                        title={!canViewMonetary ? "Sin permisos de acceso" : "Alternar visualización de divisas"}
                    >
                        {!canViewMonetary ? <Lock size={16} /> : showMonetary ? <Eye size={16}/> : <Eye className="opacity-50" size={16}/>}
                        {showMonetary ? 'Cifras Visibles' : 'Cifras Ocultas'}
                    </button>

                    <button 
                        onClick={() => setShowContextModal(true)}
                        className="px-5 py-2.5 flex items-center justify-center bg-white border border-slate-200 text-slate-700 hover:text-blue-600 hover:border-blue-200 hover:bg-blue-50/50 rounded-xl transition-all shadow-sm font-bold text-sm tracking-wide"
                    >
                        CUSTOM
                    </button>
                </div>
            </header>

            {/* Panel Principal */}
            <div className="flex-1 overflow-auto p-8 lg:p-10 custom-scrollbar-light">
                {isLoading ? (
                    <div className="flex items-center justify-center h-full">
                        <Activity className="animate-spin text-blue-500" size={40} />
                    </div>
                ) : (
                    <div className="max-w-[1600px] mx-auto space-y-8 h-full flex flex-col">
                        
                        {/* Fila Módulos KPI Analíticos */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 shrink-0">
                            
                            {/* KPI 1 Gasto/Ingreso */}
                            <div className="bg-white rounded-2xl p-8 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 flex items-center justify-between">
                                <div className="flex flex-col">
                                    <span className="text-slate-500 text-sm font-semibold mb-2">Ingreso Total Bruto</span>
                                    <span className="text-[2.5rem] leading-none font-light tracking-[-0.05em] text-slate-800">
                                        {showMonetary ? `$${totalRev.toLocaleString()}` : "---"}
                                    </span>
                                </div>
                                <div className="flex items-end gap-2 h-16 w-16">
                                    <div className="w-4 bg-[#FBBF24] rounded-t-sm h-[40%]" />
                                    <div className="w-4 bg-[#10B981] rounded-t-sm h-[70%]" />
                                    <div className="w-4 bg-[#3B82F6] rounded-t-sm h-[100%]" />
                                </div>
                            </div>

                            {/* KPI 2 Volumen (Rate de Venta) */}
                            <div className="bg-white rounded-2xl p-8 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 flex items-center justify-between">
                                <div className="flex flex-col">
                                    <span className="text-slate-500 text-sm font-semibold mb-2">Volumen de Desplazamiento</span>
                                    <div className="flex items-baseline gap-2">
                                        <span className="text-[3rem] leading-none font-light tracking-[-0.05em] text-slate-800">{totalUnits.toLocaleString()}</span>
                                        <span className="text-slate-400 font-bold text-sm">Unid.</span>
                                    </div>
                                </div>
                                <div className="flex flex-col gap-3 w-1/3">
                                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                                        <div className="bg-[#EF4444] h-full" style={{width:'30%'}}/>
                                    </div>
                                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                                        <div className="bg-[#3B82F6] h-full" style={{width:'80%'}}/>
                                    </div>
                                </div>
                            </div>

                            {/* KPI 3 Rendimiento Promedio */}
                            <div className="bg-white rounded-2xl p-8 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 flex items-center justify-between">
                                <div className="flex flex-col">
                                    <span className="text-slate-500 text-sm font-semibold mb-2">Margen Promedio</span>
                                    <span className="text-[3rem] leading-none font-light tracking-[-0.05em] text-slate-800">
                                        {showMonetary ? `${avgMargin.toFixed(1)}` : "***"}
                                        {showMonetary && <span className="text-2xl text-slate-400">%</span>}
                                    </span>
                                </div>
                                <div className="relative w-24 h-12 flex items-end justify-center overflow-hidden">
                                   <div className="w-20 h-20 border-8 border-slate-100 rounded-full border-t-[#F97316] border-r-[#FBBF24] border-b-transparent border-l-transparent transform -rotate-45" />
                                </div>
                            </div>

                        </div>

                        {/* List View */}
                        {viewMode === 'list' && (
                            <div className="bg-white rounded-2xl shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 flex flex-col flex-1 min-h-[400px]">
                                <div className="overflow-auto custom-scrollbar-light h-full rounded-2xl">
                                    <table className="w-full text-left border-collapse text-sm">
                                        <thead className="bg-[#FAFBFA] border-b border-slate-100 sticky top-0 z-10">
                                            <tr>
                                                <th className="p-5 font-bold text-slate-400 uppercase tracking-wider text-[11px] cursor-pointer hover:text-blue-600" onClick={() => handleSort('product_name')}>Nombre del Producto</th>
                                                <th className="p-5 font-bold text-slate-400 uppercase tracking-wider text-[11px] cursor-pointer hover:text-blue-600" onClick={() => handleSort('category_name')}>Categoría</th>
                                                <th className="p-5 font-bold text-slate-400 uppercase tracking-wider text-[11px] cursor-pointer hover:text-blue-600 text-right" onClick={() => handleSort('total_quantity')}>Volumen (U)</th>
                                                <th className="p-5 font-bold text-slate-400 uppercase tracking-wider text-[11px] cursor-pointer hover:text-blue-600 text-right" onClick={() => handleSort('total_revenue')}>Ingresos Brutos</th>
                                                <th className="p-5 font-bold text-slate-400 uppercase tracking-wider text-[11px] cursor-pointer hover:text-blue-600 text-right" onClick={() => handleSort('margin_percentage')}>Rentabilidad (%)</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-50">
                                            {sortedStats.map((p, i) => (
                                                <tr key={p.product_id} className="hover:bg-slate-50/80 transition-colors">
                                                    <td className="p-5 font-bold text-slate-700">{p.product_name}</td>
                                                    <td className="p-5 font-semibold text-slate-500">{p.category_name || 'Sin Categoría'}</td>
                                                    <td className="p-5 text-right font-medium">
                                                        <span className="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-xs font-bold">{p.total_quantity}</span>
                                                    </td>
                                                    <td className={`p-5 text-right font-bold ${showMonetary ? 'text-emerald-600' : 'text-slate-400'}`}>
                                                        {showMonetary ? `$${p.total_revenue.toLocaleString()}` : '---'}
                                                    </td>
                                                    <td className="p-5 text-right">
                                                        {showMonetary ? (
                                                            <div className="flex items-center justify-end gap-2">
                                                                <div className="w-12 bg-slate-100 h-1.5 rounded-full overflow-hidden">
                                                                    <div className={`h-full ${p.margin_percentage > 50 ? 'bg-[#10B981]' : p.margin_percentage > 30 ? 'bg-[#FBBF24]' : 'bg-[#EF4444]'}`} style={{width: `${Math.min(100, Math.max(0, p.margin_percentage))}%`}} />
                                                                </div>
                                                                <span className="font-bold text-slate-600 text-xs w-10">{p.margin_percentage.toFixed(0)}%</span>
                                                            </div>
                                                        ) : (
                                                            <span className="text-slate-400 font-bold">***</span>
                                                        )}
                                                    </td>
                                                </tr>
                                            ))}
                                            {sortedStats.length === 0 && (
                                                <tr><td colSpan="5" className="p-10 text-center text-slate-400 italic text-sm">Sin movimiento en la franja definida.</td></tr>
                                            )}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        )}

                        {/* Chart View */}
                        {viewMode === 'chart' && (
                            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 flex-1 min-h-[400px] mb-10">
                                
                                {/* Sales Top (Revenue) */}
                                <div className="bg-white rounded-2xl shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 p-8 flex flex-col">
                                    <div className="flex justify-between items-center mb-8">
                                        <h3 className="text-slate-800 font-bold text-lg">Ranking de Mayores Ingresos</h3>
                                        <span className="text-slate-400 bg-slate-100 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide">Ingreso Bruto</span>
                                    </div>
                                    <div className="flex-1 flex flex-col gap-5 overflow-y-auto custom-scrollbar-light pr-2">
                                        {chartDataRevenue.map((p, i) => {
                                            const maxRev = Math.max(...chartDataRevenue.map(d => d.total_revenue));
                                            const w = (p.total_revenue / maxRev) * 100;
                                            const cColor = COLORS[i % COLORS.length];
                                            return (
                                                <div key={i} className="flex flex-col gap-2 w-full group">
                                                    <div className="flex justify-between font-semibold text-sm">
                                                        <span className="text-slate-600 truncate pr-4">{p.product_name}</span>
                                                        <span className="font-bold shrink-0" style={{color: showMonetary ? cColor : '#94A3B8'}}>
                                                            {showMonetary ? `$${p.total_revenue.toLocaleString()}` : '---'}
                                                        </span>
                                                    </div>
                                                    <div className="w-full bg-slate-50 h-4 rounded-sm overflow-hidden flex items-center">
                                                        <div className="h-full rounded-sm transition-all duration-1000 min-w-[2%]" style={{width: `${Math.max(2, w)}%`, backgroundColor: cColor}} />
                                                    </div>
                                                </div>
                                            )
                                        })}
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 grid-rows-2 gap-8">
                                    {/* Categorías (Stacked Bar Fake Donut) */}
                                    <div className="bg-white rounded-2xl shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 p-8 flex flex-col">
                                        <h3 className="text-slate-800 font-bold text-lg mb-8">Distribución por Categorías</h3>
                                        
                                        <div className="w-full bg-slate-100 h-16 rounded-2xl overflow-hidden flex shadow-inner mb-6 relative">
                                            {pieData.sort((a,b)=>b.value-a.value).map((d, i) => {
                                                const totalPie = pieData.reduce((acc,curr)=>acc+curr.value, 0);
                                                const w = (d.value / totalPie) * 100;
                                                return (
                                                    <div key={i} title={`${d.name} (${w.toFixed(1)}%)`} className="h-full transition-all duration-1000 min-w-[2%] hover:opacity-80 cursor-pointer" style={{width: `${w}%`, backgroundColor: COLORS[i % COLORS.length]}} />
                                                )
                                            })}
                                            {pieData.length === 0 && <div className="w-full h-full bg-slate-100 flex items-center justify-center text-slate-400 font-bold text-xs uppercase tracking-wider">Cargando</div>}
                                        </div>

                                        <div className="grid grid-cols-2 md:grid-cols-3 gap-y-4 gap-x-2">
                                            {pieData.map((d, i) => (
                                                <div key={i} className="flex items-center gap-2">
                                                    <div className="w-3 h-3 rounded-full shrink-0" style={{backgroundColor: COLORS[i % COLORS.length]}} />
                                                    <div className="flex flex-col">
                                                        <span className="text-xs font-semibold text-slate-500 truncate w-24 md:w-32">{d.name}</span>
                                                        <span className="text-[10px] font-bold text-slate-700">{showMonetary ? `$${(d.value/1000).toFixed(1)}k` : '---'}</span>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>

                                    {/* Total Volume */}
                                    <div className="bg-white rounded-2xl shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 p-8 flex flex-col">
                                        <h3 className="text-slate-800 font-bold text-lg mb-8">Frecuencia de Operaciones</h3>
                                        <div className="flex-1 overflow-y-auto custom-scrollbar-light space-y-4 pr-2">
                                            {chartDataVolume.slice(0,5).map((p, i) => {
                                                const maxVol = Math.max(...chartDataVolume.map(d => d.total_quantity));
                                                const w = (p.total_quantity / maxVol) * 100;
                                                return (
                                                    <div key={i} className="flex items-center gap-4">
                                                        <div className="w-5 font-light text-slate-400 text-lg">{i+1}</div>
                                                        <div className="flex-1 bg-slate-50 h-3 rounded-full overflow-hidden flex items-center">
                                                            <div className="bg-[#06B6D4] h-full rounded-full transition-all duration-1000 min-w-[5%]" style={{width: `${w}%`}} />
                                                        </div>
                                                        <div className="w-16 flex flex-col items-end">
                                                            <span className="font-bold text-slate-700 leading-none">{p.total_quantity}</span>
                                                        </div>
                                                    </div>
                                                )
                                            })}
                                        </div>
                                    </div>
                                </div>

                            </div>
                        )}
                    </div>
                )}
            </div>

            {/* Modal Clean */}
            {showContextModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-8 bg-slate-900/10 backdrop-blur-[2px] animate-in fade-in">
                    <div className="w-full max-w-lg bg-white rounded-2xl shadow-2xl p-8 border border-slate-100">
                        <div className="mb-8">
                            <h2 className="text-2xl font-light text-slate-800 tracking-tight">Contexto Operativo / Anormalidades</h2>
                            <p className="text-sm font-semibold text-slate-400 mt-1">Registro manual de incidencias externas (clima, eventos)</p>
                        </div>
                        
                        <div className="space-y-6">
                            <div>
                                <label className="text-xs font-bold text-slate-500 mb-2 block uppercase tracking-wider">Fecha de Registro</label>
                                <input type="date" className="w-full border border-slate-200 text-slate-700 bg-slate-50 font-semibold rounded-lg p-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-500/10" />
                            </div>

                            <label className="flex items-center gap-3 p-4 rounded-xl border border-slate-200 hover:bg-slate-50/50 cursor-pointer transition-colors shadow-sm">
                                <input type="checkbox" className="w-4 h-4 text-blue-600 border-slate-300 rounded focus:ring-blue-600" />
                                <span className="text-sm font-semibold text-slate-700">Marcar como atípico (Excluir de predicciones)</span>
                            </label>

                            <div>
                                <label className="text-xs font-bold text-slate-500 mb-2 block uppercase tracking-wider">Bitácora / Sustentos</label>
                                <textarea placeholder="Describe el suceso que alteró las ventas..." className="w-full border border-slate-200 text-slate-700 bg-slate-50 font-semibold rounded-lg p-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-500/10 min-h-[100px]" />
                            </div>
                        </div>

                        <div className="flex gap-4 mt-8">
                            <button onClick={() => setShowContextModal(false)} className="flex-1 py-3 rounded-xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50 transition-colors">Cancelar</button>
                            <button onClick={() => setShowContextModal(false)} className="flex-1 py-3 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition-colors shadow-md shadow-blue-600/20">Guardar Contexto</button>
                        </div>
                    </div>
                </div>
            )}

            <style>{`
                .custom-scrollbar-light::-webkit-scrollbar { width: 6px; }
                .custom-scrollbar-light::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar-light::-webkit-scrollbar-thumb { background: #E2E8F0; border-radius: 6px; }
                .custom-scrollbar-light::-webkit-scrollbar-thumb:hover { background: #CBD5E1; }
            `}</style>
        </div>
    );
};
