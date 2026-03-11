import React, { useState } from 'react';

/**
 * R de Rico - Gestión de Manuales Operativos (ADMIN/GERENTE)
 * 
 * Interfaz tipo Google Calendar para:
 * 1. Crear actividades recurrentes por puesto y día.
 * 2. Definir procedimientos y prioridades.
 * 3. Editar manuales dinámicamente.
 */

export const ManualManagerUI = ({ roles, initialActivities }) => {
    const [selectedRole, setSelectedRole] = useState('BAKER');
    const [selectedDay, setSelectedDay] = useState(1); // Lunes por defecto
    const [activities, setActivities] = useState(initialActivities || []);
    const [showModal, setShowModal] = useState(false);
    const [newActivity, setNewActivity] = useState({
        name: '',
        startTime: '06:00',
        duration: 30,
        procedure: '',
        priority: 'FUNDAMENTAL',
        isRecurring: true
    });

    const days = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];

    const handleSave = () => {
        // Lógica para guardar actividad vinculada al día y rol
        setActivities([...activities, { ...newActivity, id: Date.now() }]);
        setShowModal(false);
    };

    return (
        <div className="bg-[#0b0c0d] text-white min-h-screen p-8 font-sans">
            <div className="flex justify-between items-start mb-10">
                <div>
                    <h1 className="text-4xl font-black uppercase tracking-tighter text-blue-500">Manuales Operativos</h1>
                    <p className="text-gray-500 font-bold tracking-widest text-xs uppercase">R DE RICO | NÚCLEO RRHH</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="bg-blue-600 px-8 py-4 rounded-2xl font-black uppercase tracking-widest shadow-2xl shadow-blue-500/20 active:scale-95 transition-all"
                >
                    + Agregar Actividad
                </button>
            </div>

            {/* Selectores de Filtro */}
            <div className="flex gap-4 mb-8">
                <div className="flex-1 bg-gray-900/50 p-2 rounded-2xl border border-gray-800 flex gap-2">
                    {roles.map(role => (
                        <button
                            key={role}
                            onClick={() => setSelectedRole(role)}
                            className={`flex-1 py-3 rounded-xl font-bold text-xs uppercase transition-all ${selectedRole === role ? 'bg-blue-600 text-white shadow-xl shadow-blue-500/10' : 'text-gray-500 hover:text-white'}`}
                        >
                            {role}
                        </button>
                    ))}
                </div>

                <div className="bg-gray-900/50 p-2 rounded-2xl border border-gray-800 flex gap-1">
                    {days.map((day, idx) => (
                        <button
                            key={day}
                            onClick={() => setSelectedDay(idx)}
                            className={`px-4 py-3 rounded-xl font-bold text-[10px] uppercase transition-all ${selectedDay === idx ? 'bg-white text-black' : 'text-gray-500 hover:text-white'}`}
                        >
                            {day.slice(0, 3)}
                        </button>
                    ))}
                </div>
            </div>

            {/* Tabla de Cronograma Operativo */}
            <div className="bg-gray-900/30 border border-gray-800 rounded-3xl overflow-hidden backdrop-blur-md">
                <table className="w-full text-left">
                    <thead className="bg-gray-900/80 font-bold text-gray-500 uppercase text-[10px] tracking-widest">
                        <tr>
                            <th className="px-8 py-5">Horario</th>
                            <th className="px-8 py-5">Actividad</th>
                            <th className="px-8 py-5">Procedimiento</th>
                            <th className="px-8 py-5 text-center">Prioridad</th>
                            <th className="px-8 py-5 text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800/50">
                        {activities.length > 0 ? activities.map(act => (
                            <tr key={act.id} className="hover:bg-blue-600/5 transition-colors group">
                                <td className="px-8 py-6">
                                    <p className="font-mono text-lg text-blue-400 font-black">{act.startTime}</p>
                                    <p className="text-[10px] text-gray-600 font-bold uppercase">{act.duration} min</p>
                                </td>
                                <td className="px-8 py-6">
                                    <p className="font-black text-gray-100 uppercase tracking-tighter">{act.name}</p>
                                    <p className="text-[10px] text-gray-500 italic">Recurrencia: {act.isRecurring ? 'Semanal' : 'Única'}</p>
                                </td>
                                <td className="px-8 py-6 max-w-sm">
                                    <p className="text-gray-400 text-sm line-clamp-2 leading-relaxed">{act.procedure}</p>
                                </td>
                                <td className="px-8 py-6 text-center">
                                    <span className={`px-4 py-1 rounded-full text-[10px] font-black uppercase ${act.priority === 'FUNDAMENTAL' ? 'bg-red-900/20 text-red-500 ring-1 ring-red-500/50' : 'bg-green-900/20 text-green-500 ring-1 ring-green-500/50'}`}>
                                        {act.priority}
                                    </span>
                                </td>
                                <td className="px-8 py-6 text-right space-x-2">
                                    <button className="text-gray-600 hover:text-white font-bold text-xs">Editar</button>
                                    <button className="text-gray-800 hover:text-red-500 font-bold text-xs">Borrar</button>
                                </td>
                            </tr>
                        )) : (
                            <tr>
                                <td colSpan="5" className="px-8 py-20 text-center text-gray-700 font-black uppercase tracking-widest text-xs italic">
                                    No hay actividades cargadas para el {days[selectedDay]} en {selectedRole}
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* Modal Estilo Google Calendar */}
            {showModal && (
                <div className="fixed inset-0 bg-black/90 backdrop-blur-3xl flex items-center justify-center p-6 z-50">
                    <div className="bg-[#121417] border border-gray-800 p-10 rounded-[40px] max-w-2xl w-full shadow-[0_0_100px_rgba(37,99,235,0.1)]">
                        <h2 className="text-3xl font-black text-white mb-8 uppercase tracking-tighter italic flex items-center gap-3">
                            <span className="w-3 h-10 bg-blue-600 block rounded-full" />
                            Nueva Actividad Operativa
                        </h2>

                        <div className="grid grid-cols-2 gap-6 mb-8">
                            <div className="col-span-2">
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Nombre de la Actividad</label>
                                <input
                                    type="text"
                                    value={newActivity.name}
                                    onChange={(e) => setNewActivity({ ...newActivity, name: e.target.value })}
                                    className="w-full bg-gray-900 border border-gray-800 rounded-2xl p-4 text-white focus:border-blue-500 transition-all outline-none font-bold placeholder-gray-700"
                                    placeholder="Ej: Encendido de Hornos y Precalentado"
                                />
                            </div>

                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Hora de Inicio</label>
                                <input
                                    type="time"
                                    value={newActivity.startTime}
                                    onChange={(e) => setNewActivity({ ...newActivity, startTime: e.target.value })}
                                    className="w-full bg-gray-900 border border-gray-800 rounded-2xl p-4 text-white focus:border-blue-500 outline-none font-bold"
                                />
                            </div>

                            <div>
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Duración (minutos)</label>
                                <input
                                    type="number"
                                    value={newActivity.duration}
                                    onChange={(e) => setNewActivity({ ...newActivity, duration: parseInt(e.target.value) })}
                                    className="w-full bg-gray-900 border border-gray-800 rounded-2xl p-4 text-white focus:border-blue-500 outline-none font-bold"
                                />
                            </div>

                            <div className="col-span-2">
                                <label className="text-[10px] uppercase font-black text-gray-500 mb-2 block">Procedimiento Paso a Paso</label>
                                <textarea
                                    value={newActivity.procedure}
                                    onChange={(e) => setNewActivity({ ...newActivity, procedure: e.target.value })}
                                    className="w-full bg-gray-900 border border-gray-800 rounded-2xl p-4 text-white focus:border-blue-500 outline-none min-h-[120px] font-medium leading-relaxed"
                                    placeholder="Detalla aquí cómo debe ejecutarse esta tarea..."
                                />
                            </div>

                            <div className="col-span-2 flex items-center justify-between p-4 bg-gray-900/50 rounded-2xl border border-gray-800">
                                <p className="text-xs font-black uppercase text-gray-400 italic">¿Se repite cada semana ({days[selectedDay]})?</p>
                                <button
                                    onClick={() => setNewActivity({ ...newActivity, isRecurring: !newActivity.isRecurring })}
                                    className={`w-14 h-8 rounded-full p-1 transition-all ${newActivity.isRecurring ? 'bg-blue-600' : 'bg-gray-700'}`}
                                >
                                    <div className={`w-6 h-6 bg-white rounded-full transform transition-all ${newActivity.isRecurring ? 'translate-x-6' : ''}`} />
                                </button>
                            </div>
                        </div>

                        <div className="flex gap-4">
                            <button
                                onClick={() => setShowModal(false)}
                                className="flex-1 bg-gray-900 text-gray-400 font-black py-4 rounded-2xl hover:bg-gray-800 transition-all uppercase tracking-widest text-xs"
                            >
                                Cancelar
                            </button>
                            <button
                                onClick={handleSave}
                                className="flex-1 bg-blue-600 text-white font-black py-4 rounded-2xl shadow-xl shadow-blue-600/20 hover:bg-blue-500 transition-all uppercase tracking-widest text-xs"
                            >
                                Guardar Actividad
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
