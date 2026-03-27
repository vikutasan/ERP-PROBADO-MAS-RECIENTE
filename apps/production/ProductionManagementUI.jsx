import React, { useState } from 'react';
import { ChefHat, ArrowRight } from 'lucide-react';
import { DoughManagerUI } from './DoughManagerUI';

/**
 * GESTOR DE PRODUCCIÓN
 * 
 * Ventana principal. 
 * Diseño: Título Superior (más alto) + Botón Compacto.
 */

export const ProductionManagementUI = () => {
    const [view, setView] = useState('dashboard'); // 'dashboard' o 'dough-manager'

    if (view === 'dough-manager') {
        return <DoughManagerUI onBack={() => setView('dashboard')} />;
    }

    return (
        <div 
            style={{ 
                backgroundColor: '#b2b2b2',
                backgroundImage: 'radial-gradient(circle at center, #d1d1d1 0%, #b2b2b2 100%)'
            }}
            className="flex-1 flex flex-col h-full animate-in fade-in duration-700 overflow-hidden relative"
        >
            {/* Capa de Grano Industrial Sutil (Acabado Metálico/Piedra) */}
            <div className="absolute inset-0 opacity-[0.05] pointer-events-none' bg-[url('https://www.transparenttextures.com/patterns/pinstriped-suit.png')]" />

            <div className="flex-1 flex flex-col h-full bg-black/10 backdrop-blur-md relative z-10 p-8 pt-6">
            
            {/* Cabecera Cristal (Light Industrial Style - FLAT) */}
            <div className="relative z-20 flex items-center justify-between p-8 border-b border-black/10 bg-white/75 backdrop-blur-3xl shadow-sm -mx-8 -mt-8 mb-12">
                <div>
                    <h1 className="text-4xl font-black italic uppercase tracking-tighter text-black leading-none">
                        GESTOR DE <span className="text-orange-500">PRODUCCIÓN</span>
                    </h1>
                    <p className="text-[10px] font-bold text-black/40 uppercase tracking-[0.5em] mt-1">
                        Control Maestro • R de Rico
                    </p>
                </div>
            </div>

            <div className="flex-1 overflow-auto custom-scrollbar relative z-10">

            {/* Acciones Principales (Compactas para expansión futura) */}
            <div className="max-w-lg space-y-3">
                <button 
                    onClick={() => setView('dough-manager')}
                    className="w-full group relative flex items-center justify-between bg-white/5 border border-white/10 p-5 rounded-3xl hover:bg-[#c1d72e] hover:border-[#c1d72e] transition-all duration-500 text-left overflow-hidden shadow-xl"
                >
                    <div className="flex items-center gap-5">
                        <div className="w-12 h-12 bg-white/5 rounded-2xl flex items-center justify-center text-orange-500 group-hover:text-black group-hover:bg-black/10 transition-all duration-500">
                            <ChefHat size={24} />
                        </div>
                        <div>
                            <h2 className="text-xl font-black text-white italic uppercase tracking-tight group-hover:text-black transition-colors">
                                GESTOR DE MASAS
                            </h2>
                            <p className="text-[8px] text-gray-400 font-bold uppercase tracking-[0.2em] mt-0.5 group-hover:text-black/60 transition-colors">
                                Configuración ADN Principal
                            </p>
                        </div>
                    </div>

                    <div className="w-9 h-9 rounded-full border border-white/10 flex items-center justify-center text-white group-hover:bg-black group-hover:text-[#c1d72e] group-hover:border-transparent transition-all duration-500">
                        <ArrowRight size={16} />
                    </div>
                </button>

                {/* Futuros botones irán aquí */}
                
                <p className="text-[8px] font-black text-gray-600 uppercase tracking-[0.4em] pl-6 pt-2">
                    ONLINE • PLANTA TOLUCA
                </p>
            </div>
            </div>
            </div>
        </div>
    );
};
