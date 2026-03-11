import React, { useState } from 'react';

/**
 * R DE RICO - NOMINA HUB (Electronic Payroll)
 * 
 * Gestión profesional de sueldos, percepciones y deducciones.
 * Timbrado fiscal CFDI de Nómina integrado.
 */

export const PayrollHubUI = () => {
    const [step, setStep] = useState('periods'); // periods | calculation | receipts
    const [selectedPeriod, setSelectedPeriod] = useState(null);

    const mockEmployees = [
        { id: 'EMP-001', name: 'Gerardo Ramos', role: 'MANAGER', salary: 12000, attendance: '100%', incidents: 0, kpiBonus: 1500, netPay: 13500 },
        { id: 'EMP-002', name: 'Sofía Soto', role: 'BAKER', salary: 8500, attendance: '95%', incidents: 1, kpiBonus: 800, netPay: 9300 },
        { id: 'EMP-003', name: 'Juan Pérez', role: 'DRIVER', salary: 7000, attendance: '88%', incidents: 3, kpiBonus: 200, netPay: 7200 },
    ];

    return (
        <div className="bg-[#050505] min-h-screen text-white p-10 font-sans animate-fade">

            {/* Header de Nómina */}
            <div className="flex justify-between items-end mb-12 border-b border-gray-800 pb-10">
                <div>
                    <h1 className="text-5xl font-black uppercase italic tracking-tighter text-indigo-400">Nómina Electrónica</h1>
                    <p className="text-[10px] font-black text-gray-500 uppercase tracking-[0.4em] mt-3 underline decoration-indigo-500/30">Protocolo de Pago CFDI | SAT R DE RICO</p>
                </div>

                <div className="flex bg-gray-900/50 p-2 rounded-2xl border border-gray-800">
                    {['periods', 'calculation', 'receipts'].map(tab => (
                        <button
                            key={tab}
                            onClick={() => setStep(tab)}
                            className={`px-8 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${step === tab ? 'bg-indigo-600 shadow-xl shadow-indigo-600/30 text-white' : 'text-gray-500 hover:text-white'}`}
                        >
                            {tab === 'periods' ? 'Periodos' : tab === 'calculation' ? 'Cálculo Actual' : 'Recibos Timbrados'}
                        </button>
                    ))}
                </div>
            </div>

            {step === 'periods' && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 animate-in slide-in-from-bottom-8 duration-500">
                    {[
                        { date: '16 Feb - 28 Feb', status: 'CLOSED', total: '$142,500', employees: 12 },
                        { date: '01 Mar - 15 Mar', status: 'OPEN', total: 'Calculando...', employees: 12 },
                        { date: '16 Mar - 31 Mar', status: 'PENDING', total: '-', employees: 12 }
                    ].map((p, i) => (
                        <div key={i} className={`p-10 rounded-[50px] glass border ${p.status === 'OPEN' ? 'border-indigo-500/40 bg-indigo-500/5' : 'border-gray-800/50'}`}>
                            <p className="text-[9px] font-black uppercase text-gray-500 mb-2 tracking-[0.2em]">{p.status}</p>
                            <h2 className="text-2xl font-black mb-6">{p.date}</h2>
                            <div className="space-y-4 mb-8">
                                <div className="flex justify-between text-xs font-bold">
                                    <span className="text-gray-500 uppercase">Empleados</span>
                                    <span>{p.employees}</span>
                                </div>
                                <div className="flex justify-between text-xs font-bold">
                                    <span className="text-gray-500 uppercase">Impacto Nómina</span>
                                    <span className="text-indigo-400 font-black">{p.total}</span>
                                </div>
                            </div>
                            <button
                                onClick={() => { setSelectedPeriod(p); setStep('calculation'); }}
                                className={`w-full py-4 rounded-2xl font-black uppercase text-[10px] tracking-widest transition-all ${p.status === 'OPEN' ? 'bg-indigo-600 text-white shadow-xl shadow-indigo-600/20' : 'bg-gray-800 text-gray-400'}`}
                            >
                                {p.status === 'OPEN' ? 'GESTIONAR PAGOS' : 'VER HISTÓRICO'}
                            </button>
                        </div>
                    ))}
                </div>
            )}

            {step === 'calculation' && (
                <div className="animate-in fade-in duration-500 space-y-8">
                    <div className="flex justify-between items-center mb-6">
                        <h2 className="text-3xl font-black uppercase italic">Cálculo de Quincena <span className="text-indigo-500 text-sm not-italic ml-4">01 MAR - 15 MAR</span></h2>
                        <div className="flex gap-4">
                            <button className="px-6 py-3 rounded-xl border border-gray-800 text-[10px] font-black uppercase hover:bg-white/5 transition-all">Recalcular</button>
                            <button className="px-6 py-3 rounded-xl bg-emerald-600 text-white text-[10px] font-black uppercase shadow-xl shadow-emerald-600/20">Autorizar Pagos</button>
                        </div>
                    </div>

                    <div className="glass overflow-hidden rounded-[50px]">
                        <table className="w-full text-left">
                            <thead className="bg-indigo-600/5 text-[10px] font-black uppercase tracking-[0.2em] text-indigo-400">
                                <tr>
                                    <th className="p-8">Empleado</th>
                                    <th className="p-8">Asistencia / Incidencias</th>
                                    <th className="p-8">Sueldo Base</th>
                                    <th className="p-8">Bonos / Comisiones</th>
                                    <th className="p-8 text-right">Neto a Pagar</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-800/30 text-xs font-bold">
                                {mockEmployees.map((emp, i) => (
                                    <tr key={i} className="hover:bg-white/5 transition-all">
                                        <td className="p-8">
                                            <p className="text-white text-sm font-black uppercase italic">{emp.name}</p>
                                            <p className="text-[9px] text-gray-500 uppercase tracking-widest">{emp.role}</p>
                                        </td>
                                        <td className="p-8">
                                            <div className="flex items-center gap-4">
                                                <span className="text-emerald-500">{emp.attendance} Att.</span>
                                                <span className={`${emp.incidents > 0 ? 'text-red-500' : 'text-gray-700'}`}>{emp.incidents} Incidencias</span>
                                            </div>
                                        </td>
                                        <td className="p-8 text-gray-400 font-mono">${emp.salary.toLocaleString()}</td>
                                        <td className="p-8 text-emerald-500 font-mono">+${emp.kpiBonus.toLocaleString()}</td>
                                        <td className="p-8 text-right">
                                            <p className="text-xl font-black text-white font-mono">${emp.netPay.toLocaleString()}</p>
                                            <button className="text-[8px] uppercase text-indigo-500 tracking-tighter hover:underline mt-1">Ver desglose fiscal ↓</button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {step === 'receipts' && (
                <div className="animate-in zoom-in-95 duration-500 text-center py-20">
                    <div className="w-20 h-20 bg-indigo-600/10 border border-indigo-500/20 rounded-full flex items-center justify-center mx-auto mb-8">
                        <span className="text-4xl">🧾</span>
                    </div>
                    <h2 className="text-3xl font-black uppercase italic mb-4">Módulo de Timbrado Masivo</h2>
                    <p className="text-gray-500 text-sm max-w-md mx-auto mb-10 leading-relaxed font-bold italic">Selecciona los recibos autorizados para realizar el timbrado fiscal ante el SAT y enviar el PDF/XML a cada empleado.</p>
                    <button className="bg-white text-black px-12 py-5 rounded-2xl font-black uppercase text-xs tracking-widest shadow-2xl shadow-indigo-600/20 hover:scale-105 transition-all">Ejecutar Timbrado CFDI</button>
                </div>
            )}

            <footer className="fixed bottom-8 left-10 text-[8px] text-gray-800 font-black uppercase tracking-[0.5em] flex items-center gap-4">
                <span>R DE RICO ERP | PAYROLL ENGINE V4.0</span>
                <div className="w-1 h-1 bg-gray-900 rounded-full" />
                <span className="text-gray-900 border border-gray-900 px-2 py-0.5 rounded">AUTO-CALC ACTIVE</span>
            </footer>
        </div>
    );
};
