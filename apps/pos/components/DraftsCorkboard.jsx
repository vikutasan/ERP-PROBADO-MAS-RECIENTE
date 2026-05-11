import React, { useState } from 'react';

/**
 * R DE RICO - PIZARRÓN DE BORRADORES
 * 
 * Interfaz estilo corcho para gestionar tickets en estado DRAFT.
 */

export const DraftsCorkboard = ({ drafts, onLoadDraft, onDiscardDraft, onClose, onBackToMain }) => {
    const [draftToDelete, setDraftToDelete] = useState(null);

    // Ordenar por fecha de creación (de más reciente a más antiguo)
    const sortedDrafts = [...drafts].sort((a, b) => {
        return new Date(b.created_at) - new Date(a.created_at);
    });

    const getRandomRotation = (index) => {
        const rotations = ['-rotate-1', 'rotate-1', '-rotate-2', 'rotate-2', '-rotate-3', 'rotate-3'];
        return rotations[index % rotations.length];
    };

    const getPostItColor = (terminal) => {
        const colors = {
            'T6': 'bg-yellow-100',
            'T5': 'bg-blue-100',
            'T4': 'bg-green-100',
            'T3': 'bg-pink-100',
            'T2': 'bg-purple-100',
            'CAJA': 'bg-orange-100'
        };
        return colors[terminal] || 'bg-gray-100';
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-10 animate-in fade-in duration-500">
            {/* Backdrop con desenfoque profundo */}
            <div className="absolute inset-0 bg-black/70 backdrop-blur-xl" onClick={onClose} />

            {/* El Pizarrón de Corcho Alterno (Color más oscuro para distinguirlo) */}
            <div className="relative w-full max-w-6xl aspect-[16/9] rounded-[40px] shadow-[0_50px_100px_-20px_rgba(0,0,0,0.5)] border-[20px] border-[#2a3b4c] overflow-hidden flex flex-col">

                {/* Textura de Corcho Alterno (Azulado/Grisáceo) */}
                <div className="absolute inset-0 opacity-90" style={{
                    backgroundColor: '#4a6078',
                    backgroundImage: `
                        radial-gradient(circle at 2px 2px, rgba(0,0,0,0.2) 1px, transparent 0),
                        radial-gradient(circle at 10px 10px, rgba(255,255,255,0.05) 1px, transparent 0)
                    `,
                    backgroundSize: '15px 15px, 40px 40px'
                }} />

                {/* Encabezado del Pizarrón */}
                <div className="relative z-10 p-8 border-b border-black/20 flex justify-between items-center bg-black/10">
                    <div>
                        <h2 className="text-4xl font-black uppercase tracking-tighter italic text-white text-shadow-sm">Cuentas en <span className="opacity-60 text-amber-300">Borrador</span></h2>
                        <p className="text-[10px] font-black uppercase tracking-[0.3em] text-gray-300">Pizarrón Alterno de Recuperación</p>
                    </div>
                    <div className="flex gap-4">
                        <button
                            onClick={onBackToMain}
                            className="h-12 px-6 rounded-full bg-white text-[#2a3b4c] flex items-center justify-center font-black hover:scale-105 active:scale-95 transition-all shadow-xl uppercase tracking-wider text-sm border-2 border-transparent"
                        >
                            ← Volver a Cuentas
                        </button>
                        <button
                            onClick={onClose}
                            className="w-12 h-12 rounded-full bg-[#2a3b4c] text-white border-2 border-white/20 flex items-center justify-center font-black hover:scale-110 active:scale-95 transition-all shadow-xl"
                        >
                            ✕
                        </button>
                    </div>
                </div>

                {/* Grid de Post-its */}
                <div className="relative z-10 flex-1 p-12 overflow-y-auto custom-scrollbar grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-12 content-start">
                    {sortedDrafts.map((draft, index) => (
                        <div
                            key={draft.id}
                            className={`group relative p-5 aspect-square ${getPostItColor(draft.terminal_id)} ${getRandomRotation(index)} shadow-[5px_15px_30px_-5px_rgba(0,0,0,0.4)] hover:shadow-[10px_25px_50px_-10px_rgba(0,0,0,0.5)] transition-all flex flex-col justify-between`}
                        >
                            {/* Alfiler (Pin) amarillo para borradores */}
                            <div className="absolute -top-3 left-1/2 -translate-x-1/2 w-4 h-4 rounded-full bg-amber-400 shadow-inner border border-amber-600 z-20">
                                <div className="absolute top-1 left-1 w-1.5 h-1.5 bg-white/60 rounded-full" />
                            </div>

                            {/* Botón de descartar integrado (arriba derecha) */}
                            <button 
                                onClick={(e) => { 
                                    e.stopPropagation(); 
                                    setDraftToDelete(draft);
                                }}
                                className="absolute top-3 right-3 w-6 h-6 flex items-center justify-center rounded-full text-black/20 hover:text-red-600 hover:bg-red-500/10 font-black text-sm hover:scale-110 active:scale-95 transition-all z-30"
                                title="Descartar Borrador"
                            >
                                ✕
                            </button>

                            {/* Contenido del Post-it */}
                            <div className="text-gray-800 flex flex-col flex-1 pt-1">
                                <div className="flex justify-between items-start mb-2">
                                    <span className="text-sm font-black bg-black/10 px-2 py-1 rounded text-black uppercase tracking-widest">📝 BORRADOR</span>
                                    <span className="text-sm font-black bg-white/60 px-2 py-1 rounded-md uppercase tracking-widest">{draft.terminal_id}</span>
                                </div>
                                
                                <div className="space-y-1 mt-2 flex-1">
                                    <p className="text-xs font-black uppercase flex items-center gap-2 text-black">
                                        👤 {draft.captured_by_name || 'DESCONOCIDO'}
                                    </p>
                                    <p className="text-xs font-bold uppercase flex items-center gap-2 text-red-700">
                                        🕐 {new Date(draft.created_at + (draft.created_at.includes('Z') ? '' : 'Z')).toLocaleDateString('es-MX', { day: '2-digit', month: 'short' })} - {new Date(draft.created_at + (draft.created_at.includes('Z') ? '' : 'Z')).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}
                                    </p>
                                    
                                    {draft.items && draft.items.length > 0 && (
                                        <div className="mt-3 text-[10px] text-gray-700 leading-tight">
                                            {draft.items.slice(0, 3).map((item, i) => (
                                                <p key={i} className="truncate">• {item.quantity}x {item.product?.name}</p>
                                            ))}
                                            {draft.items.length > 3 && (
                                                <p className="italic opacity-60">...y {draft.items.length - 3} más</p>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </div>

                            <div className="mt-3 pt-3 border-t border-black/10 flex justify-between items-end relative z-20">
                                <span className="text-lg font-black font-mono tracking-tighter text-black opacity-60">${draft.total?.toFixed(2)}</span>
                                <button 
                                    onClick={(e) => { e.stopPropagation(); onLoadDraft(draft); }}
                                    className="w-9 h-9 bg-black/80 text-white rounded-full flex items-center justify-center shadow-[2px_4px_10px_rgba(0,0,0,0.2)] hover:bg-[#c1d72e] hover:text-black hover:scale-110 active:scale-95 transition-all group/btn"
                                    title="Cargar Borrador"
                                >
                                    <span className="text-xl font-black leading-none -mt-1 transform group-hover/btn:rotate-180 transition-transform duration-500">↻</span>
                                </button>
                            </div>

                            {/* Efecto de sombra para el papel */}
                            <div className="absolute bottom-0 right-0 w-8 h-8 bg-gradient-to-br from-black/0 to-black/10 rounded-br-sm pointer-events-none" />
                        </div>
                    ))}

                    {sortedDrafts.length === 0 && (
                        <div className="col-span-full h-full flex flex-col items-center justify-center opacity-30 space-y-4 py-20 text-white">
                            <span className="text-9xl italic font-black">VACÍO</span>
                            <p className="text-sm font-black uppercase tracking-[0.5em]">No hay borradores pendientes</p>
                        </div>
                    )}
                </div>
            </div>

            {/* Modal de Confirmación de Borrado */}
            {draftToDelete && (
                <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 animate-in fade-in duration-200">
                    <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={() => setDraftToDelete(null)} />
                    <div className="relative bg-[#1a1a1a] border border-red-500/30 p-8 rounded-[30px] shadow-[0_0_100px_rgba(239,68,68,0.2)] max-w-md w-full animate-in zoom-in-95 duration-200 text-center">
                        <div className="w-16 h-16 mx-auto bg-red-500/10 rounded-full flex items-center justify-center mb-4">
                            <span className="text-3xl">🗑️</span>
                        </div>
                        <h3 className="text-2xl font-black uppercase tracking-tighter text-white mb-2">¿Descartar Borrador?</h3>
                        <p className="text-sm text-gray-400 font-bold uppercase tracking-widest mb-6">
                            Esta acción es irreversible y eliminará este borrador de forma permanente
                        </p>
                        
                        <div className="flex gap-4 w-full">
                            <button 
                                onClick={() => setDraftToDelete(null)}
                                className="flex-1 py-4 bg-white/5 hover:bg-white/10 text-white rounded-2xl font-black uppercase tracking-widest text-xs transition-all border border-white/10"
                            >
                                Cancelar
                            </button>
                            <button 
                                onClick={() => {
                                    onDiscardDraft(draftToDelete);
                                    setDraftToDelete(null);
                                }}
                                className="flex-1 py-4 bg-red-600 hover:bg-red-500 text-white rounded-2xl font-black uppercase tracking-widest text-xs transition-all shadow-[0_0_20px_rgba(220,38,38,0.4)]"
                            >
                                Sí, Eliminar
                            </button>
                        </div>
                    </div>
                </div>
            )}

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 6px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: rgba(0,0,0,0.1); }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.4); }
                .text-shadow-sm { text-shadow: 1px 1px 2px rgba(0,0,0,0.5); }
            `}</style>
        </div>
    );
};
