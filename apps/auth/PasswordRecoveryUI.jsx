import React, { useState } from 'react';

/**
 * R DE RICO - SISTEMA DE RECUPERACIÓN DE CONTRASEÑA
 * 
 * Flujo profesional para clientes y empleados:
 * 1. Ingreso de Correo Electrónico.
 * 2. Envío de Código de Seguridad (Token).
 * 3. Actualización de Password.
 */

export const PasswordRecoveryUI = () => {
    const [step, setStep] = useState(1); // 1: Email, 2: Token, 3: Success
    const [email, setEmail] = useState('');
    const [isProcessing, setIsProcessing] = useState(false);

    const handleSendReset = () => {
        setIsProcessing(true);
        // Simulación de envío de correo via SendGrid/Mailgun
        setTimeout(() => {
            setIsProcessing(false);
            setStep(2);
        }, 1500);
    };

    return (
        <div className="bg-[#050505] min-h-screen flex items-center justify-center p-6 font-sans text-white">

            <div className="max-w-md w-full bg-gray-900/40 border border-gray-800 p-12 rounded-[50px] shadow-2xl backdrop-blur-3xl relative overflow-hidden group">
                <div className="absolute -top-10 -right-10 w-32 h-32 bg-orange-600/5 blur-3xl rounded-full group-hover:bg-orange-600/10 transition-all"></div>

                <div className="text-center mb-10">
                    <h1 className="text-3xl font-black uppercase italic tracking-tighter text-orange-500 mb-2">R de Rico</h1>
                    <p className="text-[10px] font-black text-gray-500 tracking-[0.3em] uppercase underline decoration-orange-600/30">Protocolo de Seguridad</p>
                </div>

                {step === 1 && (
                    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                        <h2 className="text-xl font-black mb-4 uppercase text-white">¿Olvidaste tu acceso?</h2>
                        <p className="text-xs text-gray-500 font-bold mb-8 leading-relaxed italic">Introduce tu correo institucional. Te enviaremos un token de recuperación válido por 60 minutos.</p>

                        <div className="space-y-6">
                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-400 mb-2 block tracking-widest">Correo Electrónico</label>
                                <input
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="ej: gerardo@rderico.com"
                                    className="w-full bg-black/40 border border-gray-800 p-5 rounded-2xl outline-none focus:border-orange-500 font-bold text-sm transition-all text-white placeholder:text-gray-700"
                                />
                            </div>

                            <button
                                onClick={handleSendReset}
                                disabled={!email || isProcessing}
                                className={`w-full py-5 rounded-2xl font-black uppercase text-xs tracking-widest transition-all ${isProcessing ? 'bg-gray-800 text-gray-500' : 'bg-orange-600 text-white shadow-xl shadow-orange-600/20 hover:scale-[1.02] active:scale-95'}`}
                            >
                                {isProcessing ? 'ENVIANDO...' : 'SOLICITAR ACCESO'}
                            </button>
                        </div>
                    </div>
                )}

                {step === 2 && (
                    <div className="animate-in zoom-in-95 duration-500 text-center">
                        <div className="w-16 h-16 bg-green-600/10 border border-green-500/20 rounded-full flex items-center justify-center mx-auto mb-6">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" className="w-8 h-8 text-green-500">
                                <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" />
                            </svg>
                        </div>
                        <h2 className="text-xl font-black mb-4 uppercase text-white">¡Revisa tu Inbox!</h2>
                        <p className="text-xs text-gray-500 font-bold mb-10 leading-relaxed italic">He enviado un enlace de recuperación a: <br /><span className="text-orange-400 not-italic">{email}</span></p>

                        <button
                            onClick={() => setStep(1)}
                            className="text-[10px] font-black uppercase text-gray-600 hover:text-orange-500 transition-all tracking-[0.2em] underline"
                        >
                            ¿No recibiste nada? Reintentar
                        </button>
                    </div>
                )}

                <div className="mt-12 text-center">
                    <button className="text-[10px] font-black text-gray-700 uppercase tracking-widest hover:text-white transition-all">← Volver al Login Principal</button>
                </div>
            </div>

            <footer className="fixed bottom-8 text-[8px] font-black text-gray-800 uppercase tracking-[0.5em]">
                Sistema Cifrado R DE RICO ERP | 256-bit AES
            </footer>
        </div>
    );
};
