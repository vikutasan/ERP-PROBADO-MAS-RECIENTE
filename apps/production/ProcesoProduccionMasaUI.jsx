import React, { useState, useRef, useEffect } from 'react';
import { 
    ArrowLeft, Save, ChevronDown, ChevronRight, Plus, 
    Trash2, Copy, GripVertical, Settings, Mic, ListOrdered, Info, X, Download, Upload, Table, AlertTriangle, Loader2
} from 'lucide-react';

const API_BASE = `http://${window.location.hostname}:5001/api/v1`;

const FIELD_INFO_DATA = {
    'grupoMaquinaria': {
        title: 'Grupo Maquinaria',
        subtitle: 'Manual de Operación de Planta',
        desc: 'Es el Nombre y Apellido de la estación o máquina donde ocurre este paso (ej. G-MASA-15).',
        bullets: [
            { label: 'Cero Conflictos:', text: 'El sistema bloquea que dos procesos usen la misma máquina al mismo tiempo.' },
            { label: 'Guía del Agente:', text: 'Gemma usará este nombre para mandar al panadero a la estación correcta.' },
            { label: 'Estatus de Planta:', text: 'Permite saber en tiempo real qué máquinas están ocupadas.' }
        ]
    },
    'nombrePaso': {
        title: 'Nombre del Paso',
        subtitle: 'Identificador Principal',
        desc: 'El título general de la etapa productiva.',
        bullets: [
            { label: 'Visibilidad:', text: 'Aparece en los reportes de planta y cronogramas.' }
        ]
    },
    'nombreSubpaso': {
        title: 'Nombre del Subpaso',
        subtitle: 'Identificador Técnico',
        desc: 'El nombre técnico de la acción específica que se realizará en la pantalla.',
        bullets: [
            { label: 'Referencia visual:', text: 'Es el texto que lee el operador en la pantalla si no puede escuchar al agente.' }
        ]
    },
    'instruccionVoz': {
        title: 'Instrucción de Voz',
        subtitle: 'El guion del Agente',
        desc: 'El texto exacto, letra por letra, que Gemma le hablará al panadero a través del auricular.',
        bullets: [
            { label: 'Claridad:', text: 'Usa oraciones cortas y directas.' },
            { label: 'Tono:', text: 'Gemma ajustará su énfasis dependiendo de la Criticidad de este paso.' }
        ]
    },
    'tHumano': {
        title: 'Tiempo Humano',
        subtitle: 'Trabajo Físico',
        desc: 'Minutos que el operador requiere estar interactuando físicamente con los ingredientes o la máquina.',
        bullets: [
            { label: 'Métricas:', text: 'Afecta el cálculo de productividad y costo humano.' }
        ]
    },
    'tAutonomo': {
        title: 'Tiempo Autónomo',
        subtitle: 'Proceso Automático',
        desc: 'Minutos que la masa o máquina trabaja sola (ej. Fermentación, Batido).',
        bullets: [
            { label: 'Alertas:', text: 'Gemma usará este tiempo como temporizador y avisará cuando concluya.' }
        ]
    },
    'recurso': {
        title: 'Recurso Asignado',
        subtitle: 'Ubicación Física',
        desc: 'La máquina o mesa específica donde el panadero debe pararse.',
        bullets: [
            { label: 'Dirección:', text: 'Gemma dirá: "Ve a la Mesa 1" basada en este campo.' }
        ]
    },
    'nivelCritico': {
        title: 'Nivel de Criticidad',
        subtitle: 'Tono y Urgencia',
        desc: 'Define qué tan grave es equivocarse en este paso.',
        bullets: [
            { label: 'Modulación de Voz:', text: 'Si es ALTO, Gemma hablará más fuerte y enfática para asegurar atención total.' }
        ]
    },
    'operarioLibre': {
        title: 'Estado del Operario (Libre / Ocupado)',
        subtitle: 'Control de Multitasking',
        desc: 'Determina si el panadero debe permanecer físicamente en esta máquina (Ocupado) o si puede retirarse a realizar otra tarea (Libre).',
        bullets: [
            { label: 'Ocupado:', text: 'El panadero está anclado a la estación de trabajo prestando atención al proceso.' },
            { label: 'Libre:', text: 'Gemma dirá "Tienes X minutos libres, puedes avanzar otra receta" optimizando los tiempos muertos.' }
        ]
    },
    'confirmacionVoz': {
        title: 'Confirmación por Voz',
        subtitle: 'Escucha Activa',
        desc: 'Gemma esperará a que el panadero responda verbalmente (ej. "Listo" o "Hecho") antes de dictar el siguiente paso.',
        bullets: [
            { label: 'Uso:', text: 'Actívalo en pesajes críticos o cuando el panadero cambie de máquina.' }
        ]
    },
    'triggerInicio': {
        title: 'Trigger de Inicio',
        subtitle: 'Detonador del Paso',
        desc: 'La condición exacta que hace que Gemma comience a hablar o inicie el paso actual.',
        bullets: [
            { label: 'Autonomía:', text: 'Un paso no arrancará hasta que este evento se cumpla en el sistema.' }
        ]
    },
    'preguntaQA': {
        title: 'Pregunta de Calidad (QA)',
        subtitle: 'Validación Activa',
        desc: 'Pregunta específica de verificación que Gemma hará al finalizar el paso.',
        bullets: [
            { label: 'Auditoría:', text: 'Gemma podría preguntar: "¿A qué temperatura quedó la masa?"' }
        ]
    },
    'tipCoaching': {
        title: 'Tip de Coaching',
        subtitle: 'Pista Sensorial Extra',
        desc: 'Consejo de experto panadero que Gemma soltará de forma preventiva.',
        bullets: [
            { label: 'Ejemplo:', text: '"Recuerda que la masa debe verse lisa y brillante antes de sacarla".' }
        ]
    },
    'grupoInseparable': {
        title: 'Grupo Inseparable',
        subtitle: 'Pasos Vinculados',
        desc: 'Un ID en común para agrupar pasos que NO pueden interrumpirse entre sí.',
        bullets: [
            { label: 'Seguridad:', text: 'Evita que el sistema mande a un panadero a hacer otra cosa a la mitad de un amasado crítico.' }
        ]
    },
    'temperaturaObjetivo': {
        title: 'Temperatura Objetivo',
        subtitle: 'Parámetro Crítico',
        desc: 'Temperatura ideal (°C) a la que debe estar la masa al terminar este paso.',
        bullets: [
            { label: 'Verificación:', text: 'Gemma instruirá al panadero usar el termómetro y alcanzar esta meta térmica.' }
        ]
    },
    'senalesCompletado': {
        title: 'Señales Visuales/Táctiles',
        subtitle: 'Evaluación Organoléptica',
        desc: '¿Cómo se ve o se siente la masa si el paso se ejecutó perfectamente?',
        bullets: [
            { label: 'Orientación:', text: 'Gemma dice: "Busca que desarrolle la clásica red de gluten translúcida".' }
        ]
    },
    'erroresComunes': {
        title: 'Errores Comunes',
        subtitle: 'Prevención de Mermas',
        desc: 'Peligros típicos en este paso. Gemma advertirá sobre ellos antes de empezar.',
        bullets: [
            { label: 'Ejemplo:', text: '"No sobrebatas o quemarás irremediablemente la levadura".' }
        ]
    },
    'ingredientesRequeridos': {
        title: 'Ingredientes y Porcentajes',
        subtitle: 'Dosificación Técnica',
        desc: 'Selecciona los ingredientes específicos de la receta y el porcentaje de participación en este subpaso.',
        bullets: [
            { label: 'Precisión:', text: 'Permite al Agente Gemma dar instrucciones de pesaje exactas.' },
            { label: 'Filtro BOM:', text: 'Solo muestra ingredientes que diste de alta en la pestaña RECETA.' }
        ]
    },
    'dependenciaPasoPrevio': {
        title: 'Dependencia Obligatoria',
        subtitle: 'Orden Lógico Estricto',
        desc: 'ID o nombre de un paso que DEBE estar 100% terminado antes de iniciar este.',
        bullets: [
            { label: 'Flujo de Producción:', text: 'Impide que Gemma adelante el proceso si la etapa previa (ej. Prefermento) no ha concluido.' }
        ]
    }
};

export const ProcesoProduccionMasaUI = ({ masaId, masaNombre, theme, onClose, onSave, onSaveDB, initialData, recipeMatrix }) => {
    // If theme is not provided (safety fallback), we use a default neutral theme
    const activeTheme = theme || { bg: '#f3f4f6', input: '#ffffff', text: '#1f2937', border: '#e5e7eb' };

    // Initial state matching the 28-column schema we defined
    const [infoModalField, setInfoModalField] = useState(null);
    const [equipments, setEquipments] = useState([]);
    const [saveStatus, setSaveStatus] = useState('idle'); // 'idle' | 'saving' | 'saved'
    const [subpasoToDelete, setSubpasoToDelete] = useState(null);
    const [pasoToDelete, setPasoToDelete] = useState(null);

    useEffect(() => {
        const fetchEquipments = async () => {
            try {
                const resp = await fetch(`${API_BASE}/production/equipment`);
                if (resp.ok) setEquipments(await resp.json());
            } catch (e) { console.error('Error fetching equipments:', e); }
        };
        fetchEquipments();
    }, []);

    const FieldLabel = ({ id, text, isMain = false }) => (
        <div className="flex items-center gap-2 mb-1">
            <label style={{ color: activeTheme.text }} className={`${isMain ? 'text-[10px]' : 'text-xs'} font-black uppercase tracking-widest opacity-80 flex items-center`}>
                {text}
            </label>
            <button 
                onClick={(e) => { e.stopPropagation(); setInfoModalField(id); }}
                className="w-4 h-4 rounded-full bg-orange-500 text-white flex items-center justify-center hover:scale-125 transition-all shadow-sm shrink-0"
                title="Saber más"
            >
                <Info size={10} fill="currentColor" />
            </button>
        </div>
    );

    const DualTimeInput = ({ value, onChange }) => {
        const totalMinutes = parseFloat(value) || 0;
        const mins = Math.floor(totalMinutes);
        const secs = Math.round((totalMinutes - mins) * 60);

        const updateTime = (m, s) => {
            const final = parseFloat(m) + (parseFloat(s) / 60);
            onChange(final.toFixed(4)); // Alta precisión para evitar errores de redondeo
        };

        return (
            <div className="flex items-center gap-2 bg-black/10 p-1 rounded-2xl border border-black/10 shadow-inner">
                <div className="flex-1 flex flex-col">
                    <input 
                        type="number" 
                        min="0"
                        placeholder="0"
                        style={{ color: activeTheme.text }} 
                        value={mins || ''} 
                        onChange={e => updateTime(e.target.value || 0, secs)} 
                        className="w-full bg-transparent p-2 outline-none font-black text-center text-sm placeholder-black/20" 
                    />
                    <span className="text-[8px] uppercase font-black text-center -mt-1 pb-1 opacity-60" style={{ color: activeTheme.text }}>MIN.</span>
                </div>
                <div className="font-black text-xl mb-3 opacity-30" style={{ color: activeTheme.text }}>:</div>
                <div className="flex-1 flex flex-col">
                    <input 
                        type="number" 
                        min="0"
                        max="59"
                        placeholder="0"
                        style={{ color: activeTheme.text }} 
                        value={secs || ''} 
                        onChange={e => {
                            let s = parseInt(e.target.value) || 0;
                            if (s > 59) s = 59;
                            updateTime(mins, s);
                        }} 
                        className="w-full bg-transparent p-2 outline-none font-black text-center text-sm placeholder-black/20" 
                    />
                    <span className="text-[8px] uppercase font-black text-center -mt-1 pb-1 opacity-60" style={{ color: activeTheme.text }}>SEG.</span>
                </div>
            </div>
        );
    };
    const [pasos, setPasos] = useState(() => {
        const masaName = masaId || 'la masa en cuestión';
        const defaultInstruccion = `Revisa la orden. ¿Cuántas preparaciones de ${masaName} harás hoy?`;
        const defaultQA = `¿Cuántas preparaciones de ${masaName} harás hoy?`;

        if (initialData && initialData.length > 0) {
            const data = JSON.parse(JSON.stringify(initialData));
            if (data[0].subpasos && data[0].subpasos.length > 0) {
                const sub = data[0].subpasos[0];
                if (sub.instruccionVoz?.includes('¿Cuántas preparaciones harás hoy?') || sub.instruccionVoz?.includes('¿Cuántas preparaciones de masa') || sub.instruccionVoz?.includes('¿Cuántas preparaciones de MASA')) {
                    sub.instruccionVoz = defaultInstruccion;
                    sub.preguntaQA = defaultQA;
                }
            }
            return data;
        }

        return [
            {
                id: '1',
                nombre: 'IDENTIFICAR EL MEP',
                idBloque: 'G-MASA-15',
                isExpanded: true,
                subpasos: [
                    {
                        id: '1.1',
                        nombre: 'Revisar orden de producción',
                        instruccionVoz: defaultInstruccion,
                        tHumano: 1.0,
                        tAutonomo: 0.0,
                        recurso: '',
                        recursoConfigs: {},
                        nivelCritico: 'bajo',
                        operarioLibre: false,
                        confirmacionVoz: true,
                        triggerInicio: 'inicio_turno',
                        preguntaQA: defaultQA,
                        tipCoaching: '',
                        grupoInseparable: '',
                        temperaturaObjetivo: '',
                        senalesCompletado: '',
                        erroresComunes: '',
                        ingredientesRequeridos: '',
                        dependenciaPasoPrevio: '',
                        showAdvanced: false
                    }
                ]
            }
        ];
    });

    const fileInputRef = useRef(null);

    const handleExport = () => {
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(pasos, null, 2));
        const downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href", dataStr);
        downloadAnchorNode.setAttribute("download", `config_agente_${masaId || 'plantilla'}.json`);
        document.body.appendChild(downloadAnchorNode);
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
    };

    const handleExportCSV = () => {
        const headers = [
            "Paso_ID", "Nombre_Paso", "Grupo_Maquinaria",
            "Subpaso_ID", "Nombre_Subpaso", "Instruccion_Voz",
            "T_Humano_min", "T_Autonomo_min", "Recurso", "Config_Recurso", "Nivel_Critico",
            "Operario_Libre", "Confirmacion_Voz", "Trigger_Inicio",
            "Pregunta_QA", "Tip_Coaching", "Grupo_Inseparable",
            "Temperatura_Objetivo", "Senales_Completado", "Errores_Comunes",
            "Ingredientes", "Dependencia"
        ];

        let csvContent = headers.join(",") + "\n";

        pasos.forEach(paso => {
            const pasoId = `"${paso.id || ''}"`;
            const nombrePaso = `"${(paso.nombre || '').replace(/"/g, '""')}"`;
            const grupo = `"${(paso.idBloque || '').replace(/"/g, '""')}"`;

            if (paso.subpasos && paso.subpasos.length > 0) {
                paso.subpasos.forEach(sp => {
                    const row = [
                        pasoId, nombrePaso, grupo,
                        `"${sp.id || ''}"`,
                        `"${(sp.nombre || '').replace(/"/g, '""')}"`,
                        `"${(sp.instruccionVoz || '').replace(/"/g, '""')}"`,
                        sp.tHumano || 0,
                        sp.tAutonomo || 0,
                        `"${(sp.recurso || '').replace(/"/g, '""')}"`,
                        `"${(JSON.stringify(sp.recursoConfigs || {})).replace(/"/g, '""')}"`,
                        `"${(sp.nivelCritico || '').replace(/"/g, '""')}"`,
                        sp.operarioLibre ? "SI" : "NO",
                        sp.confirmacionVoz ? "SI" : "NO",
                        `"${(sp.triggerInicio || '').replace(/"/g, '""')}"`,
                        `"${(sp.preguntaQA || '').replace(/"/g, '""')}"`,
                        `"${(sp.tipCoaching || '').replace(/"/g, '""')}"`,
                        `"${(sp.grupoInseparable || '').replace(/"/g, '""')}"`,
                        `"${(sp.temperaturaObjetivo || '').replace(/"/g, '""')}"`,
                        `"${(sp.senalesCompletado || '').replace(/"/g, '""')}"`,
                        `"${(sp.erroresComunes || '').replace(/"/g, '""')}"`,
                        `"${(sp.ingredientesRequeridos || '').replace(/"/g, '""')}"`,
                        `"${(sp.dependenciaPasoPrevio || '').replace(/"/g, '""')}"`
                    ];
                    csvContent += row.join(",") + "\n";
                });
            } else {
                const row = [pasoId, nombrePaso, grupo, "","","","","","","","","","","","","","","","","","",""];
                csvContent += row.join(",") + "\n";
            }
        });

        // BOM para asegurar que Excel lea UTF-8 (Acentos y Ñ) correctamente
        const blob = new Blob(["\uFEFF" + csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", `config_agente_${masaId || 'reporte'}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    const handleImportClick = () => {
        if (fileInputRef.current) {
            fileInputRef.current.click();
        }
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                const importedData = JSON.parse(event.target.result);
                if (Array.isArray(importedData)) {
                    setPasos(importedData);
                    e.target.value = null; 
                } else {
                    alert("El archivo no tiene el formato correcto (se esperaba un arreglo de pasos).");
                }
            } catch (err) {
                alert("Error al leer el archivo JSON: " + err.message);
            }
        };
        reader.readAsText(file);
    };

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

    const handleRecursoConfigChange = (pasoId, subpasoId, key, value) => {
        setPasos(pasos.map(p => {
            if (p.id !== pasoId) return p;
            return {
                ...p,
                subpasos: p.subpasos.map(sp => {
                    if (sp.id !== subpasoId) return sp;
                    return { 
                        ...sp, 
                        recursoConfigs: { ...(sp.recursoConfigs || {}), [key]: value } 
                    };
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
                    nombre: 'Nuevo Subpaso',
                    instruccionVoz: '',
                    tHumano: 0.5,
                    tAutonomo: 0.0,
                    recurso: '',
                    recursoConfigs: {},
                    nivelCritico: 'bajo',
                    operarioLibre: false,
                    confirmacionVoz: true,
                    triggerInicio: 'confirmacion_anterior',
                    preguntaQA: '',
                    tipCoaching: '',
                    grupoInseparable: '',
                    temperaturaObjetivo: '',
                    senalesCompletado: '',
                    erroresComunes: '',
                    ingredientesRequeridos: '',
                    dependenciaPasoPrevio: '',
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
            <input 
                type="file" 
                ref={fileInputRef} 
                style={{ display: 'none' }} 
                accept=".json" 
                onChange={handleFileChange} 
            />
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
                    <div className="flex items-center gap-4">
                        <div className="flex gap-2 mr-4 border-r border-black/10 pr-4">
                            <button 
                                onClick={handleImportClick}
                                style={{ color: activeTheme.text, backgroundColor: 'rgba(0,0,0,0.05)' }}
                                className="px-4 py-3 rounded-2xl hover:bg-black/10 flex items-center gap-2 font-black uppercase text-[10px] tracking-widest transition-all"
                                title="Importar configuración desde un archivo JSON"
                            >
                                <Upload size={14} /> Importar
                            </button>
                            <button 
                                onClick={handleExport}
                                style={{ color: activeTheme.text, backgroundColor: 'rgba(0,0,0,0.05)' }}
                                className="px-4 py-3 rounded-2xl hover:bg-black/10 flex items-center gap-2 font-black uppercase text-[10px] tracking-widest transition-all"
                                title="Exportar configuración a un archivo JSON"
                            >
                                <Download size={14} /> JSON
                            </button>
                            <button 
                                onClick={handleExportCSV}
                                style={{ color: '#10b981', backgroundColor: '#ecfdf5' }}
                                className="px-4 py-3 rounded-2xl hover:bg-[#d1fae5] flex items-center gap-2 font-black uppercase text-[10px] tracking-widest transition-all shadow-sm border border-[#a7f3d0]"
                                title="Exportar configuración a Excel (CSV)"
                            >
                                <Download size={14} /> Excel
                            </button>
                        </div>
                        <button 
                            onClick={onClose}
                            style={{ color: activeTheme.text, borderColor: activeTheme.text }}
                            className="px-6 py-3 border-2 rounded-2xl hover:opacity-70 flex items-center gap-2 font-black uppercase text-xs tracking-widest transition-all"
                        >
                            <ArrowLeft size={16} /> Volver
                        </button>
                        <button 
                            onClick={async () => { 
                                setSaveStatus('saving');
                                try {
                                    if(onSaveDB) await onSaveDB(pasos);
                                    else if(onSave) onSave(pasos);
                                    setSaveStatus('saved');
                                    setTimeout(() => { setSaveStatus('idle'); onClose(); }, 1000);
                                } catch(e) {
                                    setSaveStatus('idle');
                                }
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
                            <div className="flex-1 flex flex-col max-w-[500px]">
                                <FieldLabel id="nombrePaso" text="Nombre del Paso Principal" isMain />
                                <input 
                                    type="text" 
                                    style={{ color: activeTheme.text }}
                                    className="w-full p-3 border border-black/5 rounded-xl bg-white/50 focus:bg-white outline-none transition-all font-black text-sm" 
                                    value={paso.nombre}
                                    onChange={e => setPasos(pasos.map(p => p.id === paso.id ? {...p, nombre: e.target.value} : p))}
                                />
                            </div>
                            <div className="flex-1 flex flex-col max-w-[200px]">
                                <FieldLabel id="grupoMaquinaria" text="Grupo Maquinaria" isMain />
                                <input 
                                    type="text" 
                                    style={{ color: activeTheme.text }}
                                    placeholder="Ej. G-MASA-15"
                                    className="w-full p-3 border border-black/5 rounded-xl bg-white/50 focus:bg-white outline-none transition-all font-black text-sm placeholder-black/30" 
                                    value={(!paso.idBloque || String(paso.idBloque).toUpperCase() === 'NAN') ? '' : paso.idBloque}
                                    onChange={e => setPasos(pasos.map(p => p.id === paso.id ? {...p, idBloque: e.target.value} : p))}
                                />
                            </div>
                            <div className="flex-1"></div>
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setPasoToDelete({ id: paso.id, nombre: paso.nombre });
                                }}
                                className="w-10 h-10 rounded-xl bg-red-500/10 text-red-500 flex items-center justify-center hover:bg-red-500 hover:text-white transition-all mr-2 shrink-0"
                                title="Eliminar Paso Principal"
                            >
                                <X size={20} />
                            </button>
                            {paso.isExpanded ? <ChevronDown size={24} style={{ color: activeTheme.text }} className="shrink-0" /> : <ChevronRight size={24} style={{ color: activeTheme.text }} className="shrink-0" />}
                        </div>

                        {/* Step Body (Subpasos) */}
                        {paso.isExpanded && (
                            <div className="p-8 bg-white/40 border-t border-black/5">
                                <h4 style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest mb-6 flex items-center gap-2 opacity-70">
                                    <ListOrdered size={16} /> LISTA DE SUBPASOS
                                </h4>

                                {paso.subpasos.map((sp, spIndex) => {
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
                                                {/* ========================================= */}
                                                {/* SÚPER SECCIÓN: PARÁMETROS DEL SUBPASO     */}
                                                {/* ========================================= */}
                                                <div>
                                                    <h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1 mb-4">
                                                        Parámetros del Subpaso
                                                    </h5>
                                                    <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                                                        <div className="col-span-2 flex flex-col">
                                                            <FieldLabel id="nombreSubpaso" text="Nombre del Subpaso" />
                                                            <div className="flex gap-2">
                                                                <div style={{ backgroundColor: activeTheme.text, color: '#fff' }} className="flex items-center justify-center px-4 rounded-xl font-black text-lg shadow-md shrink-0 tracking-widest">
                                                                    {index + 1}.{spIndex + 1}
                                                                </div>
                                                                <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nombre} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nombre', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm flex-1 min-w-0" />
                                                            </div>
                                                        </div>
                                                        <div className="flex flex-col col-span-2 md:col-span-1 lg:col-span-1">
                                                            <FieldLabel id="triggerInicio" text="Trigger de Inicio" />
                                                            <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.triggerInicio} onChange={e => handleSubpasoChange(paso.id, sp.id, 'triggerInicio', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm truncate">
                                                                <option value="confirmacion_anterior">Confirmación Anterior</option>
                                                                <option value="inicio_turno">Inicio de Turno</option>
                                                                <option value="fin_temporizador">Fin Temporizador Autónomo</option>
                                                                <option value="temp_alcanzada">Temperatura Alcanzada</option>
                                                                <option value="paso_externo">Fin de Paso en Otra Masa</option>
                                                                <option value="hora_fija">Hora Fija / Programada</option>
                                                            </select>
                                                        </div>
                                                        <div className="flex flex-col col-span-2 md:col-span-1 lg:col-span-1">
                                                            <FieldLabel id="dependenciaPasoPrevio" text="Dependencia (Opc.)" />
                                                            <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.dependenciaPasoPrevio || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'dependenciaPasoPrevio', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm truncate">
                                                                <option value="">Ninguno</option>
                                                                <option value="inmediato_anterior">Inmediato Anterior</option>
                                                            </select>
                                                        </div>
                                                        <div className="flex flex-col col-span-2 md:col-span-1 lg:col-span-1">
                                                            <FieldLabel id="grupoInseparable" text="Grupo Inseparable" />
                                                            <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. G-VEL-1" value={sp.grupoInseparable} onChange={e => handleSubpasoChange(paso.id, sp.id, 'grupoInseparable', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm placeholder-black/30" />
                                                        </div>
                                                        <div className="flex flex-col col-span-2 md:col-span-1 lg:col-span-1">
                                                            <FieldLabel id="nivelCritico" text="Nivel de Criticidad" />
                                                            <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nivelCritico} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nivelCritico', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm truncate">
                                                                <option value="bajo">Bajo (Normal)</option>
                                                                <option value="medio">Medio (Firme)</option>
                                                                <option value="alto">Alto (Enfático)</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* ========================================= */}
                                                {/* SÚPER SECCIÓN: INTERACCIONES CON EL OPERARIO */}
                                                {/* ========================================= */}
                                                <div>
                                                    <h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1 mb-4">
                                                        Interacciones con el Operario
                                                    </h5>
                                                    
                                                    <div className="flex flex-col relative mb-4">
                                                        <FieldLabel id="instruccionVoz" text={<span><Mic size={14} className="inline mr-1"/> Instrucción de Voz Principal</span>} />
                                                        <div className="relative">
                                                            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                                <Mic size={18} style={{ color: activeTheme.text }} className="opacity-50" />
                                                            </div>
                                                            <input 
                                                                type="text" 
                                                                style={{ color: activeTheme.text, borderColor: activeTheme.text }}
                                                                value={sp.instruccionVoz} 
                                                                onChange={e => handleSubpasoChange(paso.id, sp.id, 'instruccionVoz', e.target.value)} 
                                                                className="w-full py-4 pl-12 pr-3 border rounded-xl bg-white outline-none border-l-4 font-black text-sm shadow-sm" 
                                                            />
                                                        </div>
                                                    </div>

                                                    <div style={{ backgroundColor: 'rgba(255,255,255,0.4)', borderColor: activeTheme.border }} className="flex items-center gap-6 p-3 rounded-xl border border-dashed">
                                                        <div className="flex items-center gap-2">
                                                            <label className="flex items-center gap-2 cursor-pointer">
                                                                <input type="checkbox" style={{ accentColor: activeTheme.text }} checked={sp.confirmacionVoz} onChange={e => handleSubpasoChange(paso.id, sp.id, 'confirmacionVoz', e.target.checked)} className="w-5 h-5 rounded border-black/10 cursor-pointer" />
                                                                <span style={{ color: activeTheme.text }} className="text-sm font-black uppercase tracking-widest opacity-80">Confirmación por Voz</span>
                                                            </label>
                                                            <button onClick={(e) => { e.stopPropagation(); setInfoModalField('confirmacionVoz'); }} className="w-4 h-4 rounded-full bg-orange-500 text-white flex items-center justify-center hover:scale-125 transition-all shadow-sm">
                                                                <Info size={10} fill="currentColor" />
                                                            </button>
                                                        </div>

                                                        {sp.confirmacionVoz && (
                                                            <div className="flex items-center gap-2 ml-4">
                                                                <span style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-widest opacity-50">Palabra:</span>
                                                                <select 
                                                                    style={{ color: activeTheme.text, borderColor: activeTheme.border }} 
                                                                    value={sp.palabraConfirmacion || 'listo'} 
                                                                    onChange={e => handleSubpasoChange(paso.id, sp.id, 'palabraConfirmacion', e.target.value)} 
                                                                    className="p-1 px-2 border rounded-lg bg-white outline-none font-black text-xs uppercase"
                                                                >
                                                                    <option value="hecho">HECHO</option>
                                                                    <option value="listo">LISTO</option>
                                                                    <option value="siguiente">SIGUIENTE</option>
                                                                    <option value="inicio_ciclo">INICIO CICLO</option>
                                                                </select>
                                                            </div>
                                                        )}

                                                        <div className="flex-1"></div>

                                                        <button onClick={() => toggleAdvanced(paso.id, sp.id)} style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest hover:underline flex items-center gap-1 opacity-70">
                                                            <Settings size={14} /> {sp.showAdvanced ? 'Ocultar' : 'Mostrar'} Avanzados
                                                        </button>
                                                    </div>

                                                    {sp.showAdvanced && (
                                                        <div style={{ borderColor: activeTheme.border }} className="grid grid-cols-2 gap-4 mt-2 pt-4 border-t border-dashed animate-in slide-in-from-top-2">
                                                            <div className="col-span-2"><h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1">Parámetros de Calidad y Coaching</h5></div>

                                                            <div className="flex flex-col">
                                                                <FieldLabel id="preguntaQA" text="Pregunta de Validación (QA)" />
                                                                <input type="text" placeholder="Ej. ¿A qué temperatura quedó?" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.preguntaQA || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'preguntaQA', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                            </div>
                                                            <div className="flex flex-col">
                                                                <FieldLabel id="temperaturaObjetivo" text="Temperatura Objetivo (°C)" />
                                                                <input type="text" placeholder="Ej. 24°C" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.temperaturaObjetivo || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'temperaturaObjetivo', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                            </div>

                                                            <div className="col-span-2 flex flex-col">
                                                                <FieldLabel id="tipCoaching" text="Tip de Coaching Sensorial (Voz)" />
                                                                <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. La masa debe verse brillante..." value={sp.tipCoaching} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tipCoaching', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm placeholder-black/30" />
                                                            </div>

                                                            <div className="col-span-2 flex flex-col">
                                                                <FieldLabel id="senalesCompletado" text="Señales Visuales de Completado" />
                                                                <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. Se forma una tela delgada y translúcida al estirar." value={sp.senalesCompletado || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'senalesCompletado', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm placeholder-black/30" />
                                                            </div>

                                                            <div className="col-span-2 flex flex-col">
                                                                <FieldLabel id="erroresComunes" text="Errores Comunes a Prevenir" />
                                                                <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. Sobre-batido (rompe gluten), agua muy caliente." value={sp.erroresComunes || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'erroresComunes', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm placeholder-black/30" />
                                                            </div>
                                                        </div>
                                                    )}
                                                </div>

                                                {/* ========================================= */}
                                                {/* SÚPER SECCIÓN: RECURSOS                   */}
                                                {/* ========================================= */}
                                                <div>
                                                    <h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1 mb-4">
                                                        Recursos
                                                    </h5>
                                                    
                                                    {/* SECCIÓN: RECURSO HUMANO */}
                                                    <div className="bg-white/40 border border-dashed rounded-xl p-4 mb-4" style={{ borderColor: activeTheme.border }}>
                                                        <div className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-3 text-emerald-700">Recurso Humano</div>
                                                        <div className="flex items-center justify-between gap-6">
                                                            <div className="flex flex-col w-44 shrink-0">
                                                                <FieldLabel id="tHumano" text="T. Humano" />
                                                                <DualTimeInput value={sp.tHumano} onChange={val => handleSubpasoChange(paso.id, sp.id, 'tHumano', val)} />
                                                            </div>
                                                            
                                                            {/* BOTÓN OPERARIO LIBRE / OCUPADO */}
                                                            <div className="flex flex-col items-center justify-center flex-1">
                                                                <div className="flex items-center gap-2 mt-4">
                                                                    <button 
                                                                        type="button"
                                                                        onClick={() => handleSubpasoChange(paso.id, sp.id, 'operarioLibre', !sp.operarioLibre)}
                                                                        className="relative flex items-center w-72 h-10 rounded-full bg-black/5 overflow-hidden cursor-pointer shadow-inner border border-black/10 transition-all focus:outline-none focus:ring-2 focus:ring-orange-500/50"
                                                                    >
                                                                        <div 
                                                                            className="absolute top-0 bottom-0 rounded-full transition-transform duration-300 ease-out shadow-md"
                                                                            style={{ 
                                                                                transform: sp.operarioLibre ? 'translateX(100%)' : 'translateX(0)',
                                                                                backgroundColor: sp.operarioLibre ? '#10b981' : '#f59e0b',
                                                                                margin: '2px',
                                                                                height: 'calc(100% - 4px)',
                                                                                width: 'calc(50% - 2px)'
                                                                            }}
                                                                        />
                                                                        <div className="relative z-10 flex w-full h-full text-[11px] font-black uppercase tracking-wider select-none">
                                                                            <div className={`flex-1 flex items-center justify-center transition-colors duration-300 ${!sp.operarioLibre ? 'text-white' : 'text-black/40'}`}>
                                                                                Operario Ocupado
                                                                            </div>
                                                                            <div className={`flex-1 flex items-center justify-center transition-colors duration-300 ${sp.operarioLibre ? 'text-white' : 'text-black/40'}`}>
                                                                                Operario Libre
                                                                            </div>
                                                                        </div>
                                                                    </button>
                                                                    <button onClick={(e) => { e.stopPropagation(); setInfoModalField('operarioLibre'); }} className="w-5 h-5 rounded-full bg-orange-500 text-white flex items-center justify-center hover:scale-125 transition-all shadow-sm shrink-0">
                                                                        <Info size={12} fill="currentColor" />
                                                                    </button>
                                                                </div>
                                                            </div>

                                                            <div className="flex flex-col w-44 shrink-0">
                                                                <FieldLabel id="tAutonomo" text="T. Autónomo" />
                                                                <DualTimeInput value={sp.tAutonomo} onChange={val => handleSubpasoChange(paso.id, sp.id, 'tAutonomo', val)} />
                                                            </div>
                                                        </div>
                                                        
                                                        {/* TIMELINE BAR */}
                                                        <div className="mt-4">
                                                            <div style={{ color: activeTheme.text }} className="flex justify-between text-[9px] font-black uppercase tracking-widest opacity-70 mb-1">
                                                                <span>Línea de Tiempo Estimada</span>
                                                                <span>{totalTime.toFixed(1)} min total</span>
                                                            </div>
                                                            <div className="w-full h-2 bg-slate-200 rounded-full flex overflow-hidden">
                                                                <div style={{width: `${humanPct}%`}} className="bg-amber-500 h-full transition-all" title="Humano"></div>
                                                                <div style={{width: `${autoPct}%`}} className="bg-emerald-500 h-full transition-all" title="Autónomo"></div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    {/* SECCIÓN: RECURSOS MATERIALES */}
                                                    <div className="bg-white/40 border border-dashed rounded-xl p-4 mb-4" style={{ borderColor: activeTheme.border }}>
                                                        <div className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-3 text-cyan-700">Recursos Materiales</div>
                                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                                                            <div className="flex flex-col">
                                                                <FieldLabel id="recurso" text="Recurso Asignado" />
                                                                <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recurso} onChange={e => {
                                                                    setPasos(pasos.map(p => p.id === paso.id ? {
                                                                        ...p,
                                                                        subpasos: p.subpasos.map(subp => subp.id === sp.id ? { ...subp, recurso: e.target.value, recursoConfigs: {} } : subp)
                                                                    } : p));
                                                                }} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm">
                                                                    <option value="">(Selecciona equipo)</option>
                                                                    {equipments.map(eq => (
                                                                        <option key={eq.id} value={eq.id}>{eq.name} {eq.model_ref ? `(${eq.model_ref})` : ''}</option>
                                                                    ))}
                                                                </select>
                                                            </div>
                                                            
                                                            {/* DYNAMIC RECURSO CONFIGS */}
                                                            {(() => {
                                                                const selEq = equipments.find(eq => String(eq.id) === String(sp.recurso));
                                                                if (!selEq) return null;
                                                                
                                                                let dynSpecs = selEq.dynamic_specs || {};
                                                                if (typeof dynSpecs === 'string') {
                                                                    try { dynSpecs = JSON.parse(dynSpecs); } catch(e) { dynSpecs = {}; }
                                                                }
                                                                
                                                                const tipo = dynSpecs.tipo_maquina || '';
                                                                const validTypes = ['BATIDORA', 'AMASADORA', 'REFINADORA', 'REVOLVEDORA', 'CORTADORA', 'MESA DE TRABAJO'];
                                                                const isMesa = tipo === 'MESA DE TRABAJO' || (selEq.name && selEq.name.toUpperCase().includes('MESA'));
                                                                
                                                                if (!validTypes.includes(tipo) && !dynSpecs.accesorios && !isMesa) return null;

                                                                return (
                                                                    <>
                                                                        {dynSpecs.accesorios && (
                                                                            <div className="flex flex-col">
                                                                                <FieldLabel id="accesorio" text="Accesorio a Usar" />
                                                                                <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recursoConfigs?.accesorio || ''} onChange={e => handleRecursoConfigChange(paso.id, sp.id, 'accesorio', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-sm">
                                                                                    <option value="">(Selecciona Accesorio)</option>
                                                                                    {dynSpecs.accesorios.split(',').map(a => a.trim()).filter(Boolean).map(acc => (
                                                                                        <option key={acc} value={acc}>{acc}</option>
                                                                                    ))}
                                                                                </select>
                                                                            </div>
                                                                        )}
                                                                        
                                                                        {['BATIDORA', 'AMASADORA', 'REFINADORA', 'REVOLVEDORA'].includes(tipo) && (
                                                                            <>
                                                                                <div className="flex flex-col">
                                                                                    <FieldLabel id="estado" text="Estado / Velocidad" />
                                                                                    <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recursoConfigs?.estado || ''} onChange={e => handleRecursoConfigChange(paso.id, sp.id, 'estado', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-sm">
                                                                                        <option value="">(Selecciona Estado)</option>
                                                                                        <option value="Apagado">Apagado</option>
                                                                                        <option value="Encendido">Encendido (Genérico)</option>
                                                                                        {dynSpecs.velocidades ? (
                                                                                            Array.from({ length: parseInt(dynSpecs.velocidades) || 0 }).map((_, i) => (
                                                                                                <option key={`v${i+1}`} value={`Velocidad ${i+1}`}>Velocidad {i+1}</option>
                                                                                            ))
                                                                                        ) : (
                                                                                            <>
                                                                                                <option value="Velocidad Baja">Velocidad Baja (1)</option>
                                                                                                <option value="Velocidad Media">Velocidad Media (2)</option>
                                                                                                <option value="Velocidad Alta">Velocidad Alta (3)</option>
                                                                                            </>
                                                                                        )}
                                                                                    </select>
                                                                                </div>

                                                                                {sp.recursoConfigs?.estado && sp.recursoConfigs?.estado !== 'Apagado' && (
                                                                                    <div className="flex flex-col animate-in fade-in slide-in-from-left-2 duration-300">
                                                                                        <FieldLabel id="tiempo_operacion" text="Tiempo de Operación" />
                                                                                        <DualTimeInput 
                                                                                            value={sp.recursoConfigs?.tiempo_operacion} 
                                                                                            onChange={val => handleRecursoConfigChange(paso.id, sp.id, 'tiempo_operacion', val)} 
                                                                                        />
                                                                                    </div>
                                                                                )}
                                                                            </>
                                                                        )}

                                                                        {isMesa && (
                                                                            <div className="flex flex-col">
                                                                                <FieldLabel id="cuadrante" text="Número de Cuadrante" />
                                                                                <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recursoConfigs?.cuadrante || ''} onChange={e => handleRecursoConfigChange(paso.id, sp.id, 'cuadrante', e.target.value)} className="w-full p-3 border rounded-xl bg-white outline-none font-bold text-sm">
                                                                                    <option value="">(Selecciona Cuadrante)</option>
                                                                                    {dynSpecs.cuadrantes ? (
                                                                                        Array.from({ length: parseInt(dynSpecs.cuadrantes) || 0 }).map((_, i) => (
                                                                                            <option key={`c${i+1}`} value={`Cuadrante ${i+1}`}>Cuadrante {i+1}</option>
                                                                                        ))
                                                                                    ) : (
                                                                                        <>
                                                                                            <option value="Cuadrante 1">Cuadrante 1</option>
                                                                                            <option value="Cuadrante 2">Cuadrante 2</option>
                                                                                            <option value="Cuadrante 3">Cuadrante 3</option>
                                                                                            <option value="Cuadrante 4">Cuadrante 4</option>
                                                                                            <option value="Cuadrante 5">Cuadrante 5</option>
                                                                                            <option value="Cuadrante 6">Cuadrante 6</option>
                                                                                        </>
                                                                                    )}
                                                                                </select>
                                                                            </div>
                                                                        )}
                                                                    </>
                                                                );
                                                            })()}
                                                        </div>
                                                    </div>

                                                    {/* SECCIÓN: INGREDIENTES */}
                                                    <div className="bg-white/40 border border-dashed rounded-xl p-4" style={{ borderColor: activeTheme.border }}>
                                                        <div className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-3 text-orange-700">Ingredientes</div>
                                                        <div className="flex flex-col">
                                                            <div className="space-y-2">
                                                                {(() => {
                                                                    let ings = sp.ingredientesRequeridos;
                                                                    if (typeof ings === 'string') ings = ings ? ings.split(',').map(i => ({ ingrediente: i.trim(), porcentaje: 100 })) : [];
                                                                    if (!Array.isArray(ings)) ings = [];
                                                                    
                                                                    const hiddenCols = recipeMatrix?.hidden_system_cols || [];
                                                                    const availableIngs = (recipeMatrix?.columns || [])
                                                                        .filter(c => c && c.id && c.name && !hiddenCols.includes(c.id))
                                                                        .map(c => c.name)
                                                                        .filter(Boolean);

                                                                    const usageMap = {};
                                                                    pasos.forEach(p => {
                                                                        p.subpasos?.forEach(subp => {
                                                                            let iReq = subp.ingredientesRequeridos;
                                                                            if (typeof iReq === 'string') return;
                                                                            if (Array.isArray(iReq)) {
                                                                                iReq.forEach(ir => {
                                                                                    if (ir.ingrediente && ir.unidad === '%') {
                                                                                        usageMap[ir.ingrediente] = (usageMap[ir.ingrediente] || 0) + (parseFloat(ir.porcentaje) || 0);
                                                                                    }
                                                                                });
                                                                            }
                                                                        });
                                                                    });

                                                                    return (
                                                                        <>
                                                                            {ings.map((item, idx) => (
                                                                                <div key={idx} className="flex gap-2 animate-in slide-in-from-left-2 duration-200">
                                                                                    <select 
                                                                                        value={item?.ingrediente || ''} 
                                                                                        onChange={e => {
                                                                                            const newIngs = [...ings];
                                                                                            newIngs[idx] = { ...newIngs[idx], ingrediente: e.target.value };
                                                                                            handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', newIngs);
                                                                                        }}
                                                                                        className="flex-1 p-3 border rounded-xl bg-white outline-none font-bold text-sm"
                                                                                        style={{ color: activeTheme.text, borderColor: activeTheme.border }}
                                                                                    >
                                                                                        <option value="">Seleccionar ingrediente...</option>
                                                                                        {availableIngs.map(name => (
                                                                                            <option key={name} value={name}>{name}</option>
                                                                                        ))}
                                                                                    </select>
                                                                                    <div className="flex flex-col gap-1">
                                                                                        <div style={{ borderColor: activeTheme.border }} className={`flex w-44 border-2 rounded-xl overflow-hidden h-11 bg-white shadow-sm transition-all focus-within:ring-2 ${parseFloat(usageMap[item.ingrediente]) > 100 ? 'ring-red-500/20 border-red-500' : 'focus-within:ring-orange-500/20'}`}>
                                                                                            <input 
                                                                                                type="number" 
                                                                                                placeholder="0" 
                                                                                                value={item?.porcentaje || ''} 
                                                                                                onChange={e => {
                                                                                                    const newIngs = [...ings];
                                                                                                    newIngs[idx] = { ...newIngs[idx], porcentaje: e.target.value };
                                                                                                    handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', newIngs);
                                                                                                }}
                                                                                                className="w-full min-w-0 bg-transparent px-3 py-1 font-mono font-black text-sm outline-none text-right"
                                                                                                style={{ color: activeTheme.text }}
                                                                                            />
                                                                                            <div className="relative w-20 h-full flex items-center justify-center border-l border-black/10 bg-black/5 shrink-0 group">
                                                                                                <div style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase text-center px-1 pointer-events-none break-words w-full leading-[0.8] tracking-tighter opacity-80">
                                                                                                    {item?.unidad || '%'}
                                                                                                </div>
                                                                                                <select 
                                                                                                    value={item?.unidad || '%'} 
                                                                                                    onChange={e => {
                                                                                                        const newIngs = [...ings];
                                                                                                        newIngs[idx] = { ...newIngs[idx], unidad: e.target.value };
                                                                                                        handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', newIngs);
                                                                                                    }}
                                                                                                    className="absolute inset-0 opacity-0 cursor-pointer w-full"
                                                                                                >
                                                                                                    <option style={{ color: '#000' }} value="%">%</option>
                                                                                                    <option style={{ color: '#000' }} value="g">g</option>
                                                                                                    <option style={{ color: '#000' }} value="kg">kg</option>
                                                                                                    <option style={{ color: '#000' }} value="ml">ml</option>
                                                                                                    <option style={{ color: '#000' }} value="L">L</option>
                                                                                                    <option style={{ color: '#000' }} value="PZA">PZA</option>
                                                                                                    <option style={{ color: '#000' }} value="BOLSA">BOLSA</option>
                                                                                                    <option style={{ color: '#000' }} value="SUBBOLSA">SUBB</option>
                                                                                                    <option style={{ color: '#000' }} value="BOTE">BOTE</option>
                                                                                                </select>
                                                                                            </div>
                                                                                        </div>
                                                                                        {item.ingrediente && item.unidad === '%' && (() => {
                                                                                            const totalUsed = usageMap[item.ingrediente] || 0;
                                                                                            const otherStepsUsage = totalUsed - (parseFloat(item.porcentaje) || 0);
                                                                                            const remaining = Math.max(0, 100 - otherStepsUsage);
                                                                                            
                                                                                            if (totalUsed > 100) {
                                                                                                return (
                                                                                                    <div className="flex items-center gap-1 text-[9px] font-black text-red-600 animate-pulse">
                                                                                                        <AlertTriangle size={10} /> EXCESO: {totalUsed}% USADO
                                                                                                    </div>
                                                                                                );
                                                                                            }
                                                                                            return (
                                                                                                <div className="text-[9px] font-black opacity-40 uppercase tracking-widest pl-2">
                                                                                                    Remanente: {remaining}% disponible
                                                                                                </div>
                                                                                            );
                                                                                        })()}
                                                                                    </div>
                                                                                    <button 
                                                                                        onClick={() => {
                                                                                            const newIngs = ings.filter((_, i) => i !== idx);
                                                                                            handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', newIngs);
                                                                                        }}
                                                                                        className="p-3 text-red-500 hover:bg-red-50 rounded-xl transition-colors"
                                                                                    >
                                                                                        <Trash2 size={16} />
                                                                                    </button>
                                                                                </div>
                                                                            ))}
                                                                            <button 
                                                                                onClick={() => {
                                                                                    const newIngs = [...ings, { ingrediente: '', porcentaje: 100 }];
                                                                                    handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', newIngs);
                                                                                }}
                                                                                className="text-[10px] font-black uppercase tracking-widest text-orange-600 flex items-center gap-1 hover:underline p-2"
                                                                            >
                                                                                <Plus size={14} /> Añadir Ingrediente de Receta
                                                                            </button>
                                                                        </>
                                                                    );
                                                                })()}
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                            </div>
                                            
                                            {/* Actions Side */}
                                            <div className="flex flex-col gap-2 pt-1">
                                                <button onClick={async () => { 
                                                    setSaveStatus('saving');
                                                    try {
                                                        if(onSaveDB) await onSaveDB(pasos);
                                                        else if(onSave) onSave(pasos);
                                                        setSaveStatus('saved');
                                                        setTimeout(() => setSaveStatus('idle'), 1500);
                                                    } catch (e) {
                                                        setSaveStatus('idle');
                                                    }
                                                }} style={{ color: '#10b981', borderColor: '#a7f3d0' }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-emerald-50 transition-all shadow-sm" title="Guardar Respaldo Rápido">
                                                    <Save size={16} />
                                                </button>
                                                <button style={{ color: activeTheme.text, borderColor: activeTheme.border }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-white transition-all shadow-sm" title="Duplicar">
                                                    <Copy size={16} />
                                                </button>
                                                <button onClick={() => setSubpasoToDelete({ pasoId: paso.id, subpasoId: sp.id, nombre: sp.nombre })} style={{ color: '#ef4444', borderColor: '#fca5a5' }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-red-50 transition-all shadow-sm" title="Eliminar">
                                                    <X size={18} />
                                                </button>
                                            </div>
                                        </div>
                                    );
                                })}

                                <button onClick={() => addSubpaso(paso.id)} style={{ color: activeTheme.text, borderColor: activeTheme.border }} className="w-full py-4 border-2 border-dashed rounded-xl font-black text-[10px] uppercase tracking-widest hover:bg-black/5 transition-colors flex items-center justify-center gap-2">
                                    <Plus size={16} /> Agregar Subpaso
                                </button>
                            </div>
                        )}
                    </div>
                ))}

                <button onClick={addPaso} style={{ color: activeTheme.text, backgroundColor: activeTheme.input, borderColor: activeTheme.border }} className="w-full py-6 border-2 border-dashed rounded-3xl font-black text-sm uppercase tracking-widest hover:scale-[1.01] transition-all flex items-center justify-center gap-2 shadow-sm mb-20">
                    <Plus size={20} /> AGREGAR NUEVO PASO PRINCIPAL
                </button>
            </div>

            {/* DYNAMIC INFO MODAL */}
            {infoModalField && FIELD_INFO_DATA[infoModalField] && (() => {
                const info = FIELD_INFO_DATA[infoModalField];
                return (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-black/60 backdrop-blur-md animate-in fade-in duration-300" onClick={() => setInfoModalField(null)}>
                        <div 
                            style={{ backgroundColor: activeTheme.input }} 
                            className="w-full max-w-xl rounded-[40px] p-10 border border-black/10 shadow-2xl relative overflow-hidden max-h-[90vh] overflow-y-auto"
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="absolute top-0 left-0 w-full h-2 bg-orange-500 shadow-[0_0_20px_rgba(249,115,22,0.5)]"></div>
                            <div className="flex justify-between items-start mb-8">
                                <div className="flex items-center gap-4">
                                    <div className="w-14 h-14 shrink-0 rounded-2xl bg-orange-500/10 flex items-center justify-center text-orange-500">
                                        <Info size={32} />
                                    </div>
                                    <div>
                                        <h3 style={{ color: activeTheme.text }} className="text-3xl font-black italic uppercase tracking-tighter leading-tight">{info.title}</h3>
                                        <p className="text-[10px] font-black uppercase tracking-[0.4em] text-orange-500/60 mt-1">{info.subtitle}</p>
                                    </div>
                                </div>
                                <button onClick={() => setInfoModalField(null)} className="w-10 h-10 shrink-0 bg-black/5 flex items-center justify-center rounded-full transition-all hover:bg-red-500 hover:text-white">
                                    <X size={24} />
                                </button>
                            </div>
                            
                            <div className="space-y-6">
                                <div className="p-6 bg-orange-500/5 rounded-[30px] border border-orange-500/10">
                                    <p style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-[0.2em] mb-2 opacity-50">¿Qué es exactamente?</p>
                                    <p style={{ color: activeTheme.text }} className="text-lg font-bold leading-tight italic">
                                        {info.desc}
                                    </p>
                                </div>
                                
                                {info.bullets && info.bullets.length > 0 && (
                                    <div className="p-6 bg-black/5 rounded-[30px]">
                                        <p style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-[0.2em] mb-4 opacity-50">Impacto en Producción</p>
                                        <ul style={{ color: activeTheme.text }} className="text-base font-bold space-y-4 list-none">
                                            {info.bullets.map((b, idx) => (
                                                <li key={idx} className="flex gap-3">
                                                    <div className="w-1.5 h-1.5 rounded-full bg-orange-500 mt-2 shrink-0"></div>
                                                    <span><span className="text-orange-600 uppercase tracking-tighter italic mr-1">{b.label}</span> {b.text}</span>
                                                </li>
                                            ))}
                                        </ul>
                                    </div>
                                )}
                            </div>

                            <button 
                                onClick={() => setInfoModalField(null)}
                                style={{ backgroundColor: activeTheme.text, color: activeTheme.bg }}
                                className="w-full mt-10 py-6 rounded-[25px] font-black text-sm uppercase tracking-[0.3em] hover:scale-[1.02] active:scale-95 transition-all shadow-2xl shadow-black/20"
                            >
                                Entendido, cerrar guía
                            </button>
                        </div>
                    </div>
                );
            })()}

            {/* SAVE STATUS MODAL */}
            {saveStatus !== 'idle' && (
                <div className="fixed inset-0 z-[200] flex items-center justify-center p-6 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
                    <div className="bg-white rounded-[30px] p-8 shadow-2xl flex flex-col items-center justify-center min-w-[300px] border border-black/10">
                        {saveStatus === 'saving' ? (
                            <>
                                <Loader2 size={48} className="animate-spin text-emerald-500 mb-4" />
                                <h3 className="text-xl font-black italic uppercase text-slate-800 tracking-tighter">Guardando...</h3>
                                <p className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mt-2">Respaldando progreso</p>
                            </>
                        ) : (
                            <>
                                <div className="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mb-4">
                                    <Save size={32} className="text-emerald-500" />
                                </div>
                                <h3 className="text-xl font-black italic uppercase text-slate-800 tracking-tighter">¡Guardado!</h3>
                                <p className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 mt-2">Respaldo exitoso</p>
                            </>
                        )}
                    </div>
                </div>
            )}

            {/* DELETE CONFIRMATION MODAL (SUBPASO) */}
            {subpasoToDelete && (
                <div className="fixed inset-0 z-[200] flex items-center justify-center p-6 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
                    <div style={{ backgroundColor: activeTheme.input }} className="max-w-md w-full rounded-[30px] p-8 shadow-2xl border border-black/10 relative overflow-hidden text-center">
                        <div className="absolute top-0 left-0 w-full h-2 bg-red-500"></div>
                        <div className="w-20 h-20 bg-red-50 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
                            <AlertTriangle size={40} />
                        </div>
                        <h3 style={{ color: activeTheme.text }} className="text-2xl font-black italic uppercase tracking-tighter mb-2">
                            ¿Borrar Subpaso?
                        </h3>
                        <p className="text-sm font-bold opacity-70 mb-6" style={{ color: activeTheme.text }}>
                            Estás a punto de eliminar el subpaso <span className="text-red-500 uppercase">"{subpasoToDelete.nombre}"</span>. Esta acción no se puede deshacer.
                        </p>
                        <div className="flex gap-4">
                            <button 
                                onClick={() => setSubpasoToDelete(null)}
                                style={{ color: activeTheme.text, borderColor: activeTheme.border }}
                                className="flex-1 py-4 rounded-2xl font-black text-xs uppercase tracking-widest border-2 hover:bg-black/5 transition-colors"
                            >
                                Cancelar
                            </button>
                            <button 
                                onClick={() => {
                                    removeSubpaso(subpasoToDelete.pasoId, subpasoToDelete.subpasoId);
                                    setSubpasoToDelete(null);
                                }}
                                className="flex-1 py-4 rounded-2xl font-black text-xs uppercase tracking-widest bg-red-500 text-white hover:bg-red-600 hover:scale-[1.02] active:scale-95 transition-all shadow-lg shadow-red-500/30"
                            >
                                Sí, borrar
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* DELETE CONFIRMATION MODAL (PASO PRINCIPAL) */}
            {pasoToDelete && (
                <div className="fixed inset-0 z-[210] flex items-center justify-center p-6 bg-black/60 backdrop-blur-md animate-in fade-in duration-200">
                    <div style={{ backgroundColor: activeTheme.input }} className="max-w-md w-full rounded-[30px] p-8 shadow-2xl border border-black/10 relative overflow-hidden text-center">
                        <div className="absolute top-0 left-0 w-full h-2 bg-red-600"></div>
                        <div className="w-20 h-20 bg-red-100 text-red-600 rounded-full flex items-center justify-center mx-auto mb-6">
                            <AlertTriangle size={40} />
                        </div>
                        <h3 style={{ color: activeTheme.text }} className="text-2xl font-black italic uppercase tracking-tighter mb-2">
                            ¿Eliminar Paso Principal?
                        </h3>
                        <p className="text-sm font-bold opacity-70 mb-6" style={{ color: activeTheme.text }}>
                            Borrarás el paso <span className="text-red-600 uppercase font-black">"{pasoToDelete.nombre}"</span> y TODOS sus subpasos asociados. Esta acción es definitiva.
                        </p>
                        <div className="flex gap-4">
                            <button 
                                onClick={() => setPasoToDelete(null)}
                                style={{ color: activeTheme.text, borderColor: activeTheme.border }}
                                className="flex-1 py-4 rounded-2xl font-black text-xs uppercase tracking-widest border-2 hover:bg-black/5 transition-colors"
                            >
                                Mantener
                            </button>
                            <button 
                                onClick={() => {
                                    setPasos(pasos.filter(p => p.id !== pasoToDelete.id));
                                    setPasoToDelete(null);
                                }}
                                className="flex-1 py-4 rounded-2xl font-black text-xs uppercase tracking-widest bg-red-600 text-white hover:bg-red-700 hover:scale-[1.02] active:scale-95 transition-all shadow-lg shadow-red-600/30"
                            >
                                Confirmar Borrado
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
