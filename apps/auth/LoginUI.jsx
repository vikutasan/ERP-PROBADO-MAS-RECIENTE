import React, { useState } from 'react';

/**
 * R DE RICO - LOGIN UI
 * 
 * Interfaz de acceso profesional con seguridad por roles.
 * Diseño premium, minimalista y de alto impacto.
 */

export const LoginUI = ({ onLogin }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [isProcessing, setIsProcessing] = useState(false);

    const handleSubmit = (e) => {
        e.preventDefault();
        setIsProcessing(true);

        // Simulación de autenticación
        setTimeout(() => {
            setIsProcessing(false);
            // Determinamos el rol basado en el email para el demo
            let role = 'WAITER';
            if (email.includes('admin')) role = 'ADMIN';
            else if (email.includes('gerente')) role = 'MANAGER';
            else if (email.includes('panadero')) role = 'BAKER';
            else if (email.includes('chofer')) role = 'DRIVER';

            onLogin({ email, role });
        }, 1200);
    };

    return (
        <div className="min-h-screen flex items-center justify-center p-6 font-sans text-white bg-cover bg-center" style={{ backgroundImage: 'url("/assets/wood_bg.jpg")' }}>
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            <div className="max-w-md w-full relative z-10">
                {/* Branding */}
                <div className="text-center mb-12 animate-in fade-in slide-in-from-top-4 duration-700">
                    <img src="/assets/logo.png" alt="Logo R de Rico" className="w-24 h-24 object-contain mx-auto mb-6 drop-shadow-[0_0_20px_rgba(255,255,255,0.2)]" />
                    <h1 className="text-6xl font-black uppercase italic tracking-tighter text-orange-500 mb-2">R de Rico</h1>
                    <p className="text-[10px] font-black text-gray-500 tracking-[0.4em] uppercase">Evolutive Digital Ecosystem</p>
                </div>

                <div className="bg-gray-900/40 border border-gray-800 p-10 rounded-[50px] shadow-2xl backdrop-blur-3xl relative overflow-hidden">
                    {/* Efectos de luz */}
                    <div className="absolute -top-20 -left-20 w-40 h-40 bg-orange-600/10 blur-3xl rounded-full"></div>
                    <div className="absolute -bottom-20 -right-20 w-40 h-40 bg-indigo-600/10 blur-3xl rounded-full"></div>

                    <form onSubmit={handleSubmit} className="relative z-10 space-y-6">
                        <h2 className="text-lg font-black uppercase tracking-tight text-white mb-8">Iniciar Sesión</h2>

                        <div className="space-y-4">
                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-400 mb-2 block tracking-widest">Credenciales</label>
                                <input
                                    type="text"
                                    placeholder="Usuario o Email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="w-full bg-black/60 border border-gray-800 p-5 rounded-2xl outline-none focus:border-orange-500 font-bold text-sm transition-all placeholder:text-gray-700"
                                    required
                                />
                            </div>
                            <div>
                                <input
                                    type="password"
                                    placeholder="Contraseña"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className="w-full bg-black/60 border border-gray-800 p-5 rounded-2xl outline-none focus:border-orange-500 font-bold text-sm transition-all placeholder:text-gray-700"
                                    required
                                />
                            </div>
                        </div>

                        <div className="flex justify-between items-center text-[10px] font-black uppercase tracking-widest px-2">
                            <label className="flex items-center gap-2 text-gray-500 cursor-pointer hover:text-white transition-colors">
                                <input type="checkbox" className="accent-orange-500" /> Recordarme
                            </label>
                            <button type="button" className="text-orange-500/80 hover:text-orange-500 transition-colors">¿Olvidaste tu contraseña?</button>
                        </div>

                        <button
                            type="submit"
                            disabled={isProcessing}
                            className={`w-full py-5 rounded-2xl font-black uppercase text-xs tracking-widest transition-all ${isProcessing ? 'bg-gray-800 text-gray-600' : 'bg-white text-black hover:bg-orange-500 hover:text-white shadow-2xl shadow-white/5 active:scale-95'}`}
                        >
                            {isProcessing ? 'VALIDANDO...' : 'ENTRAR AL SISTEMA'}
                        </button>
                    </form>
                </div>

                <div className="mt-12 text-center text-[9px] font-bold text-gray-700 uppercase tracking-[0.3em]">
                    Sucursal Toluca Centro | Terminal ID: RDR-001-A
                </div>
            </div>
        </div>
    );
};
