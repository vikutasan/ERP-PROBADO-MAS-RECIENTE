import React, { useState } from 'react';
import { GrandezaParamsUI } from './GrandezaParamsUI';
import { GrandezaDailyUI } from './GrandezaDailyUI';
import { GrandezaDriverUI } from './GrandezaDriverUI';

/**
 * REPARTO PAN GRANDEZA — Landing Page
 * Módulo del ERP R de Rico para gestión de repartos de Pan Grandeza.
 * 
 * 3 sub-suites controladas por permisos:
 * - Parámetros Generales (Supervisor) — grandeza_params
 * - Gestión Diaria (Gerente) — grandeza_daily
 * - Herramienta Repartidor (Repartidor) — grandeza_driver
 */
export const RepartoPanGrandezaUI = ({ onBack, userPermissions = {} }) => {
    const [activeSuite, setActiveSuite] = useState(null);
    const LOGO_URL = `http://${window.location.hostname}:5001/static/images/grandeza/logo.png`;

    // Helper: verificar permiso (Master Access o permiso específico)
    const hasPermission = (permId) => {
        return userPermissions.all === 'full' || userPermissions[permId] === 'full';
    };

    // Definición de las 3 sub-suites
    const suites = [
        {
            id: 'params',
            permissionId: 'grandeza_params',
            icon: '📋',
            title: 'Establecer Parámetros Generales',
            subtitle: 'Reparto Pan Grandeza',
            description: 'Productos, clientes, rutas por día, estadísticas',
            color: 'from-blue-500 to-indigo-700',
            shadow: 'shadow-blue-500/20',
            accent: 'text-blue-400',
        },
        {
            id: 'daily',
            permissionId: 'grandeza_daily',
            icon: '📅',
            title: 'Gestión Diaria',
            subtitle: 'Reparto Pan Grandeza',
            description: 'Inventario inicial, entregas, cierre de jornada, rastreo',
            color: 'from-emerald-500 to-green-700',
            shadow: 'shadow-emerald-500/20',
            accent: 'text-emerald-400',
        },
        {
            id: 'driver',
            permissionId: 'grandeza_driver',
            icon: '🚗',
            title: 'Herramienta Repartidor',
            subtitle: 'Pan Grandeza',
            description: 'Captura de ventas en ruta, cobros, incidentes, pedidos',
            color: 'from-amber-500 to-orange-700',
            shadow: 'shadow-amber-500/20',
            accent: 'text-amber-400',
        },
    ];

    // Si hay una suite activa, renderizarla
    if (activeSuite) {
        if (activeSuite === 'params') {
            return <GrandezaParamsUI onBack={() => setActiveSuite(null)} />;
        }
        if (activeSuite === 'daily') {
            return <GrandezaDailyUI onBack={() => setActiveSuite(null)} />;
        }
        if (activeSuite === 'driver') {
            return <GrandezaDriverUI onBack={() => setActiveSuite(null)} userPermissions={userPermissions} />;
        }
        
        // Placeholder para la suite del repartidor (Fase 3)
        const suite = suites.find(s => s.id === activeSuite);
        return (
            <div className="h-full flex flex-col bg-gradient-to-br from-[#0a0a0a] via-[#111] to-[#0a0a0a] text-white overflow-hidden">
                {/* Header de sub-suite */}
                <div className="p-8 pb-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-6">
                            <div className={`w-16 h-16 bg-gradient-to-br ${suite.color} rounded-3xl flex items-center justify-center text-3xl shadow-2xl ${suite.shadow}`}>
                                {suite.icon}
                            </div>
                            <div>
                                <h1 className="text-3xl font-black uppercase tracking-tighter text-white leading-none">
                                    {suite.title}
                                </h1>
                                <p className={`text-sm font-bold uppercase tracking-widest mt-1 ${suite.accent}`}>
                                    {suite.subtitle}
                                </p>
                            </div>
                        </div>
                        <button
                            onClick={() => setActiveSuite(null)}
                            className="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-400 hover:text-white hover:bg-white/10 transition-all"
                        >
                            ← Volver al Módulo
                        </button>
                    </div>
                </div>

                {/* Contenido de la sub-suite — Placeholder (se llena en fases 1-5) */}
                <div className="flex-1 flex items-center justify-center p-8">
                    <div className="text-center space-y-6">
                        <div className="text-7xl">{suite.icon}</div>
                        <h2 className={`text-2xl font-black uppercase tracking-tighter ${suite.accent}`}>
                            {suite.title}
                        </h2>
                        <p className="text-gray-500 text-base font-medium max-w-md mx-auto">
                            Suite en preparación. La infraestructura de datos ya está lista.
                        </p>
                        <div className="flex items-center justify-center gap-2 mt-4">
                            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></div>
                            <span className="text-xs font-bold text-emerald-500/60 uppercase tracking-widest">Backend Conectado</span>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    // Landing Page — 3 botones
    return (
        <div className="h-full flex flex-col text-white overflow-hidden relative" style={{ backgroundColor: '#3a2e1e' }}>
            {/* Header */}
            <div className="relative z-10 p-8 pb-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-6">
                        <div className="w-16 h-16 rounded-3xl overflow-hidden shadow-2xl shadow-orange-500/20 border border-amber-500/30">
                            <img src={LOGO_URL} alt="Grandeza" className="w-full h-full object-cover" />
                        </div>
                        <div>
                            <h1 className="text-4xl font-black uppercase tracking-tighter text-white leading-none">
                                Reparto <span className="text-amber-400">Pan Grandeza</span>
                            </h1>
                            <p className="text-sm font-bold text-gray-500 uppercase tracking-widest mt-1">
                                Sistema de Gestión de Repartos
                            </p>
                        </div>
                    </div>
                    {onBack && (
                        <button
                            onClick={onBack}
                            className="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-400 hover:text-white hover:bg-white/10 transition-all"
                        >
                            ← Volver
                        </button>
                    )}
                </div>
            </div>

            {/* 3 Botones de Acceso */}
            <div className="relative z-10 flex-1 flex items-center justify-center p-8">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl w-full">
                    {suites.map(suite => {
                        const permitted = hasPermission(suite.permissionId);
                        return (
                            <button
                                key={suite.id}
                                onClick={() => permitted && setActiveSuite(suite.id)}
                                disabled={!permitted}
                                className={`group relative p-8 rounded-[32px] border-2 transition-all duration-500 text-left flex flex-col items-center
                                    ${permitted 
                                        ? 'bg-[#2a2016]/80 border-[#5a4530] hover:border-amber-600/60 hover:bg-[#352a1c]/90 hover:scale-[1.02] active:scale-[0.98] cursor-pointer backdrop-blur-sm' 
                                        : 'bg-[#1a1510]/40 border-[#3a2e22] opacity-30 cursor-not-allowed'
                                    }`}
                            >
                                {/* Icono */}
                                <div className={`w-20 h-20 rounded-3xl overflow-hidden shadow-2xl ${suite.shadow} mb-6 border border-white/10
                                    ${permitted ? 'group-hover:scale-110 group-hover:rotate-3' : ''} transition-all duration-500`}>
                                    <img src={LOGO_URL} alt="Grandeza" className="w-full h-full object-cover" />
                                </div>

                                {/* Texto */}
                                <h3 className="text-lg font-black uppercase tracking-tight text-white text-center leading-tight mb-1">
                                    {suite.title}
                                </h3>
                                <p className={`text-xs font-bold uppercase tracking-widest mb-4 ${suite.accent}`}>
                                    {suite.subtitle}
                                </p>
                                <p className="text-xs text-gray-500 font-medium text-center leading-relaxed">
                                    {suite.description}
                                </p>

                                {/* Badge de estado */}
                                {!permitted && (
                                    <div className="absolute top-4 right-4 px-3 py-1 bg-red-500/10 border border-red-500/20 rounded-full">
                                        <span className="text-[9px] font-black text-red-400 uppercase tracking-widest">Sin Acceso</span>
                                    </div>
                                )}
                            </button>
                        );
                    })}
                </div>
            </div>

            <style>{`
                @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
                @keyframes zoom-in-95 { from { transform: scale(0.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }
            `}</style>

            {/* Capa de textura yute (CSS puro) */}
            <div className="absolute inset-0 z-0 pointer-events-none" style={{
                backgroundImage: `
                    url("data:image/svg+xml,%3Csvg width='40' height='40' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' stroke='%23000' stroke-width='0.3' opacity='0.15'%3E%3Cpath d='M0 0h40M0 2h40M0 4h40M0 6h40M0 8h40M0 10h40M0 12h40M0 14h40M0 16h40M0 18h40M0 20h40M0 22h40M0 24h40M0 26h40M0 28h40M0 30h40M0 32h40M0 34h40M0 36h40M0 38h40'/%3E%3Cpath d='M0 0v40M2 0v40M4 0v40M6 0v40M8 0v40M10 0v40M12 0v40M14 0v40M16 0v40M18 0v40M20 0v40M22 0v40M24 0v40M26 0v40M28 0v40M30 0v40M32 0v40M34 0v40M36 0v40M38 0v40'/%3E%3C/g%3E%3C/svg%3E"),
                    url("data:image/svg+xml,%3Csvg width='6' height='6' xmlns='http://www.w3.org/2000/svg'%3E%3Crect width='6' height='6' fill='none'/%3E%3Crect x='0' y='0' width='1' height='1' fill='%23ffffff' opacity='0.03'/%3E%3Crect x='3' y='3' width='1' height='1' fill='%23000000' opacity='0.05'/%3E%3C/svg%3E")
                `,
                backgroundSize: '40px 40px, 6px 6px',
            }} />
            {/* Capa de gradiente cálido */}
            <div className="absolute inset-0 z-0 pointer-events-none" style={{
                background: 'radial-gradient(ellipse at 30% 20%, rgba(139,109,63,0.25) 0%, transparent 60%), radial-gradient(ellipse at 70% 80%, rgba(101,67,33,0.2) 0%, transparent 60%), linear-gradient(180deg, rgba(58,46,30,0.3) 0%, rgba(42,32,22,0.5) 100%)'
            }} />
        </div>
    );
};
