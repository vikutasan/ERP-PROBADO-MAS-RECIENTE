import React from 'react';
import { GestionPersonal } from '../pos/components/GestionPersonal';

export const SeguridadAccesoUI = () => {
    return (
        <div className="flex flex-col h-full bg-[#050505] text-white overflow-hidden p-10">
            {/* Header de la Pantalla */}
            <header className="mb-12">
                <h1 className="text-7xl font-black uppercase italic tracking-tighter text-white leading-none">
                    Seguridad y <span className="text-[#c1d72e]">Acceso</span>
                </h1>
                <p className="text-[12px] font-black text-white/20 uppercase tracking-[0.5em] mt-4">
                    Centro de Control Imperial · Gestión de Credenciales y Perfiles
                </p>
            </header>

            {/* Contenido Modular por Secciones */}
            <div className="flex-1 overflow-y-auto pr-4 custom-scrollbar">
                <div className="max-w-5xl space-y-20 pb-20">
                    
                    {/* Sección 1: Gestión de Claves de Acceso (Legacy POS) */}
                    <section className="animate-in fade-in slide-in-from-bottom-10 duration-700">
                        <div className="relative group">
                            <div className="absolute -inset-1 bg-orange-500/5 blur-2xl rounded-[60px] opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none"></div>
                            <GestionPersonal isSection={true} onClose={() => {}} />
                        </div>
                    </section>

                    {/* Más secciones podrán ser añadidas aquí en el futuro */}
                    
                </div>
            </div>

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 6px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: #333; border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #c1d72e; }
            `}</style>
        </div>
    );
};
