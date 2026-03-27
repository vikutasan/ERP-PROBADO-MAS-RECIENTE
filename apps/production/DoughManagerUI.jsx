import React, { useState, useEffect } from 'react';
import { 
    ArrowLeft, Plus, Search, Filter, Loader2, ChefHat, Info, 
    Save, X, ChevronRight, ChevronLeft, Beaker, Zap, Timer, 
    Scale, Trash2, ListOrdered, Settings2, Package, ArrowRight
} from 'lucide-react';

/**
 * DOUGH MANAGER UI (INDUSTRIAL EDITION)
 * 
 * Basado en la Matriz de Producción R de Rico.
 * Maneja MEP, Procedimientos y Rendimientos.
 */

export const DoughManagerUI = ({ onBack }) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedDough, setSelectedDough] = useState(null);
    const [doughs, setDoughs] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    const loadDoughs = async () => {
        try {
            const resp = await fetch('http://localhost:3002/api/v1/production/doughs');
            if (resp.ok) setDoughs(await resp.json());
        } catch (e) { console.error(e); }
        finally { setIsLoading(false); }
    };

    useEffect(() => { loadDoughs(); }, []);

    return (
        <div className="flex-1 flex flex-col h-full animate-in fade-in duration-500 overflow-hidden">
            {/* Header: GESTOR DE MASAS */}
            <div className="flex items-center justify-between p-8 border-b border-white/5 bg-black/20 backdrop-blur-xl">
                <div className="flex items-center gap-6">
                    {onBack && (
                        <button 
                            onClick={onBack}
                            className="w-10 h-10 rounded-full border border-white/10 flex items-center justify-center text-gray-400 hover:text-white hover:bg-white/5 transition-all"
                        >
                            <ArrowLeft size={20} />
                        </button>
                    )}
                    <div>
                        <h1 className="text-4xl font-black italic uppercase tracking-tighter text-white">
                            GESTOR DE <span className="text-orange-500 text-glow">MASAS</span>
                        </h1>
                        <p className="text-[10px] font-bold text-gray-500 uppercase tracking-[0.4em] mt-1">
                            Control de Materia Prima • R de Rico
                        </p>
                    </div>
                </div>

                <div className="flex items-center gap-4">
                    <div className="relative group">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-orange-500 transition-colors" size={16} />
                        <input 
                            type="text" 
                            placeholder="Buscar masa o clave..."
                            className="bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-6 text-xs font-bold text-white focus:outline-none focus:ring-1 focus:ring-orange-500/50 w-64 transition-all"
                        />
                    </div>
                    <button 
                        onClick={() => setIsModalOpen(true)}
                        className="bg-[#c1d72e] text-black px-8 py-4 rounded-2xl font-black uppercase text-xs tracking-widest flex items-center gap-3 hover:scale-105 active:scale-95 transition-all shadow-lg shadow-[#c1d72e]/20"
                    >
                        <Plus size={20} strokeWidth={3} />
                        AGREGAR MASA
                    </button>
                </div>
            </div>

            {/* Listado de Masas */}
            <div className="flex-1 overflow-auto p-8 custom-scrollbar">
                {isLoading ? (
                    <div className="flex flex-col items-center justify-center h-64 space-y-4">
                        <Loader2 className="animate-spin text-orange-500" size={48} />
                        <p className="text-[10px] font-bold text-gray-500 uppercase tracking-widest">Sincronizando Archivo Maestro...</p>
                    </div>
                ) : (
                    <div className="flex flex-col gap-4 max-w-5xl mx-auto">
                        {doughs.map(dough => (
                            <div 
                                key={dough.id} 
                                onClick={() => { setSelectedDough(dough); setIsModalOpen(true); }}
                                className="group relative bg-[#0a0a0a] border border-white/5 rounded-2xl p-4 hover:bg-[#111] hover:border-[#c1d72e]/30 transition-all duration-300 cursor-pointer overflow-hidden flex items-center gap-6 shadow-xl"
                            >
                                {/* Brillo de fondo al hover */}
                                <div className="absolute inset-0 bg-gradient-to-r from-[#c1d72e]/0 via-transparent to-transparent group-hover:from-[#c1d72e]/5 transition-all duration-500 opacity-0 group-hover:opacity-100" />
                                
                                {/* Sólo Nombre de la Masa (Compacto) */}
                                <div className="relative z-10 flex flex-1 items-center justify-between">
                                    <h3 className="text-xl font-black text-white italic tracking-tight group-hover:text-[#c1d72e] transition-all duration-300">
                                        <span className="text-[#c1d72e] not-italic mr-3">[{dough.code || 'M-00'}]</span> 
                                        {dough.name}
                                    </h3>
                                    
                                    <div className="opacity-0 group-hover:opacity-100 transition-all duration-300 flex items-center gap-2">
                                        <span className="text-[9px] font-black text-gray-500 uppercase tracking-widest italic">Editar</span>
                                        <ArrowRight size={16} className="text-[#c1d72e]" />
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {isModalOpen && (
                <DoughWizardModal 
                    initialData={selectedDough}
                    onClose={() => { setIsModalOpen(false); setSelectedDough(null); }} 
                    onSuccess={() => { setIsModalOpen(false); setSelectedDough(null); loadDoughs(); }}
                />
            )}
        </div>
    );
};

/**
 * WIZARD MODAL: ADN PANADERO
 */
const DoughWizardModal = ({ onClose, onSuccess, initialData }) => {
    const [step, setStep] = useState(1);
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState(initialData || {
        code: '', name: '', dough_type: 'SALADA', description: '',
        theoretical_yield: 0, expected_waste: 0,
        requires_rest: false, rest_container: '', rest_warehouse: '', rest_time_min: 0,
        ingredients: [],
        procedure_steps: [],
        batches: [{ name: 'BASE', baston_qty: 1 }],
        product_relations: [],
        dough_relations: [] // Para pre-fermentos
    });

    const [catalog, setCatalog] = useState({ products: [], doughs: [] });
    const [searchTerm, setSearchTerm] = useState('');

    const loadCatalog = async () => {
        try {
            const [pResp, dResp] = await Promise.all([
                fetch('http://localhost:3002/api/v1/products'),
                fetch('http://localhost:3002/api/v1/production/doughs')
            ]);
            if (pResp.ok && dResp.ok) {
                setCatalog({
                    products: await pResp.json(),
                    doughs: await dResp.json()
                });
            }
        } catch (e) { console.error("Error loading catalog:", e); }
    };

    useEffect(() => { loadCatalog(); }, []);

    const addIngredient = () => {
        setFormData({
            ...formData,
            ingredients: [...formData.ingredients, { name: '', qty_per_baston: 0, unit: 'g', mep_type: 'POLVOS' }]
        });
    };

    const addStep = () => {
        setFormData({
            ...formData,
            procedure_steps: [...formData.procedure_steps, { 
                step_number: formData.procedure_steps.length + 1, 
                task: 'REVOLVER', description: '', equipment: '', speed: '1', time_minutes: 0 
            }]
        });
    };

    const [notification, setNotification] = useState(null);

    const showNotify = (title, msg, type = 'error') => {
        setNotification({ title, msg, type });
        if (type === 'success') setTimeout(() => setNotification(null), 3000);
    };

    const handleSave = async () => {
        setLoading(true);
        try {
            const isUpdate = !!initialData?.id;
            const url = isUpdate 
                ? `http://localhost:3002/api/v1/production/doughs/${initialData.id}`
                : 'http://localhost:3002/api/v1/production/doughs';
            
            const resp = await fetch(url, {
                method: isUpdate ? 'PUT' : 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });
            
            if (resp.ok) {
                showNotify("ÉXITO", "Masa guardada correctamente", "success");
                setTimeout(onSuccess, 1500);
            } else {
                const err = await resp.json();
                showNotify("ERROR DE MOTOR", err.detail || "No se pudo guardar la masa", "error");
            }
        } catch (e) {
            showNotify("ERROR DE CONEXIÓN", "El servidor no responde (Puerto 3002)", "error");
        } finally {
            setLoading(false);
        }
    };

    const steps = [
        { id: 1, label: 'GENERAL', icon: Info },
        { id: 2, label: 'RECETA (BOM)', icon: Beaker },
        { id: 3, label: 'PROCESO DE REVOLTURA', icon: ListOrdered },
        { id: 4, label: 'REPOSO', icon: Timer },
        { id: 5, label: 'VÍNCULOS', icon: Zap }
    ];

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-8">
            <div className="absolute inset-0 bg-black/90 backdrop-blur-2xl" onClick={onClose} />
            
            <div className="relative w-full max-w-6xl h-[90vh] bg-[#111] border border-white/10 rounded-[60px] flex flex-col overflow-hidden shadow-2xl animate-in zoom-in-95 duration-300">
                {/* Modal Header - Compact */}
                <div className="p-6 pb-2 flex items-center justify-between">
                    <div className="flex items-center gap-6">
                        <div>
                            <h2 className="text-4xl font-black italic uppercase tracking-tighter text-white">
                                {formData.name || 'NUEVA MASA'}
                            </h2>
                            <p className="text-[10px] font-bold text-gray-500 uppercase tracking-[0.4em] mt-1">Configuración Maestra Industrial</p>
                        </div>
                    </div>
                    <button onClick={onClose} className="p-4 bg-white/5 rounded-full hover:bg-white/10 transition-all text-gray-500 hover:text-white">
                        <X size={24} />
                    </button>
                </div>

                {/* Stepper Progress - Condensed */}
                <div className="px-10 py-4 flex gap-3">
                    {steps.map(s => (
                        <button 
                            key={s.id}
                            onClick={() => setStep(s.id)}
                            className={`flex-1 flex items-center gap-3 p-3 rounded-2xl border transition-all
                                ${step === s.id ? 'bg-orange-500 border-orange-500 text-black' : 'bg-white/5 border-white/5 text-gray-500 hover:border-white/10'}`}
                        >
                            <div className={`p-1.5 rounded-lg ${step === s.id ? 'bg-black/20' : 'bg-black/40'}`}>
                                <s.icon size={16} />
                            </div>
                            <span className="text-[9px] font-black uppercase tracking-widest">{s.label}</span>
                        </button>
                    ))}
                </div>
                
                {/* Form Content - Truly Centered Distribution */}
                <div className="flex-1 overflow-auto px-10 relative flex flex-col justify-center min-h-0 custom-scrollbar py-6">
                    <div className="max-w-5xl mx-auto w-full">
                        {step === 1 && (
                            <div className="grid grid-cols-2 gap-8 animate-in slide-in-from-bottom-4 duration-500">
                                <div className="space-y-6">
                                    <label className="block">
                                        <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Nombre de la Masa</span>
                                        <input 
                                            type="text" 
                                            value={formData.name}
                                            onChange={e => setFormData({...formData, name: e.target.value})}
                                            placeholder="Ej: MASA DE FUERZA REFINADA"
                                            className="w-full bg-white/5 border border-white/10 rounded-3xl p-5 mt-2 focus:ring-1 focus:ring-orange-500/50 outline-none text-white font-bold"
                                        />
                                    </label>
                                    <label className="block">
                                        <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Clave Maestra</span>
                                        <input 
                                            type="text" 
                                            value={formData.code}
                                            onChange={e => setFormData({...formData, code: e.target.value})}
                                            placeholder="Ej: MF-01"
                                            className="w-full bg-white/5 border border-white/10 rounded-3xl p-5 mt-2 focus:ring-1 focus:ring-orange-500/50 outline-none text-white font-mono font-bold"
                                        />
                                    </label>
                                </div>
                                <div className="space-y-6">
                                    <label className="block">
                                        <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Tipo de Masa</span>
                                        <select 
                                            value={formData.dough_type}
                                            onChange={e => setFormData({...formData, dough_type: e.target.value})}
                                            className="w-full bg-white/5 border border-white/10 rounded-3xl p-5 mt-2 focus:ring-1 focus:ring-orange-500/50 outline-none text-white font-bold appearance-none uppercase"
                                        >
                                            <option value="PREFERMENTO">PREFERMENTO</option>
                                            <option value="MASA SALADA">MASA SALADA</option>
                                            <option value="MASA DULCE">MASA DULCE</option>
                                        </select>
                                    </label>
                                    <div className="grid grid-cols-2 gap-4">
                                        <label className="block">
                                            <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Rend. Teórico (g)</span>
                                            <input 
                                                type="number" 
                                                value={formData.theoretical_yield}
                                                onChange={e => setFormData({...formData, theoretical_yield: Number(e.target.value)})}
                                                className="w-full bg-white/5 border border-white/10 rounded-3xl p-5 mt-2 font-mono text-[#c1d72e] font-bold"
                                            />
                                        </label>
                                        <label className="block">
                                            <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">% Merma Esperada</span>
                                            <input 
                                                type="number" 
                                                value={formData.expected_waste}
                                                onChange={e => setFormData({...formData, expected_waste: Number(e.target.value)})}
                                                className="w-full bg-white/5 border border-white/10 rounded-3xl p-5 mt-2 font-mono text-red-500 font-bold"
                                            />
                                        </label>
                                    </div>
                                </div>
                            </div>
                        )}

                        {step === 2 && (
                            <div className="space-y-4 animate-in fade-in duration-500">
                                <div className="flex justify-between items-center mb-6">
                                    <h3 className="text-xl font-black italic uppercase text-white">Mise en Place <span className="text-orange-500">(BOM)</span></h3>
                                    <button onClick={addIngredient} className="bg-white/5 hover:bg-orange-500 hover:text-black border border-white/10 px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all gap-2 flex items-center">
                                        <Plus size={14}/> Agregar Insumo
                                    </button>
                                </div>
                                <div className="space-y-4">
                                    {formData.ingredients.length === 0 && (
                                        <div className="text-center py-20 bg-white/5 rounded-[40px] border border-dashed border-white/10">
                                            <Beaker size={48} className="mx-auto text-gray-700 mb-4" />
                                            <p className="text-gray-500 font-bold uppercase text-[10px] tracking-widest">No hay ingredientes cargados todavía</p>
                                        </div>
                                    )}
                                    {formData.ingredients.map((ing, idx) => (
                                        <div key={idx} className="flex gap-4 bg-white/5 p-6 rounded-[30px] border border-white/5 hover:border-white/20 transition-all group">
                                            <div className="flex-1">
                                                <input 
                                                    placeholder="Nombre del Insumo"
                                                    value={ing.name}
                                                    onChange={e => {
                                                        const newIngs = [...formData.ingredients];
                                                        newIngs[idx].name = e.target.value;
                                                        setFormData({...formData, ingredients: newIngs});
                                                    }}
                                                    className="bg-transparent border-none text-white font-black text-sm w-full outline-none focus:placeholder-orange-500"
                                                />
                                            </div>
                                            <div className="w-48">
                                                <select 
                                                    value={ing.mep_type}
                                                    onChange={e => {
                                                        const newIngs = [...formData.ingredients];
                                                        newIngs[idx].mep_type = e.target.value;
                                                        setFormData({...formData, ingredients: newIngs});
                                                    }}
                                                    className="bg-black/40 border border-white/10 rounded-xl px-4 py-2 text-[10px] font-black text-gray-400 outline-none w-full"
                                                >
                                                    <option value="POLVOS">POLVOS</option>
                                                    <option value="LIQUIDOS">LÍQUIDOS</option>
                                                    <option value="PRE-FERMENTO">PRE-FERMENTO</option>
                                                </select>
                                            </div>
                                            <div className="w-32 flex items-center gap-2">
                                                <input 
                                                    type="number"
                                                    value={ing.qty_per_baston}
                                                    onChange={e => {
                                                        const newIngs = [...formData.ingredients];
                                                        newIngs[idx].qty_per_baston = Number(e.target.value);
                                                        setFormData({...formData, ingredients: newIngs});
                                                    }}
                                                    className="bg-black/40 border border-white/10 rounded-xl px-4 py-2 text-white font-mono text-center w-full"
                                                />
                                                <span className="text-[10px] font-black text-gray-600">g</span>
                                            </div>
                                            <button 
                                                onClick={() => {
                                                    const newIngs = formData.ingredients.filter((_, i) => i !== idx);
                                                    setFormData({...formData, ingredients: newIngs});
                                                }}
                                                className="p-2 text-gray-700 hover:text-red-500 transition-colors"
                                            >
                                                <Trash2 size={18}/>
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {step === 3 && (
                            <div className="space-y-4 animate-in fade-in duration-500">
                                <div className="flex justify-between items-center mb-6">
                                    <h3 className="text-xl font-black italic uppercase text-white">Cronograma de <span className="text-orange-500">Revoltura</span></h3>
                                    <button onClick={addStep} className="bg-white/5 hover:bg-orange-500 hover:text-black border border-white/10 px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all gap-2 flex items-center">
                                        <Plus size={14}/> Agregar Paso
                                    </button>
                                </div>
                                <div className="space-y-4 relative">
                                    {formData.procedure_steps.map((st, idx) => (
                                        <div key={idx} className="flex gap-4 items-center">
                                            <div className="w-10 h-10 rounded-xl bg-orange-500/10 border border-orange-500/20 flex items-center justify-center text-orange-500 font-black italic shrink-0">
                                                {st.step_number}
                                            </div>
                                            <div className="flex-1 bg-white/5 p-4 rounded-2xl border border-white/5 flex items-center gap-4 group hover:border-white/20 transition-all">
                                                <input 
                                                    placeholder="Tarea (Ej: INTEGRAR HARINA)"
                                                    value={st.task}
                                                    onChange={e => {
                                                        const newSteps = [...formData.procedure_steps];
                                                        newSteps[idx].task = e.target.value.toUpperCase();
                                                        setFormData({...formData, procedure_steps: newSteps});
                                                    }}
                                                    className="flex-1 bg-black/40 border border-white/10 rounded-xl p-3 text-xs font-black text-white outline-none"
                                                />
                                                <input 
                                                    placeholder="Equipo"
                                                    value={st.equipment}
                                                    onChange={e => {
                                                        const newSteps = [...formData.procedure_steps];
                                                        newSteps[idx].equipment = e.target.value.toUpperCase();
                                                        setFormData({...formData, procedure_steps: newSteps});
                                                    }}
                                                    className="w-40 bg-black/40 border border-white/10 rounded-xl p-3 text-[10px] font-black text-gray-400 outline-none"
                                                />
                                                <select 
                                                    value={st.speed}
                                                    onChange={e => {
                                                        const newSteps = [...formData.procedure_steps];
                                                        newSteps[idx].speed = e.target.value;
                                                        setFormData({...formData, procedure_steps: newSteps});
                                                    }}
                                                    className="w-24 bg-black/40 border border-white/10 rounded-xl p-3 text-[10px] font-black text-white outline-none"
                                                >
                                                    <option value="1">VEL 1</option>
                                                    <option value="2">VEL 2</option>
                                                    <option value="OFF">OFF</option>
                                                </select>
                                                <div className="flex items-center gap-2 bg-black/40 border border-white/10 rounded-xl px-3 py-2">
                                                    <input 
                                                        type="number"
                                                        value={st.time_minutes}
                                                        onChange={e => {
                                                            const newSteps = [...formData.procedure_steps];
                                                            newSteps[idx].time_minutes = Number(e.target.value);
                                                            setFormData({...formData, procedure_steps: newSteps});
                                                        }}
                                                        className="w-12 bg-transparent text-xs font-mono font-black text-orange-500 text-center outline-none"
                                                    />
                                                    <span className="text-[9px] font-black text-gray-600">MIN</span>
                                                </div>
                                                <button 
                                                    onClick={() => {
                                                        const newSteps = formData.procedure_steps.filter((_, i) => i !== idx);
                                                        setFormData({...formData, procedure_steps: newSteps});
                                                    }}
                                                    className="p-2 text-gray-700 hover:text-red-500 transition-colors"
                                                >
                                                    <Trash2 size={16}/>
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {step === 4 && (
                            <div className="animate-in fade-in duration-500 max-w-2xl mx-auto w-full">
                                <div className="space-y-8">
                                    <div className="p-6 bg-[#c1d72e]/5 border border-[#c1d72e]/20 rounded-[32px] space-y-6">
                                        <div className="flex items-center justify-between px-2">
                                            <h3 className="text-sm font-black italic uppercase text-white tracking-widest">Requiere <span className="text-[#c1d72e]">Reposo Maestro</span></h3>
                                            <button 
                                                onClick={() => setFormData({...formData, requires_rest: !formData.requires_rest})}
                                                className={`w-12 h-6 rounded-full transition-all relative ${formData.requires_rest ? 'bg-[#c1d72e]' : 'bg-white/10'}`}
                                            >
                                                <div className={`absolute top-1 w-4 h-4 rounded-full bg-white shadow-xl transition-all ${formData.requires_rest ? 'left-7' : 'left-1'}`} />
                                            </button>
                                        </div>
                                        <hr className="border-white/5" />
                                        <div className="space-y-4">
                                            <label className="block">
                                                <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Contenedor de Reposo</span>
                                                <input 
                                                    type="text" 
                                                    value={formData.rest_container}
                                                    onChange={e => setFormData({...formData, rest_container: e.target.value})}
                                                    placeholder="Ej: CUBETA AMARILLA 20L / CHAROLA"
                                                    className="w-full bg-black/40 border border-white/10 rounded-3xl p-5 mt-2 outline-none text-white font-bold"
                                                />
                                            </label>
                                            <div className="grid grid-cols-2 gap-4">
                                                <label className="block">
                                                    <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Almacén de Destino</span>
                                                    <input 
                                                        type="text" 
                                                        value={formData.rest_warehouse}
                                                        onChange={e => setFormData({...formData, rest_warehouse: e.target.value})}
                                                        placeholder="Ej: CÁMARA 1"
                                                        className="w-full bg-black/40 border border-white/10 rounded-3xl p-5 mt-2 outline-none text-white font-bold"
                                                    />
                                                </label>
                                                <label className="block">
                                                    <span className="text-[10px] font-black uppercase text-gray-500 tracking-widest pl-2">Tiempo de Reposo</span>
                                                    <div className="flex items-center gap-2 mt-2">
                                                        <div className="flex-1 flex items-center gap-2 bg-black/40 border border-white/10 rounded-[20px] px-4 py-3 focus-within:border-orange-500/50 transition-all">
                                                            <input 
                                                                type="number" 
                                                                placeholder="0"
                                                                value={Math.floor(formData.rest_time_min / 60) || ''}
                                                                onChange={e => {
                                                                    const hours = Number(e.target.value);
                                                                    const mins = formData.rest_time_min % 60;
                                                                    setFormData({...formData, rest_time_min: (hours * 60) + mins});
                                                                }}
                                                                className="bg-transparent text-white font-mono font-black text-lg w-full outline-none text-center"
                                                            />
                                                            <span className="text-[9px] font-black text-gray-500 tracking-widest uppercase">HRS</span>
                                                        </div>
                                                        <div className="flex-1 flex items-center gap-2 bg-black/40 border border-white/10 rounded-[20px] px-4 py-3 focus-within:border-orange-500/50 transition-all">
                                                            <input 
                                                                type="number" 
                                                                placeholder="0"
                                                                value={formData.rest_time_min % 60 || ''}
                                                                onChange={e => {
                                                                    const mins = Number(e.target.value);
                                                                    const hours = Math.floor(formData.rest_time_min / 60);
                                                                    setFormData({...formData, rest_time_min: (hours * 60) + mins});
                                                                }}
                                                                className="bg-transparent text-white font-mono font-black text-lg w-full outline-none text-center"
                                                            />
                                                            <span className="text-[9px] font-black text-gray-500 tracking-widest uppercase">MIN</span>
                                                        </div>
                                                    </div>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {step === 5 && (
                            <div className="animate-in fade-in duration-500 pt-6 max-w-4xl mx-auto w-full">
                                <div className="space-y-6">
                                    <div className="text-center mb-8">
                                        <h3 className="text-2xl font-black italic uppercase text-white">
                                            {formData.dough_type === 'PREFERMENTO' ? 'Masas' : 'Productos'} en que <span className="text-orange-500 text-glow">se usa</span>
                                        </h3>
                                        <p className="text-[10px] font-bold text-gray-500 uppercase tracking-widest mt-2">Traza la cadena de producción industrial</p>
                                    </div>

                                    {/* Buscador de Vínculos */}
                                    <div className="relative group max-w-xl mx-auto">
                                        <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-orange-500 transition-colors" size={20} />
                                        <input 
                                            type="text" 
                                            placeholder={`Buscar ${formData.dough_type === 'PREFERMENTO' ? 'masa' : 'producto'} para vincular...`}
                                            value={searchTerm}
                                            onChange={e => setSearchTerm(e.target.value)}
                                            className="w-full bg-white/5 border border-white/10 rounded-[30px] py-5 pl-14 pr-6 text-sm font-bold text-white focus:outline-none focus:ring-2 focus:ring-orange-500/30 transition-all"
                                        />
                                        
                                        {searchTerm && (
                                            <div className="absolute top-full left-0 right-0 mt-2 bg-[#1a1a1a] border border-white/10 rounded-3xl overflow-hidden z-50 shadow-2xl max-h-64 overflow-auto custom-scrollbar">
                                                {(formData.dough_type === 'PREFERMENTO' ? catalog.doughs : catalog.products)
                                                    .filter(item => item.name.toLowerCase().includes(searchTerm.toLowerCase()) && item.id !== initialData?.id)
                                                    .map(item => (
                                                        <button 
                                                            key={item.id}
                                                            onClick={() => {
                                                                const key = formData.dough_type === 'PREFERMENTO' ? 'dough_relations' : 'product_relations';
                                                                if (!formData[key].find(r => r.id === item.id)) {
                                                                    setFormData({...formData, [key]: [...formData[key], item]});
                                                                }
                                                                setSearchTerm('');
                                                            }}
                                                            className="w-full px-6 py-4 flex items-center justify-between hover:bg-white/5 transition-all text-left border-b border-white/5 last:border-0"
                                                        >
                                                            <div className="flex items-center gap-4">
                                                                <div className="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center text-orange-500 font-black italic text-[10px]">
                                                                    {item.code || 'ID'}
                                                                </div>
                                                                <span className="text-xs font-bold text-white uppercase">{item.name}</span>
                                                            </div>
                                                            <Plus size={16} className="text-[#c1d72e]" />
                                                        </button>
                                                    ))
                                                }
                                            </div>
                                        )}
                                    </div>

                                    {/* Lista de Vínculos Actuales */}
                                    <div className="grid grid-cols-2 gap-4 mt-8">
                                        {(formData.dough_type === 'PREFERMENTO' ? formData.dough_relations : formData.product_relations).map(item => (
                                            <div key={item.id} className="bg-white/5 border border-white/5 p-4 rounded-2xl flex items-center justify-between group hover:border-orange-500/30 transition-all">
                                                <div className="flex items-center gap-4">
                                                    <div className="w-10 h-10 rounded-xl bg-black/40 flex items-center justify-center text-[#c1d72e] font-black italic text-xs border border-white/5">
                                                        {item.code || 'ID'}
                                                    </div>
                                                    <span className="text-xs font-black text-white uppercase tracking-tight">{item.name}</span>
                                                </div>
                                                <button 
                                                    onClick={() => {
                                                        const key = formData.dough_type === 'PREFERMENTO' ? 'dough_relations' : 'product_relations';
                                                        setFormData({...formData, [key]: formData[key].filter(r => r.id !== item.id)});
                                                    }}
                                                    className="p-2 bg-red-500/10 text-red-500 rounded-lg opacity-0 group-hover:opacity-100 transition-all hover:bg-red-500 hover:text-white"
                                                >
                                                    <Trash2 size={14} />
                                                </button>
                                            </div>
                                        ))}
                                        {(formData.dough_type === 'PREFERMENTO' ? formData.dough_relations : formData.product_relations).length === 0 && (
                                            <div className="col-span-2 py-12 border border-dashed border-white/10 rounded-[40px] flex flex-col items-center justify-center opacity-30 select-none">
                                                <Zap size={32} />
                                                <p className="text-[10px] font-black uppercase tracking-widest mt-4">No hay vínculos establecidos</p>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                </div>

                {/* Footer Navigation - Slim */}
                <div className="p-6 bg-black/40 border-t border-white/10 backdrop-blur-3xl flex justify-end items-center">
                    <div className="flex gap-3">
                        {step > 1 && (
                            <button 
                                onClick={() => setStep(step - 1)}
                                className="px-8 py-5 bg-white/5 hover:bg-white/10 rounded-3xl text-xs font-black uppercase tracking-widest text-gray-400 hover:text-white transition-all flex items-center gap-2"
                            >
                                <ChevronLeft size={18}/> Anterior
                            </button>
                        )}

                        {step < 5 && (
                            <button 
                                onClick={() => setStep(step + 1)}
                                className="px-8 py-5 bg-white text-black rounded-3xl text-xs font-black uppercase tracking-widest hover:scale-105 active:scale-95 transition-all flex items-center gap-2"
                            >
                                Siguiente <ChevronRight size={18}/>
                            </button>
                        )}
                        
                        <button 
                            onClick={handleSave}
                            disabled={loading || !formData.name}
                            className={`px-10 py-5 rounded-3xl text-xs font-black uppercase tracking-widest transition-all flex items-center gap-2 shadow-xl
                                ${loading || !formData.name ? 'bg-gray-800 text-gray-500 cursor-not-allowed' : 'bg-[#c1d72e] text-black hover:scale-105 active:scale-95 shadow-[#c1d72e]/20'}`}
                        >
                            {loading ? <Loader2 className="animate-spin" size={18}/> : <Save size={18}/>}
                            GUARDAR MASA
                        </button>
                    </div>
                </div>

                {/* NOTIFICACIÓN "IMPERIAL" */}
                {notification && (
                    <div className="absolute top-10 left-1/2 -translate-x-1/2 z-[110] animate-in fade-in slide-in-from-top-8 duration-500">
                        <div className={`px-10 py-6 rounded-[30px] border backdrop-blur-3xl shadow-2xl flex items-center gap-6 min-w-[400px]
                            ${notification.type === 'error' ? 'bg-red-500/10 border-red-500/50 text-red-500' : 'bg-[#c1d72e]/10 border-[#c1d72e]/50 text-[#c1d72e]'}`}>
                            <div className={`w-12 h-12 rounded-2xl flex items-center justify-center bg-black/40`}>
                                {notification.type === 'error' ? <X size={24}/> : <Plus size={24}/>}
                            </div>
                            <div>
                                <p className="text-[10px] font-black uppercase tracking-[0.3em] opacity-60 mb-1">{notification.title}</p>
                                <p className="text-sm font-black uppercase italic tracking-tight text-white">{notification.msg}</p>
                            </div>
                            {notification.type === 'error' && (
                                <button onClick={() => setNotification(null)} className="ml-auto p-2 hover:bg-white/10 rounded-full transition-all">
                                    <X size={16}/>
                                </button>
                            )}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};
