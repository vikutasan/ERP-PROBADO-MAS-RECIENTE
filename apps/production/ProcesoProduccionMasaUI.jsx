import React, { useState } from 'react';
import { 
    ArrowLeft, Save, ChevronDown, ChevronRight, Plus, 
    Trash2, Copy, GripVertical, Settings, Mic, ListOrdered 
} from 'lucide-react';

export const ProcesoProduccionMasaUI = ({ masaId, masaNombre, theme, onClose, onSave, initialData }) => {
    // If theme is not provided (safety fallback), we use a default neutral theme
    const activeTheme = theme || { bg: '#f3f4f6', input: '#ffffff', text: '#1f2937', border: '#e5e7eb' };

    // Initial state matching the 28-column schema we defined
    const [pasos, setPasos] = useState(initialData || [
        {
            id: '1',
            nombre: 'IDENTIFICAR EL MEP',
            idBloque: 'G-MAS-15',
            isExpanded: true,
            subpasos: [
                {
                    id: '1.1',
                    nombre: 'Revisar orden de producción',
                    instruccionVoz: 'Revisa la orden. ¿Cuántas preparaciones harás hoy?',
                    tHumano: 1.0,
                    tAutonomo: 0.0,
                    recurso: 'MESA-TRABAJO-01',
                    nivelCritico: 'bajo',
                    operarioLibre: false,
                    confirmacionVoz: true,
                    triggerInicio: 'inicio_turno',
                    preguntaValidacion: '¿Cuántas preparaciones harás hoy?',
                    tipCoaching: '',
                    grupoInseparable: '',
                    showAdvanced: false
                }
            ]
        }
    ]);

    const handleSubpasoChange = (pasoId, subpasoId, field, value) => {
        setPasos(pasos.map(p => {
            if (p.id !== pasoId) return p;
            return {
                ...p,
                subpasos: p.subpasos.map(sp => {
                    if (sp.id !== subpasoId) return sp;
                    return { ...sp, [field]: value };
                })
            };
        }));
    };

    const toggleStep = (pasoId) => {
        setPasos(pasos.map(p => 
            p.id === pasoId ? { ...p, isExpanded: !p.isExpanded } : p
        ));
    };

    const toggleAdvanced = (pasoId, subpasoId) => {
        setPasos(pasos.map(p => {
            if (p.id !== pasoId) return p;
            return {
                ...p,
                subpasos: p.subpasos.map(sp => {
                    if (sp.id !== subpasoId) return sp;
                    return { ...sp, showAdvanced: !sp.showAdvanced };
                })
            };
        }));
    };

    const addSubpaso = (pasoId) => {
        setPasos(pasos.map(p => {
            if (p.id !== pasoId) return p;
            const newId = `${p.id}.${p.subpasos.length + 1}`;
            return {
                ...p,
                subpasos: [...p.subpasos, {
                    id: newId,
                    nombre: 'Nueva Tarea',
                    instruccionVoz: '',
                    tHumano: 0.5,
                    tAutonomo: 0.0,
                    recurso: 'MESA-TRABAJO-01',
                    nivelCritico: 'bajo',
                    operarioLibre: false,
                    confirmacionVoz: true,
                    triggerInicio: 'confirmacion_anterior',
                    preguntaValidacion: '',
                    tipCoaching: '',
                    grupoInseparable: '',
                    showAdvanced: false
                }]
            };
        }));
    };

    const addPaso = () => {
        const newId = `${pasos.length + 1}`;
        setPasos([...pasos, {
            id: newId,
            nombre: 'Nuevo Paso',
            idBloque: '',
            isExpanded: true,
            subpasos: []
        }]);
    };

    const removeSubpaso = (pasoId, subpasoId) => {
        setPasos(pasos.map(p => {
            if (p.id !== pasoId) return p;
            return {
                ...p,
                subpasos: p.subpasos.filter(sp => sp.id !== subpasoId)
            };
        }));
    };

    return (
        <div style={{ backgroundColor: activeTheme.bg }} className="absolute inset-0 z-50 overflow-y-auto w-full h-full transition-colors duration-500">
            <div className="max-w-[1400px] mx-auto p-8">
                
                {/* HEADER */}
                <div style={{ backgroundColor: activeTheme.input, borderColor: activeTheme.border }} className="flex justify-between items-center mb-8 p-6 rounded-2xl shadow-sm border">
                    <div>
                        <h1 style={{ color: activeTheme.text }} className="text-3xl font-black italic uppercase">Configuración del Agente</h1>
                        <div className="mt-2 flex items-center gap-4">
                            <span style={{ backgroundColor: 'rgba(0,0,0,0.1)', color: activeTheme.text }} className="px-3 py-1.5 rounded-xl text-[12px] font-black uppercase tracking-widest">{masaId || 'N/A'}</span>
                            <span style={{ color: activeTheme.text }} className="font-black text-lg uppercase tracking-tight">{masaNombre || 'Masa Seleccionada'}</span>
                        </div>
                    </div>
                    <div className="flex gap-4">
                        <button 
                            onClick={onClose}
                            style={{ color: activeTheme.text, borderColor: activeTheme.text }}
                            className="px-6 py-3 border-2 rounded-2xl hover:opacity-70 flex items-center gap-2 font-black uppercase text-xs tracking-widest transition-all"
                        >
                            <ArrowLeft size={16} /> Volver
                        </button>
                        <button 
                            onClick={() => { 
                                if(onSave) onSave(pasos);
                                onClose(); 
                            }}
                            style={{ backgroundColor: activeTheme.text, color: activeTheme.bg }}
                            className="px-6 py-3 rounded-2xl hover:scale-105 transition-all flex items-center gap-2 font-black uppercase text-xs tracking-widest shadow-xl"
                        >
                            <Save size={16} /> Guardar
                        </button>
                    </div>
                </div>

                {/* PASOS */}
                {pasos.map((paso, index) => (
                    <div key={paso.id} style={{ backgroundColor: activeTheme.input, borderColor: activeTheme.border }} className="border rounded-3xl mb-6 shadow-sm overflow-hidden transition-all duration-300">
                        {/* Step Header */}
                        <div 
                            style={{ borderBottomColor: activeTheme.border }}
                            className="p-6 border-b flex items-center gap-4 cursor-pointer hover:opacity-80 transition-opacity"
                            onClick={(e) => {
                                if(e.target.tagName !== 'INPUT') toggleStep(paso.id);
                            }}
                        >
                            <div style={{ backgroundColor: activeTheme.text, color: activeTheme.bg }} className="w-10 h-10 rounded-xl flex items-center justify-center font-black italic shrink-0 shadow-md">
                                {paso.id}
                            </div>
                            <div className="flex-1 flex flex-col gap-1 max-w-[500px]">
                                <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Nombre del Paso Principal</label>
                                <input 
                                    type="text" 
                                    style={{ color: activeTheme.text }}
                                    className="w-full p-3 border border-black/5 rounded-xl bg-white/50 focus:bg-white outline-none transition-all font-black text-sm" 
                                    value={paso.nombre}
                                    onChange={e => setPasos(pasos.map(p => p.id === paso.id ? {...p, nombre: e.target.value} : p))}
                                />
                            </div>
                            <div className="flex-1 flex flex-col gap-1 max-w-[200px]">
                                <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Grupo Maquinaria</label>
                                <input 
                                    type="text" 
                                    style={{ color: activeTheme.text }}
                                    placeholder="Ej. G-MAS-15"
                                    className="w-full p-3 border border-black/5 rounded-xl bg-white/50 focus:bg-white outline-none transition-all font-black text-sm placeholder-black/30" 
                                    value={(!paso.idBloque || String(paso.idBloque).toUpperCase() === 'NAN') ? '' : paso.idBloque}
                                    onChange={e => setPasos(pasos.map(p => p.id === paso.id ? {...p, idBloque: e.target.value} : p))}
                                />
                            </div>
                            <div className="flex-1"></div>
                            {paso.isExpanded ? <ChevronDown size={24} style={{ color: activeTheme.text }} /> : <ChevronRight size={24} style={{ color: activeTheme.text }} />}
                        </div>

                        {/* Step Body (Subpasos) */}
                        {paso.isExpanded && (
                            <div className="p-8 bg-white/40 border-t border-black/5">
                                <h4 style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest mb-6 flex items-center gap-2 opacity-70">
                                    <ListOrdered size={16} /> LISTA DE TAREAS (SUBPASOS)
                                </h4>

                                {paso.subpasos.map((sp) => {
                                    const tH = parseFloat(sp.tHumano) || 0;
                                    const tA = parseFloat(sp.tAutonomo) || 0;
                                    const totalTime = tH + tA;
                                    const humanPct = totalTime > 0 ? (tH / totalTime) * 100 : 0;
                                    const autoPct = totalTime > 0 ? (tA / totalTime) * 100 : 0;

                                    return (
                                        <div key={sp.id} style={{ backgroundColor: 'rgba(255,255,255,0.6)', borderColor: activeTheme.border }} className="border rounded-2xl p-4 mb-4 flex gap-4 shadow-sm relative transition-all">
                                            {sp.operarioLibre && (
                                                <div className="absolute left-0 top-0 bottom-0 w-1 bg-green-500 rounded-l-2xl"></div>
                                            )}
                                            
                                            <div style={{ color: activeTheme.text }} className="cursor-grab py-2 flex items-center select-none opacity-40 hover:opacity-100 transition-opacity">
                                                <GripVertical size={20} />
                                            </div>
                                            
                                            <div className="flex-1 flex flex-col gap-4">
                                                {/* ROW 1: Names */}
                                                <div className="grid grid-cols-5 gap-4">
                                                    <div className="col-span-2 flex flex-col gap-1">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">{sp.id} Nombre de la Tarea</label>
                                                        <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nombre} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nombre', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs" />
                                                    </div>
                                                    <div className="col-span-3 flex flex-col gap-1 relative">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest flex items-center gap-1"><Mic size={12}/> Instrucción de Voz Principal</label>
                                                        <div className="relative">
                                                            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                                <Mic size={16} style={{ color: activeTheme.text }} className="opacity-50" />
                                                            </div>
                                                            <input 
                                                                type="text" 
                                                                style={{ color: activeTheme.text, borderColor: activeTheme.text }}
                                                                value={sp.instruccionVoz} 
                                                                onChange={e => handleSubpasoChange(paso.id, sp.id, 'instruccionVoz', e.target.value)} 
                                                                className="w-full py-3 pl-10 pr-3 border rounded-xl bg-white outline-none border-l-4 font-black text-xs shadow-sm" 
                                                            />
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* ROW 2: Numbers & Resources */}
                                                <div className="grid grid-cols-4 gap-4">
                                                    <div className="flex flex-col gap-1">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">T. Humano (min)</label>
                                                        <input type="number" step="0.1" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.tHumano} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tHumano', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs" />
                                                    </div>
                                                    <div className="flex flex-col gap-1">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">T. Autónomo (min)</label>
                                                        <input type="number" step="0.1" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.tAutonomo} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tAutonomo', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs" />
                                                    </div>
                                                    <div className="flex flex-col gap-1">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Recurso Asignado</label>
                                                        <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recurso} onChange={e => handleSubpasoChange(paso.id, sp.id, 'recurso', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs">
                                                            <option value="MESA-TRABAJO-01">Mesa de Trabajo 1</option>
                                                            <option value="BATIDORA-01">Batidora 1</option>
                                                            <option value="REVOLVEDORA-01">Revolvedora 1</option>
                                                            <option value="REFINADORA-01">Refinadora 1</option>
                                                            <option value="BASCULA-01">Báscula 1</option>
                                                            <option value="RACK-FERMENTO-01">Rack de Fermento 1</option>
                                                        </select>
                                                    </div>
                                                    <div className="flex flex-col gap-1">
                                                        <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Nivel de Criticidad</label>
                                                        <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nivelCritico} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nivelCritico', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs">
                                                            <option value="bajo">Bajo (Tono Normal)</option>
                                                            <option value="medio">Medio (Tono Firme)</option>
                                                            <option value="alto">Alto (Tono Enfático)</option>
                                                        </select>
                                                    </div>
                                                </div>

                                                {/* ROW 3: Timeline Bar */}
                                                <div>
                                                    <div style={{ color: activeTheme.text }} className="flex justify-between text-[10px] font-black uppercase tracking-widest opacity-70 mb-1">
                                                        <span>Línea de Tiempo Estimada</span>
                                                        <span>{totalTime.toFixed(1)} min total</span>
                                                    </div>
                                                    <div className="w-full h-2 bg-slate-200 rounded-full flex overflow-hidden">
                                                        <div style={{width: `${humanPct}%`}} className="bg-amber-500 h-full transition-all" title="Humano"></div>
                                                        <div style={{width: `${autoPct}%`}} className="bg-emerald-500 h-full transition-all" title="Autónomo"></div>
                                                    </div>
                                                </div>

                                                {/* ROW 4: Options */}
                                                <div style={{ backgroundColor: 'rgba(255,255,255,0.4)', borderColor: activeTheme.border }} className="flex items-center gap-6 p-3 rounded-xl border border-dashed">
                                                    
                                                    <label className="flex items-center gap-2 cursor-pointer">
                                                        <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
                                                            <input type="checkbox" className="toggle-checkbox absolute block w-5 h-5 rounded-full bg-white border-4 appearance-none cursor-pointer z-10 transition-transform duration-200 ease-in-out" 
                                                                style={{ transform: sp.operarioLibre ? 'translateX(100%)' : 'translateX(0)', borderColor: sp.operarioLibre ? '#10b981' : activeTheme.border }}
                                                                checked={sp.operarioLibre}
                                                                onChange={e => handleSubpasoChange(paso.id, sp.id, 'operarioLibre', e.target.checked)}
                                                            />
                                                            <div style={{ backgroundColor: sp.operarioLibre ? '#10b981' : 'rgba(0,0,0,0.1)' }} className={`toggle-label block overflow-hidden h-5 rounded-full cursor-pointer transition-colors duration-200 ease-in-out`}></div>
                                                        </div>
                                                        <span style={{ color: sp.operarioLibre ? '#059669' : activeTheme.text }} className={`text-xs font-black uppercase tracking-widest ${!sp.operarioLibre && 'opacity-60'}`}>Operario Libre</span>
                                                    </label>

                                                    <div style={{ backgroundColor: activeTheme.border }} className="h-5 w-px"></div>

                                                    <label className="flex items-center gap-2 cursor-pointer">
                                                        <input type="checkbox" style={{ accentColor: activeTheme.text }} checked={sp.confirmacionVoz} onChange={e => handleSubpasoChange(paso.id, sp.id, 'confirmacionVoz', e.target.checked)} className="w-4 h-4 rounded border-black/10 cursor-pointer" />
                                                        <span style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest opacity-80">Confirmación por Voz</span>
                                                    </label>

                                                    <div className="flex-1"></div>

                                                    <button onClick={() => toggleAdvanced(paso.id, sp.id)} style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest hover:underline flex items-center gap-1 opacity-70">
                                                        <Settings size={14} /> {sp.showAdvanced ? 'Ocultar' : 'Mostrar'} Avanzados
                                                    </button>
                                                </div>

                                                {sp.showAdvanced && (
                                                    <div style={{ borderColor: activeTheme.border }} className="grid grid-cols-2 gap-4 mt-2 pt-4 border-t border-dashed animate-in slide-in-from-top-2">
                                                        <div className="flex flex-col gap-1">
                                                            <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Trigger de Inicio</label>
                                                            <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.triggerInicio} onChange={e => handleSubpasoChange(paso.id, sp.id, 'triggerInicio', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs">
                                                                <option value="inicio_turno">Inicio de Turno</option>
                                                                <option value="confirmacion_anterior">Confirmación Anterior</option>
                                                                <option value="fin_temporizador">Fin de Temporizador</option>
                                                            </select>
                                                        </div>
                                                        <div className="flex flex-col gap-1">
                                                            <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Pregunta de Validación</label>
                                                            <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.preguntaValidacion} onChange={e => handleSubpasoChange(paso.id, sp.id, 'preguntaValidacion', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs" />
                                                        </div>
                                                        <div className="col-span-2 flex flex-col gap-1">
                                                            <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Tip de Coaching Sensorial (Opcional)</label>
                                                            <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.text }} placeholder="Ej. La masa debe verse brillante..." value={sp.tipCoaching} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tipCoaching', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none border-l-4 font-black text-xs placeholder-black/30 shadow-sm" />
                                                        </div>
                                                        <div className="col-span-2 flex flex-col gap-1 max-w-xs">
                                                            <label style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-80">Grupo Inseparable</label>
                                                            <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. G-VEL-1" value={sp.grupoInseparable} onChange={e => handleSubpasoChange(paso.id, sp.id, 'grupoInseparable', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-xs placeholder-black/30" />
                                                        </div>
                                                    </div>
                                                )}

                                            </div>
                                            
                                            {/* Actions Side */}
                                            <div className="flex flex-col gap-2 pt-1">
                                                <button style={{ color: activeTheme.text, borderColor: activeTheme.border }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-white transition-all shadow-sm" title="Duplicar">
                                                    <Copy size={16} />
                                                </button>
                                                <button onClick={() => removeSubpaso(paso.id, sp.id)} style={{ color: '#ef4444', borderColor: '#fca5a5' }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-red-50 transition-all shadow-sm" title="Eliminar">
                                                    <Trash2 size={16} />
                                                </button>
                                            </div>
                                        </div>
                                    );
                                })}

                                <button onClick={() => addSubpaso(paso.id)} style={{ color: activeTheme.text, borderColor: activeTheme.border }} className="w-full py-4 border-2 border-dashed rounded-xl font-black text-[10px] uppercase tracking-widest hover:bg-black/5 transition-colors flex items-center justify-center gap-2">
                                    <Plus size={16} /> Agregar Tarea
                                </button>
                            </div>
                        )}
                    </div>
                ))}

                <button onClick={addPaso} style={{ color: activeTheme.text, backgroundColor: activeTheme.input, borderColor: activeTheme.border }} className="w-full py-6 border-2 border-dashed rounded-3xl font-black text-sm uppercase tracking-widest hover:scale-[1.01] transition-all flex items-center justify-center gap-2 shadow-sm mb-20">
                    <Plus size={20} /> AGREGAR NUEVO PASO PRINCIPAL
                </button>

            </div>
        </div>
    );
};
