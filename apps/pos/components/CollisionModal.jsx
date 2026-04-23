import React from 'react';

export const CollisionModal = ({ onClose }) => {
    return (
        <div className="fixed inset-0 bg-black/95 backdrop-blur-xl flex items-center justify-center z-[200] animate-in fade-in zoom-in duration-500">
            <div className="bg-gray-950 border border-yellow-500/50 p-10 rounded-[40px] shadow-[0_0_100px_rgba(234,179,8,0.2)] max-w-lg w-full text-center relative overflow-hidden">
                <div className="absolute -top-40 -left-40 w-80 h-80 bg-yellow-600/10 blur-[100px] rounded-full"></div>
                <div className="text-8xl mb-4 relative z-10 animate-bounce">⚠️</div>
                <h2 className="text-2xl font-black uppercase text-yellow-500 mb-4 relative z-10 tracking-tighter">CONFLICTO DE VERSIÓN</h2>
                
                <div className="text-sm font-bold text-gray-300 mb-8 relative z-10 leading-relaxed text-left space-y-4 bg-black/40 p-6 rounded-3xl border border-white/5">
                    <p>
                        <span className="text-white">Otro usuario modificó esta cuenta mientras usted trabajaba.</span>
                    </p>
                    <p className="text-xs font-normal text-gray-400">
                        Esto ocurre cuando dos estaciones intentan guardar la misma cuenta al mismo tiempo. 
                        El sistema ha bloqueado su guardado para proteger los datos y evitar sobreescribir el trabajo de su compañero.
                    </p>
                    <div className="bg-yellow-500/10 border border-yellow-500/20 p-4 rounded-2xl">
                        <p className="text-yellow-400 font-black text-xs uppercase mb-1">¿Qué debe hacer?</p>
                        <ol className="list-decimal list-inside text-xs font-medium space-y-1 text-yellow-200/80">
                            <li>Cierre este aviso.</li>
                            <li>Vaya al <span className="text-white font-bold">Pizarrón</span>.</li>
                            <li>Vuelva a abrir esta cuenta para descargar los datos combinados.</li>
                        </ol>
                    </div>
                </div>

                <div className="flex justify-center relative z-10">
                    <button 
                        onClick={onClose}
                        className="w-full py-4 rounded-2xl bg-yellow-600 hover:bg-yellow-500 border border-yellow-500/50 font-black uppercase text-xs tracking-[0.2em] text-black transition-all shadow-[0_10px_40px_rgba(234,179,8,0.3)]"
                    >
                        ENTENDIDO
                    </button>
                </div>
            </div>
        </div>
    );
};
