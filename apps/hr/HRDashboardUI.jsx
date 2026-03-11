import React, { useState } from 'react';

/**
 * R de Rico - HR Management Dashboard (Recursos Humanos)
 * 
 * Este módulo moderno permite:
 * 1. Gestión de Talento (Panaderos, Pizzeros, Meseros).
 * 2. Control de Asistencia (Clock-in / Clock-out).
 * 3. Simulación de Nómina.
 * 4. Asignación de Turnos Dinámica.
 */

export const HRDashboardUI = ({ employees, currentShifts }) => {
    const [activeTab, setActiveTab] = useState('employees');
    const [showIncidentModal, setShowIncidentModal] = useState(false);
    const [newIncident, setNewIncident] = useState({
        employeeId: '',
        type: 'ABSENCE',
        severity: 'LOW',
        description: ''
    });


    const stats = {
        total: employees.length,
        active: employees.filter(e => e.isActive).length,
        onShift: 12, // Simulado
        absences: 1
    };

    return (
        <div className="bg-[#121416] text-white min-h-screen p-8 font-sans">
            {/* Header Corporativo */}
            <div className="flex justify-between items-center mb-10">
                <div>
                    <h1 className="text-4xl font-black uppercase tracking-tighter text-orange-500">Gestión de Talento</h1>
                    <p className="text-gray-500 font-bold tracking-widest text-xs uppercase">R DE RICO | NÚCLEO RRHH</p>
                </div>
                <div className="flex items-center gap-4">
                    {activeTab === 'incidents' && (
                        <button
                            onClick={() => setShowIncidentModal(true)}
                            className="bg-red-600 hover:bg-red-500 text-white px-6 py-3 rounded-2xl font-black uppercase tracking-widest shadow-xl shadow-red-500/20 transition-all active:scale-95 text-xs"
                        >
                            + Nueva Incidencia
                        </button>
                    )}
                    <div className="flex bg-gray-900 p-1 rounded-2xl border border-gray-800">
                        <button
                            onClick={() => setActiveTab('employees')}
                            className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${activeTab === 'employees' ? 'bg-orange-600 text-white shadow-lg shadow-orange-600/20' : 'text-gray-400 hover:text-white'}`}
                        >
                            Empleados
                        </button>
                        <button
                            onClick={() => setActiveTab('incidents')}
                            className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${activeTab === 'incidents' ? 'bg-red-600 text-white shadow-lg shadow-red-600/20' : 'text-gray-400 hover:text-white'}`}
                        >
                            Incidencias
                        </button>
                        <button
                            onClick={() => setActiveTab('shifts')}
                            className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${activeTab === 'shifts' ? 'bg-orange-600 text-white shadow-lg shadow-orange-600/20' : 'text-gray-400 hover:text-white'}`}
                        >
                            Turnos
                        </button>
                    </div>
                </div>
            </div>

            {/* Tarjetas de Estadística */}
            <div className="grid grid-cols-4 gap-6 mb-10">
                {[
                    { label: "Total Equipo", value: stats.total, color: "orange" },
                    { label: "En Turno Ahora", value: stats.onShift, color: "green" },
                    { label: "Asistencia Hoy", value: "98%", color: "blue" },
                    { label: "Alertas / Incidencias", value: 3, color: "red" }
                ].map(stat => (
                    <div key={stat.label} className="bg-gray-900/50 backdrop-blur-xl border border-gray-800 p-6 rounded-3xl">
                        <p className="text-gray-500 text-xs font-black uppercase mb-2 tracking-widest">{stat.label}</p>
                        <div className="flex items-end gap-2">
                            <span className={`text-4xl font-black text-${stat.color}-500`}>{stat.value}</span>
                            <span className="text-sm text-gray-600 mb-1 font-bold">Eventos</span>
                        </div>
                    </div>
                ))}
            </div>

            {/* Tabla de Empleados / Incidencias */}
            <div className="bg-gray-900/30 border border-gray-800 rounded-3xl overflow-hidden backdrop-blur-md">
                {activeTab === 'employees' ? (
                    <table className="w-full text-left">
                        <thead className="bg-gray-900 font-bold text-gray-500 uppercase text-[10px] tracking-[0.2em]">
                            <tr>
                                <th className="px-8 py-5">Colaborador</th>
                                <th className="px-8 py-5">Rol / Área</th>
                                <th className="px-8 py-5">Sucursal</th>
                                <th className="px-8 py-5">Estatus</th>
                                <th className="px-8 py-5 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-800/50 text-sm">
                            {employees.map(emp => (
                                <tr key={emp.id} className="hover:bg-orange-600/5 transition-colors group">
                                    <td className="px-8 py-5 flex items-center gap-4">
                                        <div className="w-10 h-10 rounded-full bg-gray-800 flex items-center justify-center font-black text-orange-500 text-xs shadow-inner border border-gray-700">
                                            {emp.firstName[0]}{emp.lastName[0]}
                                        </div>
                                        <div>
                                            <p className="font-black text-gray-100">{emp.firstName} {emp.lastName}</p>
                                            <p className="text-[10px] text-gray-500 font-mono italic">{emp.email}</p>
                                        </div>
                                    </td>
                                    <td className="px-8 py-5">
                                        <span className="bg-gray-800 text-gray-300 px-3 py-1 rounded-lg font-black text-[10px] uppercase border border-gray-700">
                                            {emp.role}
                                        </span>
                                    </td>
                                    <td className="px-8 py-5 font-bold text-gray-400 italic">{emp.branch}</td>
                                    <td className="px-8 py-5">
                                        <div className="flex items-center gap-2">
                                            <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                                            <span className="text-xs font-bold text-green-500 uppercase">Activo</span>
                                        </div>
                                    </td>
                                    <td className="px-8 py-5 text-right">
                                        <button className="bg-orange-600 text-white px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-orange-500 transition-all active:scale-95">Expediente</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : activeTab === 'incidents' ? (
                    <table className="w-full text-left">
                        <thead className="bg-gray-900 font-bold text-red-500 uppercase text-[10px] tracking-[0.2em]">
                            <tr>
                                <th className="px-8 py-5">Colaborador</th>
                                <th className="px-8 py-5">Tipo de Incidencia</th>
                                <th className="px-8 py-5">Gravedad</th>
                                <th className="px-8 py-5 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-800/50 text-sm">
                            <tr className="hover:bg-red-600/5 transition-colors group">
                                <td className="px-8 py-5">
                                    <p className="font-black text-gray-100">Gerardo Ramos</p>
                                    <p className="text-[10px] text-gray-500 font-mono uppercase">02/03/2026</p>
                                </td>
                                <td className="px-8 py-5">
                                    <p className="text-gray-300 font-bold uppercase text-xs">Retardo (Lateness)</p>
                                    <p className="text-[10px] text-gray-500 line-clamp-1 italic">Problemas transporte público.</p>
                                </td>
                                <td className="px-8 py-5">
                                    <span className="bg-yellow-900/20 text-yellow-500 px-3 py-1 rounded-md text-[10px] font-black border border-yellow-500/30">MEDIUM</span>
                                </td>
                                <td className="px-8 py-5 text-right">
                                    <button className="text-red-500 font-black uppercase text-[10px] hover:underline">Gestionar</button>
                                </td>
                            </tr>
                            <tr className="hover:bg-green-600/5 transition-colors group">
                                <td className="px-8 py-5">
                                    <p className="font-black text-gray-100">Sofía Soto</p>
                                    <p className="text-[10px] text-gray-500 font-mono uppercase">02/03/2026</p>
                                </td>
                                <td className="px-8 py-5">
                                    <p className="text-green-400 font-bold uppercase text-xs">Mérito (Recognition)</p>
                                    <p className="text-[10px] text-gray-500 line-clamp-1 italic">Excelente atención cliente.</p>
                                </td>
                                <td className="px-8 py-5">
                                    <span className="bg-green-900/20 text-green-500 px-3 py-1 rounded-md text-[10px] font-black border border-green-500/30">LOW</span>
                                </td>
                                <td className="px-8 py-5 text-right">
                                    <button className="text-green-500 font-black uppercase text-[10px] hover:underline">Ver Reporte</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                ) : (
                    <div className="p-20 text-center text-gray-600 italic uppercase font-black tracking-widest">
                        Sección en desarrollo: {activeTab}
                    </div>
                )}
            </div>

            {/* Modal para Captura de Incidencias */}
            {showIncidentModal && (
                <div className="fixed inset-0 bg-black/90 backdrop-blur-3xl flex items-center justify-center p-6 z-[60]">
                    <div className="bg-[#1a1c1e] border border-gray-800 p-10 rounded-[40px] max-w-lg w-full shadow-2xl">
                        <h2 className="text-2xl font-black text-white mb-8 uppercase tracking-tighter flex items-center gap-3">
                            <span className="w-2 h-8 bg-red-600 block rounded-full" />
                            Registrar Incidencia
                        </h2>

                        <div className="space-y-6 mb-8">
                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Colaborador</label>
                                <select
                                    className="w-full bg-gray-900 border border-gray-800 rounded-xl p-4 text-white focus:border-red-500 outline-none font-bold"
                                    onChange={(e) => setNewIncident({ ...newIncident, employeeId: e.target.value })}
                                >
                                    <option value="">Seleccionar empleado...</option>
                                    {employees.map(e => <option key={e.id} value={e.id}>{e.firstName} {e.lastName}</option>)}
                                </select>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Tipo</label>
                                    <select
                                        className="w-full bg-gray-900 border border-gray-800 rounded-xl p-4 text-white focus:border-red-500 outline-none font-bold text-xs"
                                        onChange={(e) => setNewIncident({ ...newIncident, type: e.target.value })}
                                    >
                                        <option value="ABSENCE">Falta</option>
                                        <option value="LATENESS">Retardo</option>
                                        <option value="DISCIPLINARY">Disciplina</option>
                                        <option value="MERIT">Mérito</option>
                                        <option value="ACCIDENT">Accidente</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Gravedad</label>
                                    <select
                                        className="w-full bg-gray-900 border border-gray-800 rounded-xl p-4 text-white focus:border-red-500 outline-none font-bold text-xs"
                                        onChange={(e) => setNewIncident({ ...newIncident, severity: e.target.value })}
                                    >
                                        <option value="LOW">Baja</option>
                                        <option value="MEDIUM">Media</option>
                                        <option value="HIGH">Alta</option>
                                        <option value="CRITICAL">Crítica</option>
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Descripción de los hechos</label>
                                <textarea
                                    className="w-full bg-gray-900 border border-gray-800 rounded-xl p-4 text-white focus:border-red-500 outline-none min-h-[100px] text-sm"
                                    placeholder="Detalla lo ocurrido para el expediente..."
                                    onChange={(e) => setNewIncident({ ...newIncident, description: e.target.value })}
                                />
                            </div>
                        </div>

                        <div className="flex gap-4">
                            <button onClick={() => setShowIncidentModal(false)} className="flex-1 bg-gray-900 text-gray-400 font-black py-4 rounded-2xl hover:bg-gray-800 transition-all uppercase tracking-widest text-xs">Descartar</button>
                            <button onClick={() => setShowIncidentModal(false)} className="flex-1 bg-red-600 text-white font-black py-4 rounded-2xl shadow-xl shadow-red-500/20 hover:bg-red-500 transition-all uppercase tracking-widest text-xs">Guardar Reporte</button>
                        </div>
                    </div>
                </div>
            )}
            {/* Paginación */}
            <div className="mt-8 flex justify-between items-center text-gray-600 text-[10px] font-bold uppercase tracking-widest px-4">
                <p>Mostrando 12 de {employees.length} registros</p>
                <div className="flex gap-2">
                    <button className="px-4 py-2 bg-gray-900 rounded-xl border border-gray-800 hover:border-gray-600 text-xs">Anterior</button>
                    <button className="px-4 py-2 bg-gray-900 rounded-xl border border-orange-600/50 hover:border-orange-500 text-white text-xs">Siguiente</button>
                </div>
            </div>
        </div>
    );
};

