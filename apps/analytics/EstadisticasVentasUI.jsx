import React, { useState, useEffect, useMemo } from 'react';
import {
  Activity, BarChart2, BarChart, PieChart as PieChartIcon,
  Lock, Eye, EyeOff, Settings, Plus, Trash2, Edit3, Copy,
  ChevronUp, ChevronDown, ArrowLeft, TrendingUp, TrendingDown,
  List, Table, Zap, Target, DollarSign, Package, Percent, X, Check,
  LayoutDashboard, Sparkles
} from 'lucide-react';

const API_BASE = `http://${window.location.hostname}:5001/api/v1`;
const STORAGE_KEY = 'rderico_sales_dashboard_v2';

const COLOR_PALETTES = {
  vibrant:    { name: 'Vibrante',      colors: ['#FBBF24','#10B981','#3B82F6','#8B5CF6','#F97316','#06B6D4','#EF4444','#EC4899','#14B8A6','#F59E0B'] },
  ocean:      { name: 'Océano',        colors: ['#0EA5E9','#06B6D4','#14B8A6','#10B981','#22D3EE','#67E8F9','#0284C7','#0369A1','#155E75','#164E63'] },
  sunset:     { name: 'Atardecer',     colors: ['#F97316','#EF4444','#F59E0B','#EC4899','#FB923C','#FBBF24','#F472B6','#E11D48','#D97706','#DC2626'] },
  forest:     { name: 'Bosque',        colors: ['#10B981','#059669','#34D399','#6EE7B7','#047857','#A7F3D0','#065F46','#14B8A6','#0D9488','#0F766E'] },
  monochrome: { name: 'Monocromático', colors: ['#1E293B','#334155','#475569','#64748B','#94A3B8','#CBD5E1','#E2E8F0','#0F172A','#1E293B','#334155'] },
  royal:      { name: 'Royal',         colors: ['#7C3AED','#6D28D9','#8B5CF6','#A78BFA','#C4B5FD','#4C1D95','#5B21B6','#DDD6FE','#EDE9FE','#581C87'] },
};

const DATA_PARAMETERS = [
  { id: 'revenue',    label: 'Ingresos Brutos',     icon: DollarSign, isMoney: true },
  { id: 'volume',     label: 'Volumen (Unidades)',   icon: Package,    isMoney: false },
  { id: 'margin',     label: 'Margen Absoluto ($)',  icon: TrendingUp, isMoney: true },
  { id: 'margin_pct', label: 'Margen (%)',           icon: Percent,    isMoney: true },
  { id: 'cost',       label: 'Costo Acumulado',      icon: Target,     isMoney: true },
  { id: 'avg_price',  label: 'Precio Promedio',      icon: Zap,        isMoney: true },
  { id: 'time_series_dow', label: 'Tendencia por Día', icon: Activity, isMoney: true },
];

const CHART_TYPES = [
  { id: 'horizontal_bar', label: 'Barras Horizontales', icon: BarChart2,    desc: 'Ideal para rankings' },
  { id: 'vertical_bar',   label: 'Barras Verticales',   icon: BarChart,     desc: 'Comparativas' },
  { id: 'pie',            label: 'Circular',            icon: PieChartIcon, desc: 'Distribución %' },
  { id: 'donut',          label: 'Donut',               icon: PieChartIcon, desc: 'Con indicador central' },
  { id: 'table',          label: 'Tabla',               icon: Table,        desc: 'Análisis detallado' },
  { id: 'list',           label: 'Lista',               icon: List,         desc: 'Rankings rápidos' },
  { id: 'kpi_card',       label: 'Tarjeta KPI',         icon: TrendingUp,   desc: 'Indicador grande' },
];

const TEMPORALITY_OPTIONS = [
  { value: 7, label: '7 Días' }, { value: 14, label: '14 Días' },
  { value: 30, label: '30 Días' }, { value: 60, label: '60 Días' },
  { value: 90, label: '90 Días' }, { value: 180, label: '6 Meses' },
  { value: 365, label: '1 Año' },
];

const QUICK_PRESETS = [
  { label: '🏆 Top 10 Ingresos', config: { title: 'Top 10 Productos por Ingreso', dataParameter: 'revenue', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'vibrant', gridSpan: 'full' }},
  { label: '📦 Top 10 Volumen', config: { title: 'Top 10 por Volumen', dataParameter: 'volume', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'ocean', gridSpan: 'full' }},
  { label: '🥧 Categorías', config: { title: 'Distribución por Categorías', dataParameter: 'revenue', sortDirection: 'desc', limit: 15, chartType: 'donut', temporality: 30, colorPalette: 'vibrant', gridSpan: 'half' }},
  { label: '📉 Bottom 5 Margen', config: { title: 'Menor Margen', dataParameter: 'margin_pct', sortDirection: 'asc', limit: 5, chartType: 'list', temporality: 30, colorPalette: 'sunset', gridSpan: 'half' }},
  { label: '💰 Top 5 Rentables', config: { title: 'Más Rentables', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 5, chartType: 'vertical_bar', temporality: 30, colorPalette: 'forest', gridSpan: 'half' }},
  { label: '📊 Tabla Completa', config: { title: 'Análisis Detallado', dataParameter: 'revenue', sortDirection: 'desc', limit: 50, chartType: 'table', temporality: 30, colorPalette: 'monochrome', gridSpan: 'full' }},
  { label: '⚡ KPI Ingreso', config: { title: 'Ingreso Total', dataParameter: 'revenue', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'vibrant', gridSpan: 'third' }},
  { label: '📦 KPI Volumen', config: { title: 'Volumen Total', dataParameter: 'volume', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'ocean', gridSpan: 'third' }},
  { label: '📈 KPI Margen', config: { title: 'Margen Promedio', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'forest', gridSpan: 'third' }},
];

const DEFAULT_SECTIONS = [
  { id: 'dk1', title: 'Ingreso Total Bruto', dataParameter: 'revenue', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'third', order: 0 },
  { id: 'dk2', title: 'Volumen Desplazado', dataParameter: 'volume', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'ocean', customColors: [], gridSpan: 'third', order: 1 },
  { id: 'dk3', title: 'Margen Promedio', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'forest', customColors: [], gridSpan: 'third', order: 2 },
  { id: 'dt1', title: 'Top 10 Productos por Ingreso', dataParameter: 'revenue', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'full', order: 3 },
  { id: 'dd1', title: 'Distribución por Categorías', dataParameter: 'revenue', sortDirection: 'desc', limit: 15, chartType: 'donut', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'half', order: 4 },
  { id: 'dl1', title: 'Top 5 por Volumen', dataParameter: 'volume', sortDirection: 'desc', limit: 5, chartType: 'list', temporality: 30, colorPalette: 'ocean', customColors: [], gridSpan: 'half', order: 5 },
];

// ── UTILITIES ──────────────────────────────────────────────
const generateId = () => `s${Date.now()}_${Math.random().toString(36).substr(2,6)}`;
const getColors = (sec) => sec.colorPalette === 'custom' && sec.customColors?.length ? sec.customColors : (COLOR_PALETTES[sec.colorPalette]?.colors || COLOR_PALETTES.vibrant.colors);

const getDataValue = (item, param) => {
  switch(param) {
    case 'revenue': return item.total_revenue || 0;
    case 'volume': return item.total_quantity || 0;
    case 'margin': return item.margin_absolute || 0;
    case 'margin_pct': return item.margin_percentage || 0;
    case 'cost': return item.total_revenue ? item.total_revenue * (1 - (item.margin_percentage||0)/100) : 0;
    case 'avg_price': return item.total_quantity > 0 ? item.total_revenue / item.total_quantity : 0;
    case 'time_series_dow': return item.total_revenue || 0;
    default: return 0;
  }
};

const formatValue = (val, param, show) => {
  const p = DATA_PARAMETERS.find(x => x.id === param);
  if (p?.isMoney && !show) return '•••';
  if (param === 'margin_pct') return `${val.toFixed(1)}%`;
  if (param === 'volume') return val.toLocaleString();
  return `$${val.toLocaleString(undefined,{minimumFractionDigits:0,maximumFractionDigits:0})}`;
};

const processData = (allData, sec, timeSeriesMetrics) => {
  if (sec.dataParameter === 'time_series_dow') {
    const byDow = timeSeriesMetrics?.by_day_of_week || [];
    const daysOfWeek = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return daysOfWeek.map((name, i) => {
      const found = byDow.find(d => d.day_index === i);
      return { name, product_name: name, total_revenue: found ? found.revenue : 0 };
    });
  }

  if (!allData?.length) return [];
  if (sec.chartType === 'kpi_card') return allData;
  if (sec.chartType === 'pie' || sec.chartType === 'donut') {
    const m = {};
    allData.forEach(it => {
      const c = it.category_name || 'Sin Categoría';
      if (!m[c]) m[c] = { name: c, value: 0 };
      m[c].value += getDataValue(it, sec.dataParameter);
    });
    return Object.values(m).sort((a,b) => sec.sortDirection==='desc'? b.value-a.value : a.value-b.value).slice(0, sec.limit||15);
  }
  const sorted = [...allData].sort((a,b) => {
    const va = getDataValue(a, sec.dataParameter), vb = getDataValue(b, sec.dataParameter);
    return sec.sortDirection==='desc'? vb-va : va-vb;
  });
  return sec.limit > 0 ? sorted.slice(0, sec.limit) : sorted;
};

const loadSections = () => { try { const r = localStorage.getItem(STORAGE_KEY); if(r) return JSON.parse(r); } catch(e){} return [...DEFAULT_SECTIONS]; };
const saveSections = (s) => { try { localStorage.setItem(STORAGE_KEY, JSON.stringify(s)); } catch(e){} };

// ── WIDGETS ────────────────────────────────────────────────

const HorizontalBarWidget = ({ data, colors, showMonetary, section }) => {
  const maxVal = Math.max(...data.map(d => getDataValue(d, section.dataParameter)), 1);
  return (
    <div className="flex flex-col gap-4 w-full">
      {data.map((item, i) => {
        const val = getDataValue(item, section.dataParameter);
        const w = (val / maxVal) * 100;
        const color = colors[i % colors.length];
        return (
          <div key={i} className="group flex flex-col gap-1.5 w-full">
            <div className="flex justify-between text-sm font-semibold">
              <span className="text-slate-600 truncate pr-4">{item.product_name || item.name}</span>
              <span className="shrink-0 font-bold" style={{color}}>{formatValue(val, section.dataParameter, showMonetary)}</span>
            </div>
            <div className="w-full bg-slate-50 h-5 rounded-md overflow-hidden relative">
              <div className="h-full rounded-md transition-all duration-700 ease-out group-hover:brightness-110" style={{width:`${Math.max(2,w)}%`, backgroundColor: color}} />
              <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-end pr-2">
                <span className="text-[10px] font-bold text-white drop-shadow">{formatValue(val, section.dataParameter, showMonetary)}</span>
              </div>
            </div>
          </div>
        );
      })}
      {data.length === 0 && <p className="text-slate-400 text-sm italic text-center py-8">Sin datos disponibles</p>}
    </div>
  );
};

const VerticalBarWidget = ({ data, colors, showMonetary, section }) => {
  const maxVal = Math.max(...data.map(d => getDataValue(d, section.dataParameter)), 1);
  return (
    <div className="flex items-end gap-2 h-52 w-full pt-6">
      {data.map((item, i) => {
        const val = getDataValue(item, section.dataParameter);
        const h = (val / maxVal) * 100;
        const color = colors[i % colors.length];
        return (
          <div key={i} className="flex-1 flex flex-col items-center gap-1 group relative min-w-0">
            <div className="opacity-0 group-hover:opacity-100 transition-opacity absolute -top-6 bg-slate-800 text-white text-[9px] font-bold px-2 py-1 rounded-md whitespace-nowrap z-10">
              {formatValue(val, section.dataParameter, showMonetary)}
            </div>
            <div className="w-full rounded-t-md transition-all duration-700 ease-out group-hover:brightness-110" style={{height:`${Math.max(4,h)}%`, backgroundColor: color}} />
            <span className="text-[9px] text-slate-400 font-semibold truncate w-full text-center">{(item.product_name||item.name||'').slice(0,8)}</span>
          </div>
        );
      })}
    </div>
  );
};

const PieChartWidget = ({ data, colors, showMonetary, section }) => {
  const total = data.reduce((a, d) => a + (d.value || 0), 0);
  if (total === 0) return <p className="text-slate-400 text-sm italic text-center py-8">Sin datos</p>;
  let cumPct = 0;
  const gradientParts = data.map((d, i) => {
    const pct = (d.value / total) * 100;
    const start = cumPct;
    cumPct += pct;
    return `${colors[i % colors.length]} ${start}% ${cumPct}%`;
  });
  const gradient = `conic-gradient(${gradientParts.join(', ')})`;
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="w-44 h-44 rounded-full shadow-inner" style={{background: gradient}} />
      <div className="grid grid-cols-2 gap-x-4 gap-y-2 w-full">
        {data.map((d, i) => (
          <div key={i} className="flex items-center gap-2 group">
            <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{backgroundColor: colors[i%colors.length]}} />
            <div className="flex flex-col min-w-0">
              <span className="text-[11px] font-semibold text-slate-500 truncate">{d.name}</span>
              <span className="text-[10px] font-bold text-slate-700">{showMonetary ? formatValue(d.value, section.dataParameter, true) : '•••'}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const DonutChartWidget = ({ data, colors, showMonetary, section }) => {
  const total = data.reduce((a, d) => a + (d.value || 0), 0);
  if (total === 0) return <p className="text-slate-400 text-sm italic text-center py-8">Sin datos</p>;
  let cumPct = 0;
  const gradientParts = data.map((d, i) => {
    const pct = (d.value / total) * 100;
    const start = cumPct;
    cumPct += pct;
    return `${colors[i % colors.length]} ${start}% ${cumPct}%`;
  });
  const gradient = `conic-gradient(${gradientParts.join(', ')})`;
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="relative w-44 h-44">
        <div className="w-full h-full rounded-full shadow-inner" style={{background: gradient}} />
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-24 h-24 rounded-full bg-white shadow-sm flex items-center justify-center">
            <span className="text-lg font-bold text-slate-700">{showMonetary ? formatValue(total, section.dataParameter, true) : '•••'}</span>
          </div>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-x-4 gap-y-2 w-full">
        {data.map((d, i) => (
          <div key={i} className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{backgroundColor: colors[i%colors.length]}} />
            <div className="flex flex-col min-w-0">
              <span className="text-[11px] font-semibold text-slate-500 truncate">{d.name}</span>
              <span className="text-[10px] font-bold text-slate-700">{showMonetary ? `${((d.value/total)*100).toFixed(1)}%` : '•••'}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// ── Table, List, KPI widgets + Section Router ──

const TableWidget = ({ data, colors, showMonetary, section }) => {
  const [sortKey, setSortKey] = useState(section.dataParameter);
  const [sortDir, setSortDir] = useState('desc');
  const handleSort = (k) => { if(sortKey===k) setSortDir(d=>d==='desc'?'asc':'desc'); else { setSortKey(k); setSortDir('desc'); } };
  const sorted = [...data].sort((a,b) => { const va=getDataValue(a,sortKey), vb=getDataValue(b,sortKey); return sortDir==='desc'?vb-va:va-vb; });
  return (
    <div className="overflow-auto max-h-80 custom-scrollbar-light rounded-xl">
      <table className="w-full text-left text-sm border-collapse">
        <thead className="bg-slate-50 sticky top-0 z-10">
          <tr>
            <th className="p-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider w-8">#</th>
            <th className="p-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider cursor-pointer hover:text-blue-600" onClick={()=>handleSort('revenue')}>Producto</th>
            <th className="p-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Categoría</th>
            <th className="p-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right cursor-pointer hover:text-blue-600" onClick={()=>handleSort(section.dataParameter)}>
              {DATA_PARAMETERS.find(p=>p.id===section.dataParameter)?.label || 'Valor'}
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-50">
          {sorted.map((item, i) => (
            <tr key={i} className="hover:bg-slate-50/80 transition-colors">
              <td className="p-3"><span className="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold text-white" style={{backgroundColor:colors[i%colors.length]}}>{i+1}</span></td>
              <td className="p-3 font-bold text-slate-700 truncate max-w-[200px]">{item.product_name}</td>
              <td className="p-3 text-slate-500 font-medium text-xs">{item.category_name||'—'}</td>
              <td className="p-3 text-right font-bold" style={{color: showMonetary||!DATA_PARAMETERS.find(p=>p.id===section.dataParameter)?.isMoney ? colors[0] : '#94A3B8'}}>
                {formatValue(getDataValue(item, section.dataParameter), section.dataParameter, showMonetary)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

const ListWidget = ({ data, colors, showMonetary, section }) => {
  const maxVal = Math.max(...data.map(d => getDataValue(d, section.dataParameter)), 1);
  return (
    <div className="flex flex-col gap-3">
      {data.map((item, i) => {
        const val = getDataValue(item, section.dataParameter);
        const w = (val / maxVal) * 100;
        return (
          <div key={i} className="flex items-center gap-3 group">
            <span className="text-2xl font-extralight text-slate-300 w-7 text-right">{i+1}</span>
            <div className="flex-1 min-w-0">
              <div className="flex justify-between items-baseline mb-1">
                <span className="text-sm font-semibold text-slate-600 truncate pr-2">{item.product_name||item.name}</span>
                <span className="text-xs font-bold shrink-0" style={{color:colors[i%colors.length]}}>{formatValue(val, section.dataParameter, showMonetary)}</span>
              </div>
              <div className="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
                <div className="h-full rounded-full transition-all duration-700" style={{width:`${Math.max(3,w)}%`, backgroundColor:colors[i%colors.length]}} />
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

const KPICardWidget = ({ data, colors, showMonetary, section }) => {
  let mainValue = 0;
  if (section.dataParameter === 'margin_pct' || section.dataParameter === 'avg_price') {
    const vals = data.map(d => getDataValue(d, section.dataParameter)).filter(v => v > 0);
    mainValue = vals.length ? vals.reduce((a,b)=>a+b,0) / vals.length : 0;
  } else {
    mainValue = data.reduce((a, d) => a + getDataValue(d, section.dataParameter), 0);
  }
  // Trend: compare first half vs second half
  const half = Math.floor(data.length / 2);
  const firstHalf = data.slice(0, half).reduce((a,d) => a + getDataValue(d, section.dataParameter), 0);
  const secondHalf = data.slice(half).reduce((a,d) => a + getDataValue(d, section.dataParameter), 0);
  const trendUp = secondHalf >= firstHalf;
  return (
    <div className="flex items-center justify-between h-full">
      <div className="flex flex-col">
        <span className="text-slate-500 text-xs font-semibold mb-2">{section.title}</span>
        <span className="text-4xl font-extralight tracking-tight text-slate-800 leading-none">
          {formatValue(mainValue, section.dataParameter, showMonetary)}
        </span>
        <div className="flex items-center gap-1 mt-2">
          {trendUp ? <TrendingUp size={14} className="text-emerald-500" /> : <TrendingDown size={14} className="text-red-400" />}
          <span className={`text-[10px] font-bold ${trendUp ? 'text-emerald-500' : 'text-red-400'}`}>
            {trendUp ? 'Tendencia positiva' : 'Tendencia a la baja'}
          </span>
        </div>
      </div>
      <div className="flex items-end gap-1.5 h-14 opacity-60">
        <div className="w-3 rounded-t-sm" style={{height:'40%', backgroundColor:colors[0]}} />
        <div className="w-3 rounded-t-sm" style={{height:'70%', backgroundColor:colors[1]||colors[0]}} />
        <div className="w-3 rounded-t-sm" style={{height:'100%', backgroundColor:colors[2]||colors[0]}} />
      </div>
    </div>
  );
};

const DashboardSection = ({ section, allData, showMonetary, index, timeSeriesMetrics }) => {
  const data = useMemo(() => processData(allData, section, timeSeriesMetrics), [allData, section, timeSeriesMetrics]);
  const colors = getColors(section);
  const props = { data, colors, showMonetary, section };
  const Widget = { horizontal_bar: HorizontalBarWidget, vertical_bar: VerticalBarWidget, pie: PieChartWidget, donut: DonutChartWidget, table: TableWidget, list: ListWidget, kpi_card: KPICardWidget }[section.chartType] || HorizontalBarWidget;
  const isKPI = section.chartType === 'kpi_card';
  return (
    <div className="bg-white rounded-2xl shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 p-6 flex flex-col dashboard-section-enter" style={{animationDelay:`${index*100}ms`}}>
      {!isKPI && <h3 className="text-slate-800 font-bold text-base mb-5">{section.title}</h3>}
      <div className="flex-1"><Widget {...props} /></div>
    </div>
  );
};

// ── SECTION EDITOR MODAL ──────────────────────────────────

const SectionEditorModal = ({ section, onSave, onClose, allData }) => {
  const [form, setForm] = useState(section || {
    title: '', dataParameter: 'revenue', sortDirection: 'desc', limit: 10,
    chartType: 'horizontal_bar', temporality: 30, colorPalette: 'vibrant',
    customColors: [], gridSpan: 'full'
  });
  const upd = (k, v) => setForm(f => ({...f, [k]: v}));
  const previewSection = { ...form, id: 'preview' };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/20 backdrop-blur-md" onClick={onClose}>
      <div className="w-full max-w-5xl max-h-[90vh] overflow-auto bg-white/95 backdrop-blur-xl rounded-3xl shadow-2xl border border-white/50 p-8" onClick={e=>e.stopPropagation()}>
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold text-slate-800">{section ? 'Editar Sección' : 'Nueva Sección'}</h2>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-xl transition-colors"><X size={20} className="text-slate-400"/></button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Form */}
          <div className="space-y-5">
            {/* Title */}
            <div>
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Título de la Sección</label>
              <input value={form.title} onChange={e=>upd('title',e.target.value)} placeholder="Ej: Top 10 Productos por Ingreso"
                className="w-full border border-slate-200 bg-slate-50 rounded-xl p-3 text-sm font-semibold text-slate-700 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-500/10" />
            </div>

            {/* Data Parameter */}
            <div>
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Parámetro de Datos</label>
              <div className="grid grid-cols-3 gap-2">
                {DATA_PARAMETERS.map(p => {
                  const Icon = p.icon;
                  return (
                    <button key={p.id} onClick={()=>upd('dataParameter',p.id)}
                      className={`flex items-center gap-2 p-2.5 rounded-xl text-xs font-bold transition-all border ${form.dataParameter===p.id ? 'bg-blue-50 border-blue-300 text-blue-700' : 'border-slate-200 text-slate-500 hover:bg-slate-50'}`}>
                      <Icon size={14}/> {p.label}
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Chart Type */}
            <div>
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Tipo de Gráfico</label>
              <div className="grid grid-cols-4 gap-2">
                {CHART_TYPES.map(ct => {
                  const Icon = ct.icon;
                  return (
                    <button key={ct.id} onClick={()=>upd('chartType',ct.id)}
                      className={`flex flex-col items-center gap-1 p-3 rounded-xl text-[10px] font-bold transition-all border ${form.chartType===ct.id ? 'bg-blue-50 border-blue-300 text-blue-700' : 'border-slate-200 text-slate-500 hover:bg-slate-50'}`}>
                      <Icon size={18}/> {ct.label}
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Row: Sort + Limit + Temporality */}
            <div className="grid grid-cols-3 gap-3">
              <div>
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Orden</label>
                <select value={form.sortDirection} onChange={e=>upd('sortDirection',e.target.value)} className="w-full border border-slate-200 bg-slate-50 rounded-xl p-2.5 text-xs font-semibold text-slate-700 focus:outline-none">
                  <option value="desc">Mayor → Menor</option>
                  <option value="asc">Menor → Mayor</option>
                </select>
              </div>
              <div>
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Límite</label>
                <select value={form.limit} onChange={e=>upd('limit',Number(e.target.value))} className="w-full border border-slate-200 bg-slate-50 rounded-xl p-2.5 text-xs font-semibold text-slate-700 focus:outline-none">
                  <option value={0}>Todos</option>
                  {[3,5,7,10,15,20,25,50].map(n=><option key={n} value={n}>{n} items</option>)}
                </select>
              </div>
              <div>
                <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Temporalidad</label>
                <select value={form.temporality} onChange={e=>upd('temporality',Number(e.target.value))} className="w-full border border-slate-200 bg-slate-50 rounded-xl p-2.5 text-xs font-semibold text-slate-700 focus:outline-none">
                  {TEMPORALITY_OPTIONS.map(t=><option key={t.value} value={t.value}>{t.label}</option>)}
                </select>
              </div>
            </div>

            {/* Grid Span */}
            <div>
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Tamaño en Dashboard</label>
              <div className="flex gap-2">
                {[{v:'third',l:'Tercio'},{v:'half',l:'Medio'},{v:'full',l:'Completo'}].map(s=>(
                  <button key={s.v} onClick={()=>upd('gridSpan',s.v)} className={`flex-1 p-2.5 rounded-xl text-xs font-bold border transition-all ${form.gridSpan===s.v?'bg-blue-50 border-blue-300 text-blue-700':'border-slate-200 text-slate-500 hover:bg-slate-50'}`}>{s.l}</button>
                ))}
              </div>
            </div>

            {/* Color Palette */}
            <div>
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-1.5">Paleta de Colores</label>
              <div className="grid grid-cols-3 gap-2">
                {Object.entries(COLOR_PALETTES).map(([k, pal]) => (
                  <button key={k} onClick={()=>upd('colorPalette',k)} className={`flex items-center gap-2 p-2.5 rounded-xl border transition-all ${form.colorPalette===k?'border-blue-300 bg-blue-50':'border-slate-200 hover:bg-slate-50'}`}>
                    <div className="flex gap-0.5">{pal.colors.slice(0,4).map((c,j)=><div key={j} className="w-3 h-3 rounded-full" style={{backgroundColor:c}}/>)}</div>
                    <span className="text-[10px] font-bold text-slate-600">{pal.name}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Preview */}
          <div className="flex flex-col">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-2">Vista Previa</label>
            <div className="flex-1 border-2 border-dashed border-slate-200 rounded-2xl p-4 bg-slate-50/50 min-h-[300px]">
              {(allData?.length > 0 || form.dataParameter === 'time_series_dow') ? (
                <DashboardSection section={previewSection} allData={allData} showMonetary={true} index={0} timeSeriesMetrics={timeSeriesMetrics} />
              ) : (
                <div className="flex items-center justify-center h-full text-slate-400 text-sm">Cargando datos para preview...</div>
              )}
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-3 mt-6 pt-6 border-t border-slate-100">
          <button onClick={onClose} className="flex-1 py-3 rounded-xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50 transition-colors">Cancelar</button>
          <button onClick={()=>{if(!form.title.trim())return;onSave({...form,id:form.id||generateId(),customColors:form.customColors||[],order:form.order||0});}} className="flex-1 py-3 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition-colors shadow-md shadow-blue-600/20 flex items-center justify-center gap-2"><Check size={16}/> Guardar Sección</button>
        </div>
      </div>
    </div>
  );
};

// ── SALES KPIs VIEW ───────────────────────────────────────

const SalesKPIsView = ({ allData, showMonetary, ticketMetrics, timeSeriesMetrics }) => {
  const totalRev = allData.reduce((a, d) => a + (d.total_revenue||0), 0);
  const totalUnits = allData.reduce((a, d) => a + (d.total_quantity||0), 0);
  const validMargins = allData.filter(p => typeof p.margin_percentage === 'number' && p.margin_percentage > 0);
  const avgMargin = validMargins.length ? validMargins.reduce((a,p) => a + p.margin_percentage, 0) / validMargins.length : 0;
  const totalTickets = ticketMetrics?.total_tickets || 0;
  const ticketAvg = totalTickets > 0 ? totalRev / totalTickets : 0;
  
  // Procesar Time Series (Día de la semana)
  const daysOfWeek = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  const byDow = timeSeriesMetrics?.by_day_of_week || [];
  const maxDowRev = Math.max(...byDow.map(d => d.revenue), 1);
  // Asegurar que todos los días existan
  const dowChartData = daysOfWeek.map((name, i) => {
    const found = byDow.find(d => d.day_index === i);
    return { name, revenue: found ? found.revenue : 0 };
  });
  const totalCost = allData.reduce((a,d) => a + ((d.total_revenue||0) * (1 - (d.margin_percentage||0)/100)), 0);

  const topRevenue = [...allData].sort((a,b) => b.total_revenue - a.total_revenue).slice(0,10);
  const topVolume = [...allData].sort((a,b) => b.total_quantity - a.total_quantity).slice(0,10);
  const bottomMargin = [...allData].filter(p => p.margin_percentage > 0).sort((a,b) => a.margin_percentage - b.margin_percentage).slice(0,5);

  const catMap = {};
  allData.forEach(it => {
    const c = it.category_name || 'Sin Categoría';
    if (!catMap[c]) catMap[c] = { name: c, value: 0 };
    catMap[c].value += it.total_revenue || 0;
  });
  const catData = Object.values(catMap).sort((a,b) => b.value - a.value);
  const catTotal = catData.reduce((a,d) => a + d.value, 0);

  const COLS = COLOR_PALETTES.vibrant.colors;
  const OCEAN = COLOR_PALETTES.ocean.colors;

  const KPICard = ({ label, value, subtitle, color, icon: Icon }) => (
    <div className="bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 flex flex-col justify-between dashboard-section-enter">
      <div className="flex items-start justify-between mb-4">
        <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">{label}</span>
        <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{backgroundColor: color + '15'}}>
          <Icon size={18} style={{color}} />
        </div>
      </div>
      <div>
        <span className="text-3xl font-extralight tracking-tight text-slate-800 leading-none">{showMonetary ? value : '•••'}</span>
        {subtitle && <p className="text-[10px] font-semibold text-slate-400 mt-2">{subtitle}</p>}
      </div>
    </div>
  );

  const maxRev = Math.max(...topRevenue.map(d => d.total_revenue), 1);
  const maxVol = Math.max(...topVolume.map(d => d.total_quantity), 1);

  return (
    <div className="max-w-[1600px] mx-auto space-y-8">
      {/* KPI Cards Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
        <KPICard label="Ingreso Bruto Total" value={`$${totalRev.toLocaleString()}`} subtitle={`${allData.length} productos activos`} color="#10B981" icon={DollarSign} />
        <KPICard label="Volumen Desplazado" value={`${totalUnits.toLocaleString()} uds`} subtitle="Unidades vendidas en el periodo" color="#3B82F6" icon={Package} />
        <KPICard label="Ticket Promedio" value={`$${ticketAvg.toLocaleString(undefined,{maximumFractionDigits:0})}`} subtitle={`${totalTickets.toLocaleString()} tickets en el periodo`} color="#8B5CF6" icon={Zap} />
        <KPICard label="Margen Promedio" value={`${avgMargin.toFixed(1)}%`} subtitle={showMonetary ? `Costo acumulado: $${totalCost.toLocaleString(undefined,{maximumFractionDigits:0})}` : ''} color="#F59E0B" icon={Percent} />
      </div>

      {/* Row 2: Top Revenue + Category Donut */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Top 10 Revenue */}
        <div className="lg:col-span-3 bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 dashboard-section-enter" style={{animationDelay:'100ms'}}>
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-bold text-slate-800">Top 10 por Ingresos</h3>
            <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full uppercase tracking-wide">Revenue</span>
          </div>
          <div className="space-y-3">
            {topRevenue.map((p, i) => {
              const w = (p.total_revenue / maxRev) * 100;
              return (
                <div key={i} className="group">
                  <div className="flex justify-between text-sm mb-1">
                    <span className="font-semibold text-slate-600 truncate pr-3">{p.product_name}</span>
                    <span className="font-bold shrink-0" style={{color:COLS[i%COLS.length]}}>{showMonetary ? `$${p.total_revenue.toLocaleString()}` : '•••'}</span>
                  </div>
                  <div className="w-full bg-slate-50 h-4 rounded-md overflow-hidden">
                    <div className="h-full rounded-md transition-all duration-700 group-hover:brightness-110" style={{width:`${Math.max(2,w)}%`, backgroundColor:COLS[i%COLS.length]}} />
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Category Donut */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 dashboard-section-enter" style={{animationDelay:'200ms'}}>
          <h3 className="font-bold text-slate-800 mb-6">Distribución por Categoría</h3>
          {catTotal > 0 && (
            <div className="flex flex-col items-center gap-5">
              <div className="relative w-40 h-40">
                <div className="w-full h-full rounded-full shadow-inner" style={{background: `conic-gradient(${catData.map((d,i) => { const pct = (d.value/catTotal)*100; const start = catData.slice(0,i).reduce((a,x)=>(a+(x.value/catTotal)*100),0); return `${COLS[i%COLS.length]} ${start}% ${start+pct}%`; }).join(', ')})`}} />
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="w-20 h-20 rounded-full bg-white shadow-sm flex items-center justify-center flex-col">
                    <span className="text-xs font-bold text-slate-700">{catData.length}</span>
                    <span className="text-[9px] text-slate-400 font-semibold">categorías</span>
                  </div>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-x-4 gap-y-2 w-full">
                {catData.slice(0,8).map((d,i) => (
                  <div key={i} className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{backgroundColor:COLS[i%COLS.length]}} />
                    <div className="flex flex-col min-w-0">
                      <span className="text-[10px] font-semibold text-slate-500 truncate">{d.name}</span>
                      <span className="text-[10px] font-bold text-slate-700">{showMonetary ? `${((d.value/catTotal)*100).toFixed(1)}%` : '•••'}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Row 3: Top Volume + Bottom Margin */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 pb-8">
        {/* Top 10 Volume */}
        <div className="bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 dashboard-section-enter" style={{animationDelay:'300ms'}}>
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-bold text-slate-800">Top 10 por Volumen</h3>
            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2.5 py-1 rounded-full uppercase tracking-wide">Unidades</span>
          </div>
          <div className="space-y-3">
            {topVolume.map((p, i) => {
              const w = (p.total_quantity / maxVol) * 100;
              return (
                <div key={i} className="flex items-center gap-3">
                  <span className="text-xl font-extralight text-slate-300 w-6 text-right">{i+1}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-baseline mb-1">
                      <span className="text-sm font-semibold text-slate-600 truncate pr-2">{p.product_name}</span>
                      <span className="text-xs font-bold shrink-0" style={{color:OCEAN[i%OCEAN.length]}}>{p.total_quantity.toLocaleString()} u</span>
                    </div>
                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                      <div className="h-full rounded-full transition-all duration-700" style={{width:`${Math.max(3,w)}%`, backgroundColor:OCEAN[i%OCEAN.length]}} />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Bottom 5 Margin — Alert Style */}
        <div className="bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 dashboard-section-enter" style={{animationDelay:'400ms'}}>
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-bold text-slate-800">⚠️ Productos con Menor Margen</h3>
            <span className="text-[10px] font-bold text-red-500 bg-red-50 px-2.5 py-1 rounded-full uppercase tracking-wide">Alerta</span>
          </div>
          <div className="space-y-3">
            {bottomMargin.map((p, i) => {
              const marginColor = p.margin_percentage < 20 ? '#EF4444' : p.margin_percentage < 35 ? '#F59E0B' : '#10B981';
              const bgColor = p.margin_percentage < 20 ? 'bg-red-50' : p.margin_percentage < 35 ? 'bg-amber-50' : 'bg-emerald-50';
              return (
                <div key={i} className={`flex items-center gap-4 p-3 rounded-xl ${bgColor} transition-all hover:shadow-sm`}>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{backgroundColor: marginColor + '20'}}>
                    <span className="text-sm font-bold" style={{color: marginColor}}>{showMonetary ? `${p.margin_percentage.toFixed(0)}%` : '•••'}</span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm font-bold text-slate-700 block truncate">{p.product_name}</span>
                    <span className="text-[10px] text-slate-500 font-semibold">{p.category_name || 'Sin categoría'}</span>
                  </div>
                  <div className="text-right">
                    <span className="text-xs font-bold text-slate-600 block">{showMonetary ? `$${p.total_revenue.toLocaleString()}` : '•••'}</span>
                    <span className="text-[10px] text-slate-400 font-semibold">{p.total_quantity} uds</span>
                  </div>
                </div>
              );
            })}
            {bottomMargin.length === 0 && <p className="text-slate-400 text-sm italic text-center py-6">Sin datos de margen disponibles</p>}
          </div>
        </div>
      </div>

      {/* Row 4: Time Series Charts */}
      {timeSeriesMetrics && (
        <div className="bg-white rounded-2xl p-6 shadow-[0_5px_20px_rgba(0,0,0,0.03)] border border-slate-100 dashboard-section-enter" style={{animationDelay:'500ms'}}>
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-bold text-slate-800">Ventas por Día de la Semana</h3>
            <span className="text-[10px] font-bold text-purple-600 bg-purple-50 px-2.5 py-1 rounded-full uppercase tracking-wide">Tendencias</span>
          </div>
          <div className="flex items-end justify-between gap-2 h-48 w-full pt-4">
            {dowChartData.map((d, i) => {
              const h = (d.revenue / maxDowRev) * 100;
              return (
                <div key={i} className="flex-1 flex flex-col items-center gap-2 group relative min-w-0">
                  <div className="opacity-0 group-hover:opacity-100 transition-opacity absolute -top-8 bg-slate-800 text-white text-[10px] font-bold px-2.5 py-1.5 rounded-lg whitespace-nowrap z-10 shadow-lg pointer-events-none">
                    {showMonetary ? `$${d.revenue.toLocaleString(undefined,{maximumFractionDigits:0})}` : '•••'}
                  </div>
                  <div className="w-full rounded-t-xl transition-all duration-700 ease-out group-hover:brightness-110 bg-gradient-to-t from-purple-600 to-indigo-400" style={{height:`${Math.max(4,h)}%`}} />
                  <span className="text-xs text-slate-500 font-bold w-full text-center">{d.name}</span>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};

// ── MAIN COMPONENT ────────────────────────────────────────

export const EstadisticasVentasUI = ({ userPermissions = {} }) => {
  const [activeView, setActiveView] = useState('dashboard');
  const [dashboardTab, setDashboardTab] = useState('dashboard');
  const [sections, setSections] = useState(() => loadSections());
  const canViewMonetary = userPermissions.all === 'full' || !!userPermissions.analytics_financial_data;
  const [showMonetary, setShowMonetary] = useState(canViewMonetary);
  const [allData, setAllData] = useState([]);
  const [ticketMetrics, setTicketMetrics] = useState(null);
  const [timeSeriesMetrics, setTimeSeriesMetrics] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [editingSection, setEditingSection] = useState(null);
  const [showEditor, setShowEditor] = useState(false);

  const updateSections = (newSections) => { setSections(newSections); saveSections(newSections); };

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        const temps = [...new Set(sections.map(s => s.temporality))];
        const maxTemp = Math.max(...temps, 30);
        const resp = await fetch(`${API_BASE}/analytics/rankings?days=${maxTemp}`);
        if (resp.ok) { 
          const d = await resp.json(); 
          setAllData(d.all || []); 
          setTicketMetrics(d.ticket_metrics || null);
          setTimeSeriesMetrics(d.time_series_metrics || null);
        }
      } catch(e) { console.error(e); }
      finally { setIsLoading(false); }
    };
    fetchData();
  }, [sections.map(s=>s.temporality).join(',')]);

  const addSection = (config) => {
    const newSec = { ...config, id: config.id || generateId(), order: sections.length };
    updateSections([...sections, newSec]);
  };
  const removeSection = (id) => updateSections(sections.filter(s => s.id !== id));
  const duplicateSection = (id) => {
    const orig = sections.find(s => s.id === id);
    if (orig) addSection({ ...orig, id: generateId(), title: `${orig.title} (copia)` });
  };
  const moveSection = (id, dir) => {
    const idx = sections.findIndex(s => s.id === id);
    if ((dir === -1 && idx === 0) || (dir === 1 && idx === sections.length - 1)) return;
    const arr = [...sections];
    [arr[idx], arr[idx + dir]] = [arr[idx + dir], arr[idx]];
    updateSections(arr.map((s, i) => ({ ...s, order: i })));
  };
  const saveEditedSection = (sec) => {
    const exists = sections.find(s => s.id === sec.id);
    if (exists) updateSections(sections.map(s => s.id === sec.id ? sec : s));
    else addSection(sec);
    setShowEditor(false); setEditingSection(null);
  };

  const sortedSections = [...sections].sort((a, b) => (a.order || 0) - (b.order || 0));

  // ── DASHBOARD VIEW ──
  if (activeView === 'dashboard') return (
    <div className="flex flex-col h-full bg-[#FAFBFA] text-slate-700 font-sans">
      <header className="flex flex-wrap items-center justify-between px-8 py-5 bg-white border-b border-slate-100/50 shadow-[0_2px_15px_rgba(0,0,0,0.02)] z-20">
        <div className="flex items-center gap-8">
          <div>
            <h1 className="text-2xl font-black tracking-tight text-slate-800">Estadísticas de Ventas</h1>
            <p className="text-xs font-semibold text-slate-400 mt-0.5">Analítica de rendimiento y proyección de valor</p>
          </div>
          <div className="flex items-center bg-slate-100 p-1 rounded-xl">
            <button onClick={()=>setDashboardTab('dashboard')}
              className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${dashboardTab==='dashboard'?'bg-white text-blue-600 shadow-sm':'text-slate-400 hover:text-slate-600'}`}>
              Dashboard
            </button>
            <button onClick={()=>setDashboardTab('kpis')}
              className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${dashboardTab==='kpis'?'bg-white text-blue-600 shadow-sm':'text-slate-400 hover:text-slate-600'}`}>
              KPIs de Ventas
            </button>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <button disabled={!canViewMonetary} onClick={()=>setShowMonetary(!showMonetary)}
            className={`flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-bold transition-all ${!canViewMonetary?'text-slate-400 bg-slate-100 cursor-not-allowed opacity-60':showMonetary?'bg-[#E0F2FE] text-[#0284C7] shadow-sm':'bg-slate-100 text-slate-500 hover:bg-slate-200'}`}
            title={!canViewMonetary?"Sin permisos":"Alternar cifras"}>
            {!canViewMonetary?<Lock size={16}/>:showMonetary?<Eye size={16}/>:<EyeOff size={16}/>}
            {showMonetary?'Cifras Visibles':'Cifras Ocultas'}
          </button>
          <button onClick={()=>setActiveView('manager')}
            className="px-5 py-2.5 flex items-center gap-2 bg-blue-600 text-white hover:bg-blue-700 rounded-xl transition-all shadow-md shadow-blue-600/20 font-bold text-sm">
            <Settings size={16}/> Gestionar Dashboard de Ventas
          </button>
        </div>
      </header>

      <div className="flex-1 overflow-auto p-8 custom-scrollbar-light">
        {isLoading ? (
          <div className="flex items-center justify-center h-full"><Activity className="animate-spin text-blue-500" size={40}/></div>
        ) : dashboardTab === 'kpis' ? (
          <SalesKPIsView allData={allData} showMonetary={showMonetary} ticketMetrics={ticketMetrics} timeSeriesMetrics={timeSeriesMetrics} />
        ) : sortedSections.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full gap-6">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-blue-100 to-indigo-100 flex items-center justify-center animate-pulse">
              <LayoutDashboard size={40} className="text-blue-400"/>
            </div>
            <div className="text-center">
              <h2 className="text-2xl font-bold text-slate-700 mb-2">Tu dashboard está vacío</h2>
              <p className="text-slate-400 font-medium">Configura tus secciones para visualizar tus métricas de ventas</p>
            </div>
            <button onClick={()=>setActiveView('manager')} className="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 flex items-center gap-2">
              <Sparkles size={18}/> Diseña tu primer dashboard
            </button>
          </div>
        ) : (
          <div className="max-w-[1600px] mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {sortedSections.map((sec, i) => (
              <div key={sec.id} className={sec.gridSpan==='full'?'col-span-full':sec.gridSpan==='half'?'md:col-span-1 lg:col-span-1':'col-span-1'} style={sec.gridSpan==='half'?{gridColumn:'span 1'}:{}}>
                <DashboardSection section={sec} allData={allData} showMonetary={showMonetary} index={i} timeSeriesMetrics={timeSeriesMetrics}/>
              </div>
            ))}
          </div>
        )}
      </div>
      <style>{STYLES_CSS}</style>
    </div>
  );

  // ── MANAGER VIEW ──
  return (
    <div className="flex flex-col h-full bg-[#FAFBFA] text-slate-700 font-sans">
      <header className="flex items-center justify-between px-8 py-5 bg-white border-b border-slate-100/50 shadow-[0_2px_15px_rgba(0,0,0,0.02)] z-20">
        <div className="flex items-center gap-4">
          <button onClick={()=>setActiveView('dashboard')} className="p-2.5 hover:bg-slate-100 rounded-xl transition-colors"><ArrowLeft size={20} className="text-slate-500"/></button>
          <div>
            <h1 className="text-2xl font-black tracking-tight text-slate-800">Gestor de Dashboard de Ventas</h1>
            <p className="text-xs font-semibold text-slate-400 mt-0.5">Configura las secciones y visualizaciones de tu dashboard</p>
          </div>
        </div>
        <span className="text-xs font-bold text-slate-400 bg-slate-100 px-3 py-1.5 rounded-full">{sections.length} secciones</span>
      </header>

      <div className="flex-1 overflow-auto p-8 custom-scrollbar-light">
        <div className="max-w-4xl mx-auto space-y-8">
          {/* Presets */}
          <div>
            <h3 className="text-sm font-bold text-slate-500 mb-3 flex items-center gap-2"><Sparkles size={14} className="text-amber-500"/> Presets Rápidos</h3>
            <div className="flex flex-wrap gap-2">
              {QUICK_PRESETS.map((p, i) => (
                <button key={i} onClick={()=>addSection({...p.config, id:generateId(), customColors:[], order:sections.length})}
                  className="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-600 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 transition-all shadow-sm">
                  {p.label}
                </button>
              ))}
            </div>
          </div>

          {/* Sections List */}
          <div className="space-y-3">
            <h3 className="text-sm font-bold text-slate-500 mb-3">Secciones del Dashboard</h3>
            {sortedSections.length === 0 && <p className="text-slate-400 text-sm italic py-8 text-center">No hay secciones. Usa un preset rápido o crea una personalizada.</p>}
            {sortedSections.map((sec, i) => {
              const ctLabel = CHART_TYPES.find(c=>c.id===sec.chartType)?.label || sec.chartType;
              const dpLabel = DATA_PARAMETERS.find(p=>p.id===sec.dataParameter)?.label || sec.dataParameter;
              const tmpLabel = TEMPORALITY_OPTIONS.find(t=>t.value===sec.temporality)?.label || `${sec.temporality}d`;
              return (
                <div key={sec.id} className="flex items-center gap-4 p-4 bg-white rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-all group">
                  <div className="flex flex-col gap-0.5 w-6 shrink-0">
                    <button onClick={()=>moveSection(sec.id,-1)} disabled={i===0} className="text-slate-300 hover:text-slate-600 disabled:opacity-30 transition-colors"><ChevronUp size={16}/></button>
                    <button onClick={()=>moveSection(sec.id,1)} disabled={i===sortedSections.length-1} className="text-slate-300 hover:text-slate-600 disabled:opacity-30 transition-colors"><ChevronDown size={16}/></button>
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-bold text-slate-700 truncate">{sec.title || 'Sin título'}</h4>
                    <div className="flex gap-2 mt-1.5 flex-wrap">
                      <span className="px-2 py-0.5 bg-blue-50 text-blue-600 rounded-md text-[10px] font-bold">{ctLabel}</span>
                      <span className="px-2 py-0.5 bg-emerald-50 text-emerald-600 rounded-md text-[10px] font-bold">{dpLabel}</span>
                      <span className="px-2 py-0.5 bg-amber-50 text-amber-600 rounded-md text-[10px] font-bold">{tmpLabel}</span>
                      <span className="px-2 py-0.5 bg-slate-100 text-slate-500 rounded-md text-[10px] font-bold">{sec.gridSpan==='full'?'Completo':sec.gridSpan==='half'?'Medio':'Tercio'}</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button onClick={()=>{setEditingSection(sec);setShowEditor(true);}} className="p-2 hover:bg-blue-50 rounded-lg transition-colors" title="Editar"><Edit3 size={15} className="text-blue-500"/></button>
                    <button onClick={()=>duplicateSection(sec.id)} className="p-2 hover:bg-slate-100 rounded-lg transition-colors" title="Duplicar"><Copy size={15} className="text-slate-400"/></button>
                    <button onClick={()=>removeSection(sec.id)} className="p-2 hover:bg-red-50 rounded-lg transition-colors" title="Eliminar"><Trash2 size={15} className="text-red-400"/></button>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Add Custom */}
          <button onClick={()=>{setEditingSection(null);setShowEditor(true);}}
            className="w-full py-4 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400 font-bold text-sm hover:border-blue-300 hover:text-blue-500 hover:bg-blue-50/30 transition-all flex items-center justify-center gap-2">
            <Plus size={18}/> Agregar Sección Personalizada
          </button>
        </div>
      </div>

      {showEditor && <SectionEditorModal section={editingSection} onSave={saveEditedSection} onClose={()=>{setShowEditor(false);setEditingSection(null);}} allData={allData} timeSeriesMetrics={timeSeriesMetrics}/>}
      <style>{STYLES_CSS}</style>
    </div>
  );
};

const STYLES_CSS = `
  @keyframes fadeInUp { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }
  .dashboard-section-enter { animation: fadeInUp 0.5s ease-out both; }
  .custom-scrollbar-light::-webkit-scrollbar { width:6px; }
  .custom-scrollbar-light::-webkit-scrollbar-track { background:transparent; }
  .custom-scrollbar-light::-webkit-scrollbar-thumb { background:#E2E8F0; border-radius:6px; }
  .custom-scrollbar-light::-webkit-scrollbar-thumb:hover { background:#CBD5E1; }
`;
