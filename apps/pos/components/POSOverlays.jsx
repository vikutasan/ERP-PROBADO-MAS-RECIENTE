import React from 'react';

/**
 * POSOverlays — Componentes de UI overlay extraídos de RetailVisionPOS.jsx
 * 
 * Contiene:
 * - ForceLogoutModal: Modal de auto-expulsión por polling remoto
 * - OfflineBanner: Banner persistente de operaciones pendientes (v5.1)
 * - ToastNotification: Toast de confirmación no-bloqueante
 * 
 * REGLA: Solo presentación. Cero lógica de negocio.
 */

/** Modal de Auto-Expulsión (Polling Remoto) */
export const ForceLogoutModal = ({ visible, onForceLogout }) => {
    if (!visible) return null;

    return (
        <div className="fixed inset-0 bg-black/95 backdrop-blur-xl flex items-center justify-center z-[200] animate-in fade-in zoom-in duration-500">
            <div className="bg-gray-950 border border-red-500/30 p-12 rounded-[50px] shadow-[0_0_100px_rgba(255,0,0,0.3)] max-w-md w-full text-center relative overflow-hidden">
                <div className="absolute -top-40 -left-40 w-80 h-80 bg-red-600/20 blur-[100px] rounded-full"></div>
                <div className="text-8xl mb-6 relative z-10 animate-pulse">🚨</div>
                <h2 className="text-3xl font-black uppercase text-red-500 mb-4 relative z-10 tracking-tighter">SESIÓN TERMINADA</h2>
                <p className="text-sm font-bold text-gray-300 mb-10 relative z-10 leading-relaxed">
                    Un Administrador ha forzado la liberación total de tu terminal.<br/><br/>
                    <span className="text-red-400">Has sido desconectado por seguridad.</span>
                </p>
                <div className="flex justify-center relative z-10">
                    <button 
                        onClick={() => {
                            if (onForceLogout) onForceLogout();
                            else window.location.reload();
                        }}
                        className="w-full py-5 rounded-3xl bg-red-600 hover:bg-red-500 border border-red-500/50 font-black uppercase text-xs tracking-[0.2em] text-white transition-all shadow-[0_10px_40px_rgba(220,38,38,0.4)]"
                    >
                        SALIR AL LOGIN
                    </button>
                </div>
            </div>
        </div>
    );
};

/** v5.1 OFFLINE RESILIENCY: Banner persistente de operaciones pendientes */
export const OfflineBanner = ({ pendingCount, isSyncing }) => {
    if (pendingCount <= 0) return null;

    return (
        <div className="fixed top-0 left-0 right-0 z-[250] animate-in slide-in-from-top-2 fade-in duration-300">
            <div className={`w-full py-2 px-6 text-center font-black text-xs uppercase tracking-widest flex items-center justify-center gap-3 ${
                pendingCount >= 3
                    ? 'bg-red-600/95 text-white'
                    : 'bg-amber-500/95 text-black'
            }`}>
                {isSyncing ? (
                    <>
                        <span className="animate-spin">🔄</span>
                        SINCRONIZANDO {pendingCount} OPERACIÓN{pendingCount > 1 ? 'ES' : ''} PENDIENTE{pendingCount > 1 ? 'S' : ''}...
                    </>
                ) : (
                    <>
                        ⚠️ MODO OFFLINE — {pendingCount} OPERACIÓN{pendingCount > 1 ? 'ES' : ''} PENDIENTE{pendingCount > 1 ? 'S' : ''} DE SINCRONIZACIÓN
                    </>
                )}
            </div>
        </div>
    );
};

/** Toast de confirmación no-bloqueante */
export const ToastNotification = ({ message }) => {
    if (!message) return null;

    return (
        <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-[300] animate-in slide-in-from-bottom-4 fade-in duration-500">
            <div className="bg-[#c1d72e] text-black px-10 py-4 rounded-2xl shadow-[0_20px_60px_rgba(193,215,46,0.4)] font-black text-sm uppercase tracking-wider flex items-center gap-3">
                {message}
            </div>
        </div>
    );
};
