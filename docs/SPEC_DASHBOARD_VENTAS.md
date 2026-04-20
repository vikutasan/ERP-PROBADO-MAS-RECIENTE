# ESPECIFICACIÓN TÉCNICA: Dashboard de Ventas Configurable
# Documento autosuficiente para implementación por cualquier IA

## 1. CONTEXTO DEL PROYECTO

### Qué es esto
ERP web para una panadería llamada "R de Rico". Frontend en React + Vite + TailwindCSS. Backend en Python/FastAPI + PostgreSQL.

### Archivo a modificar
`C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO\apps\analytics\EstadisticasVentasUI.jsx`

Este archivo exporta `EstadisticasVentasUI` que se importa en `apps/ExperimentCenterUI.jsx` línea 17:
```jsx
import { EstadisticasVentasUI } from './analytics/EstadisticasVentasUI';
```
Y se renderiza en línea 264:
```jsx
{activeModule === 'analytics' && <EstadisticasVentasUI userPermissions={userPermissions} />}
```

### Props que recibe
- `userPermissions` — objeto con permisos del usuario. Si `userPermissions.all === 'full'` o `userPermissions.analytics_financial_data` existe, el usuario puede ver cifras monetarias.

### API disponible
Base: `http://${window.location.hostname}:5001/api/v1`

**GET `/analytics/rankings?days=30`** — Retorna:
```json
{
  "period": { "start": "2026-03-21", "end": "2026-04-20" },
  "top_volume": [...],
  "bottom_volume": [...],
  "top_margin": [...],
  "bottom_margin": [...],
  "all": [
    {
      "product_id": 1,
      "product_name": "Brownie Signature",
      "category_name": "A - B",
      "total_quantity": 150,
      "total_revenue": 4500.0,
      "margin_absolute": 15.0,
      "margin_percentage": 60.0
    }
  ]
}
```
Usamos el array `all` como fuente de datos para todos los widgets.

### Dependencias disponibles (ya instaladas)
- React 18, lucide-react, TailwindCSS 3, clsx, tailwind-merge
- NO hay librerías de gráficos (Recharts, Chart.js, etc.) — los gráficos se hacen con CSS puro y HTML

### Estilo visual del ERP
- Tema claro SaaS: fondo `#FAFBFA`, cards blancas, bordes `slate-100`, sombras suaves
- Tipografía: font-sans (sistema), font-semibold/font-bold para énfasis
- Esquinas redondeadas: `rounded-2xl` para cards
- Iconos: lucide-react

---

## 2. QUÉ SE DEBE CONSTRUIR

### Pantalla 1: "Dashboard de Ventas"
La vista principal que muestra el dashboard personalizado del usuario.

**Header:**
- Título h1: "Dashboard de Ventas"
- Subtítulo: "Analítica de rendimiento y proyección de valor"
- Esquina superior derecha: botón "Gestionar Dashboard de Ventas" con icono Settings → cambia a la vista del Gestor
- Toggle de cifras monetarias (mantener lógica de permisos existente)

**Contenido:**
- Grid CSS responsivo que renderiza las secciones configuradas
- Secciones `gridSpan: 'full'` → `col-span-full` (ancho completo)
- Secciones `gridSpan: 'half'` → `col-span-1` en grid de 2 columnas
- Secciones `gridSpan: 'third'` → `col-span-1` en grid de 3 columnas
- Cada sección es una card blanca con título y el widget correspondiente
- Animación de entrada escalonada: cada sección aparece con delay de `index * 100ms`

**Empty State (si no hay secciones):**
- Centrado, con icono grande y animación pulse
- Texto: "Tu dashboard está vacío"  
- Botón CTA: "Diseña tu primer dashboard" → navega al gestor
- Fondo con gradiente sutil animado

### Pantalla 2: "Gestor de Dashboard de Ventas"
Suite de administración para configurar las secciones del dashboard.

**Header:**
- Botón "← Volver al Dashboard" (esquina izquierda)
- Título: "Gestor de Dashboard de Ventas"

**Presets Rápidos:**
- Fila de chips/botones scrolleables horizontalmente
- Click en preset → agrega esa sección predefinida al dashboard

**Lista de Secciones:**
- Cada sección muestra: título, badges (tipo gráfico, parámetro, temporalidad)
- Botones: Editar, Duplicar, Eliminar, Mover ↑, Mover ↓

**Botón "Agregar Sección Personalizada":**
- Abre el modal editor

### Modal: Editor de Sección
Panel modal con glassmorphism (`bg-white/95 backdrop-blur-xl`) para crear/editar una sección.

**Campos del formulario:**
1. Título (input text)
2. Parámetro de datos (select entre 6 opciones)
3. Dirección de orden (desc/asc)
4. Límite de resultados (select: 3, 5, 7, 10, 15, 20, 25, 50)
5. Tipo de gráfico (grid de 7 cards seleccionables)
6. Temporalidad (select: 7d, 14d, 30d, 60d, 90d, 6m, 1y)
7. Tamaño en grid (full/half/third)
8. Paleta de colores (6 predefinidas como chips visuales + opción custom)

**Preview en tiempo real:**
- A la derecha o abajo del formulario
- Renderiza el widget seleccionado con datos reales
- Se actualiza al cambiar cualquier campo

---

## 3. MODELO DE DATOS

### Estructura de una Sección (JSON en localStorage)
```javascript
{
  id: "sec_1713600000_abc123def",  // generado con Date.now() + random
  title: "Top 10 Productos por Ingreso",
  dataParameter: "revenue",       // revenue | volume | margin | margin_pct | cost | avg_price
  sortDirection: "desc",           // desc | asc
  limit: 10,                       // 0 = sin límite (para KPI usa 0)
  chartType: "horizontal_bar",     // horizontal_bar | vertical_bar | pie | donut | table | list | kpi_card
  temporality: 30,                 // días hacia atrás
  colorPalette: "vibrant",         // vibrant | ocean | sunset | forest | monochrome | royal | custom
  customColors: [],                // solo si colorPalette === 'custom'
  gridSpan: "full",                // full | half | third
  order: 0                         // posición en el dashboard (0 = primera)
}
```

### localStorage key: `rderico_sales_dashboard_v2`
Valor: JSON array de secciones.

### Secciones por defecto (primera vez que se abre)
```javascript
[
  { id: 'default-kpi-1', title: 'Ingreso Total Bruto', dataParameter: 'revenue', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'third', order: 0 },
  { id: 'default-kpi-2', title: 'Volumen Desplazado', dataParameter: 'volume', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'ocean', customColors: [], gridSpan: 'third', order: 1 },
  { id: 'default-kpi-3', title: 'Margen Promedio', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'forest', customColors: [], gridSpan: 'third', order: 2 },
  { id: 'default-top-rev', title: 'Top 10 Productos por Ingreso', dataParameter: 'revenue', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'full', order: 3 },
  { id: 'default-cats', title: 'Distribución por Categorías', dataParameter: 'revenue', sortDirection: 'desc', limit: 15, chartType: 'donut', temporality: 30, colorPalette: 'vibrant', customColors: [], gridSpan: 'half', order: 4 },
  { id: 'default-vol', title: 'Top 5 por Volumen', dataParameter: 'volume', sortDirection: 'desc', limit: 5, chartType: 'list', temporality: 30, colorPalette: 'ocean', customColors: [], gridSpan: 'half', order: 5 },
]
```

---

## 4. PALETAS DE COLORES

```javascript
const COLOR_PALETTES = {
  vibrant:    { name: 'Vibrante',      colors: ['#FBBF24','#10B981','#3B82F6','#8B5CF6','#F97316','#06B6D4','#EF4444','#EC4899','#14B8A6','#F59E0B'] },
  ocean:      { name: 'Océano',        colors: ['#0EA5E9','#06B6D4','#14B8A6','#10B981','#22D3EE','#67E8F9','#0284C7','#0369A1','#155E75','#164E63'] },
  sunset:     { name: 'Atardecer',     colors: ['#F97316','#EF4444','#F59E0B','#EC4899','#FB923C','#FBBF24','#F472B6','#E11D48','#D97706','#DC2626'] },
  forest:     { name: 'Bosque',        colors: ['#10B981','#059669','#34D399','#6EE7B7','#047857','#A7F3D0','#065F46','#14B8A6','#0D9488','#0F766E'] },
  monochrome: { name: 'Monocromático', colors: ['#1E293B','#334155','#475569','#64748B','#94A3B8','#CBD5E1','#E2E8F0','#0F172A','#1E293B','#334155'] },
  royal:      { name: 'Royal',         colors: ['#7C3AED','#6D28D9','#8B5CF6','#A78BFA','#C4B5FD','#4C1D95','#5B21B6','#DDD6FE','#EDE9FE','#581C87'] },
};
```

## 5. PARÁMETROS DE DATOS

```javascript
const DATA_PARAMETERS = [
  { id: 'revenue',    label: 'Ingresos Brutos',     icon: DollarSign, unit: '$',  isMoney: true },
  { id: 'volume',     label: 'Volumen (Unidades)',   icon: Package,    unit: 'u',  isMoney: false },
  { id: 'margin',     label: 'Margen Absoluto ($)',  icon: TrendingUp, unit: '$',  isMoney: true },
  { id: 'margin_pct', label: 'Margen (%)',           icon: Percent,    unit: '%',  isMoney: true },
  { id: 'cost',       label: 'Costo Acumulado',      icon: Target,     unit: '$',  isMoney: true },
  { id: 'avg_price',  label: 'Precio Promedio',      icon: Zap,        unit: '$',  isMoney: true },
];
```

### Cómo extraer el valor de un item del API según el parámetro:
```javascript
const getDataValue = (item, param) => {
  switch(param) {
    case 'revenue':    return item.total_revenue || 0;
    case 'volume':     return item.total_quantity || 0;
    case 'margin':     return item.margin_absolute || 0;
    case 'margin_pct': return item.margin_percentage || 0;
    case 'cost':       return item.total_revenue ? item.total_revenue * (1 - (item.margin_percentage || 0) / 100) : 0;
    case 'avg_price':  return item.total_quantity > 0 ? item.total_revenue / item.total_quantity : 0;
    default:           return 0;
  }
};
```

### Cómo formatear el valor para display:
```javascript
const formatValue = (value, param, showMonetary) => {
  const paramDef = DATA_PARAMETERS.find(p => p.id === param);
  if (paramDef?.isMoney && !showMonetary) return '•••';
  if (param === 'margin_pct') return `${value.toFixed(1)}%`;
  if (param === 'volume') return value.toLocaleString();
  return `$${value.toLocaleString(undefined, {minimumFractionDigits:0, maximumFractionDigits:0})}`;
};
```

## 6. TIPOS DE GRÁFICO Y CÓMO RENDERIZARLOS

```javascript
const CHART_TYPES = [
  { id: 'horizontal_bar', label: 'Barras Horizontales', icon: BarChart2,    desc: 'Ideal para rankings' },
  { id: 'vertical_bar',   label: 'Barras Verticales',   icon: BarChart,     desc: 'Comparativas' },
  { id: 'pie',            label: 'Circular',            icon: PieChartIcon, desc: 'Distribución %' },
  { id: 'donut',          label: 'Donut',               icon: PieChartIcon, desc: 'Distribución con centro' },
  { id: 'table',          label: 'Tabla',               icon: Table,        desc: 'Análisis detallado' },
  { id: 'list',           label: 'Lista',               icon: List,         desc: 'Rankings rápidos' },
  { id: 'kpi_card',       label: 'Tarjeta KPI',         icon: TrendingUp,   desc: 'Indicador grande' },
];
```

### 6.1 HorizontalBarWidget
Recibe: `{ data, colors, showMonetary, section }`
- `data` es array de items del API ya procesados (sorted + limited)
- Para cada item: fila con label izquierda, valor derecha, barra CSS debajo
- Ancho de barra = `(value / maxValue) * 100%`
- Color de barra = `colors[index % colors.length]`
- CSS: `transition-all duration-700` para animación de entrada
- Hover: la barra aumenta opacidad, muestra tooltip

### 6.2 VerticalBarWidget
- Contenedor flex horizontal con `items-end`
- Cada barra: div con height proporcional al valor, max-height del contenedor
- Label debajo truncado, valor arriba de la barra
- Hover tooltip

### 6.3 PieChartWidget
- Usar `conic-gradient` CSS
- Calcular ángulos acumulados para cada segmento
- Para pie/donut, los datos se agrupan por categoría si param=revenue
- Leyenda debajo con chips de color

### 6.4 DonutChartWidget
- Igual que pie pero con un div circular blanco superpuesto en el centro
- Centro muestra el total formateado

### 6.5 TableWidget
- Tabla HTML con columnas: #, Producto, Categoría, Valor Principal
- Headers clickeables para ordenar
- Filas con hover highlight zebra

### 6.6 ListWidget
- Lista numerada compacta
- Cada item: número rank grande + nombre + mini barra horizontal + valor

### 6.7 KPICardWidget
- Agrega todos los datos según el parámetro (sum para revenue/volume/cost, avg para margin_pct/avg_price)
- Muestra número grande centrado
- Mini visualización decorativa (3 barritas)
- Indicador de tendencia: divide los datos en 2 mitades, compara sumas → ↑ verde o ↓ rojo

---

## 7. PROCESAMIENTO DE DATOS POR SECCIÓN

```javascript
const processDataForSection = (allData, section) => {
  if (!allData?.length) return [];
  
  // KPI cards: retorna todo (la agregación la hace el widget)
  if (section.chartType === 'kpi_card') return allData;
  
  // Pie/Donut: agrupar por categoría
  if ((section.chartType === 'pie' || section.chartType === 'donut')) {
    const catMap = {};
    allData.forEach(item => {
      const cat = item.category_name || 'Sin Categoría';
      if (!catMap[cat]) catMap[cat] = { name: cat, value: 0 };
      catMap[cat].value += getDataValue(item, section.dataParameter);
    });
    return Object.values(catMap)
      .sort((a,b) => section.sortDirection === 'desc' ? b.value - a.value : a.value - b.value)
      .slice(0, section.limit || 15);
  }
  
  // Resto: sort + limit sobre items individuales
  const sorted = [...allData].sort((a, b) => {
    const va = getDataValue(a, section.dataParameter);
    const vb = getDataValue(b, section.dataParameter);
    return section.sortDirection === 'desc' ? vb - va : va - vb;
  });
  return section.limit > 0 ? sorted.slice(0, section.limit) : sorted;
};
```

---

## 8. PRESETS RÁPIDOS PARA EL GESTOR

```javascript
const QUICK_PRESETS = [
  { label: '🏆 Top 10 Ingresos',          config: { title: 'Top 10 Productos por Ingreso', dataParameter: 'revenue', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'vibrant', gridSpan: 'full' }},
  { label: '📦 Top 10 Volumen',           config: { title: 'Top 10 por Volumen', dataParameter: 'volume', sortDirection: 'desc', limit: 10, chartType: 'horizontal_bar', temporality: 30, colorPalette: 'ocean', gridSpan: 'full' }},
  { label: '🥧 Categorías (Donut)',       config: { title: 'Distribución por Categorías', dataParameter: 'revenue', sortDirection: 'desc', limit: 15, chartType: 'donut', temporality: 30, colorPalette: 'vibrant', gridSpan: 'half' }},
  { label: '📉 Bottom 5 Margen',          config: { title: 'Menor Margen', dataParameter: 'margin_pct', sortDirection: 'asc', limit: 5, chartType: 'list', temporality: 30, colorPalette: 'sunset', gridSpan: 'half' }},
  { label: '💰 Top 5 Margen',             config: { title: 'Más Rentables', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 5, chartType: 'vertical_bar', temporality: 30, colorPalette: 'forest', gridSpan: 'half' }},
  { label: '📊 Tabla Completa',           config: { title: 'Análisis Detallado', dataParameter: 'revenue', sortDirection: 'desc', limit: 50, chartType: 'table', temporality: 30, colorPalette: 'monochrome', gridSpan: 'full' }},
  { label: '⚡ KPI Ingreso',              config: { title: 'Ingreso Total', dataParameter: 'revenue', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'vibrant', gridSpan: 'third' }},
  { label: '📦 KPI Volumen',              config: { title: 'Volumen Total', dataParameter: 'volume', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'ocean', gridSpan: 'third' }},
  { label: '📈 KPI Margen',               config: { title: 'Margen Promedio', dataParameter: 'margin_pct', sortDirection: 'desc', limit: 0, chartType: 'kpi_card', temporality: 30, colorPalette: 'forest', gridSpan: 'third' }},
];
```

---

## 9. ESTRUCTURA DEL ARCHIVO FINAL

```
EstadisticasVentasUI.jsx (un solo archivo, ~1050 líneas)
│
├── IMPORTS (React, lucide-react icons)
│
├── CONSTANTES (~100 líneas)
│   ├── API_BASE, STORAGE_KEY
│   ├── COLOR_PALETTES (6 paletas)
│   ├── DATA_PARAMETERS (6 params)
│   ├── CHART_TYPES (7 tipos)
│   ├── TEMPORALITY_OPTIONS (7 opciones)
│   ├── QUICK_PRESETS (9 presets)
│   └── DEFAULT_SECTIONS (6 secciones iniciales)
│
├── UTILIDADES (~50 líneas)
│   ├── generateId()
│   ├── getColors(section)
│   ├── getDataValue(item, param)
│   ├── formatValue(value, param, showMonetary)
│   ├── processDataForSection(allData, section)
│   ├── loadSections()
│   └── saveSections(sections)
│
├── WIDGETS (~350 líneas)
│   ├── HorizontalBarWidget ({ data, colors, showMonetary, section })
│   ├── VerticalBarWidget ({ data, colors, showMonetary, section })
│   ├── PieChartWidget ({ data, colors, showMonetary, section })
│   ├── DonutChartWidget ({ data, colors, showMonetary, section })
│   ├── TableWidget ({ data, colors, showMonetary, section })
│   ├── ListWidget ({ data, colors, showMonetary, section })
│   ├── KPICardWidget ({ data, colors, showMonetary, section })
│   └── DashboardSection ({ section, allData, showMonetary, index })
│       → Wrapper que selecciona el widget correcto y agrega animación
│
├── SectionEditorModal ({ section, onSave, onClose, allData }) (~200 líneas)
│   ├── Estado local para cada campo del formulario
│   ├── Grid: formulario izquierda + preview derecha
│   ├── Preview renderiza DashboardSection con la config actual
│   └── Glassmorphism: bg-white/95 backdrop-blur-xl
│
├── DashboardView ({ sections, allDataCache, showMonetary, ... }) (~120 líneas)
│   ├── Header con título + botón gestionar + toggle monetario
│   ├── Grid de secciones con col-span según gridSpan
│   ├── Empty state si sections.length === 0
│   └── Loading state con spinner
│
├── ManagerView ({ sections, setSections, onBack, allData }) (~150 líneas)
│   ├── Header con botón volver
│   ├── Presets rápidos (fila de chips)
│   ├── Lista de secciones con acciones CRUD
│   ├── Botón agregar sección personalizada
│   └── Abre SectionEditorModal al editar/crear
│
├── EstadisticasVentasUI ({ userPermissions }) (~60 líneas) ← EXPORT
│   ├── Estado: activeView, sections, showMonetary, dataCache, isLoading
│   ├── useEffect: fetch datos del API
│   ├── Renderiza DashboardView o ManagerView según activeView
│   └── Pasa callbacks para navegar entre vistas
│
└── <style> CSS (~30 líneas)
    ├── @keyframes fadeInUp
    ├── @keyframes pulse-subtle  
    ├── .dashboard-section-enter (animation: fadeInUp)
    └── custom-scrollbar-light
```

---

## 10. IMPORTS NECESARIOS

```javascript
import React, { useState, useEffect, useMemo } from 'react';
import {
  Activity, BarChart2, BarChart, PieChart as PieChartIcon,
  Lock, Eye, EyeOff, Settings, Plus, Trash2, Edit3, Copy,
  ChevronUp, ChevronDown, ArrowLeft, TrendingUp, TrendingDown,
  List, Table, Layers, Palette, Clock, Hash,
  Zap, Target, DollarSign, Package, Percent, X, Check,
  LayoutDashboard, Sparkles
} from 'lucide-react';
```

---

## 11. ELEMENTOS PREMIUM A INCLUIR

1. **Animaciones escalonadas**: Cada sección en el dashboard aparece con `animation: fadeInUp 0.5s ease-out` y `animation-delay: ${index * 100}ms`
2. **Preview en tiempo real**: El SectionEditorModal renderiza un DashboardSection miniatura que se actualiza al cambiar cualquier campo
3. **Tooltips**: En widgets de barras, hover muestra un div absolute con el valor exacto
4. **Empty state con personalidad**: Gradiente animado, icono pulsante, CTA prominente
5. **Tendencias en KPI**: Divide datos en 2 mitades, compara → muestra flecha ↑↓ con color
6. **Glassmorphism en modal**: `className="bg-white/95 backdrop-blur-xl border border-white/30 shadow-2xl"`
7. **Presets rápidos**: Chips clickeables que agregan secciones pre-configuradas con un click

---

## 12. CSS ANIMATIONS REQUERIDAS

```css
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes pulse-subtle {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.05); }
}
@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
.dashboard-section-enter {
  animation: fadeInUp 0.5s ease-out both;
}
```

---

## 13. FASES DE EJECUCIÓN

### FASE 1: Escribir desde imports hasta fin de utilidades
- Imports, constantes, funciones utilitarias, load/save
- ~150 líneas

### FASE 2: Escribir todos los widgets
- 7 widgets + DashboardSection wrapper
- ~350 líneas

### FASE 3: Escribir DashboardView
- Header, grid, empty state, loading
- ~120 líneas

### FASE 4: Escribir SectionEditorModal
- Formulario completo con preview
- ~200 líneas

### FASE 5: Escribir ManagerView
- CRUD, presets, lista de secciones
- ~150 líneas

### FASE 6: Escribir componente principal + CSS
- EstadisticasVentasUI export, estados, fetch, routing
- ~80 líneas

### ESTRATEGIA DE ESCRITURA:
Dado que el archivo es grande (~1050 líneas), escribirlo en 2 o 3 llamadas:
1. Primera llamada: write_to_file con FASE 1 + FASE 2 + FASE 3 (primeras ~620 líneas)
2. Segunda llamada: replace_file_content para agregar FASE 4 + FASE 5 + FASE 6 (restantes ~430 líneas)

O si el token lo permite, escribir todo de una sola vez.

---

## 14. VERIFICACIÓN

1. Ejecutar `npm run build` en `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO` → debe compilar sin errores
2. Abrir en navegador y navegar al módulo "Estadísticas de Ventas"
3. Debe mostrar el dashboard con las 6 secciones por defecto
4. El botón "Gestionar Dashboard de Ventas" debe llevar al gestor
5. Agregar, editar, eliminar secciones debe funcionar
6. Recargar página → la configuración debe persistir
7. Toggle de cifras monetarias debe ocultar/mostrar valores $

---

## 15. NOTAS IMPORTANTES

- NO modificar ExperimentCenterUI.jsx — la interfaz de export se mantiene igual
- NO instalar dependencias nuevas — todo con lo que ya hay
- NO cambiar el backend — todo es frontend
- El componente debe seguir exportándose como `export const EstadisticasVentasUI`
- Mantener la prop `userPermissions` con la misma lógica de permisos
