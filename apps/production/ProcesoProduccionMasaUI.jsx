import React, { useState, useRef } from 'react';
import { 
    ArrowLeft, Save, ChevronDown, ChevronRight, Plus, 
    Trash2, Copy, GripVertical, Settings, Mic, ListOrdered, Info, X, Download, Upload, Table
} from 'lucide-react';

const FIELD_INFO_DATA = {
    'grupoMaquinaria': {
        title: 'Grupo Maquinaria',
        subtitle: 'Manual de Operación de Planta',
        desc: 'Es el Nombre y Apellido de la estación o máquina donde ocurre este paso (ej. G-MAS-15).',
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
        title: 'Operario Libre',
        subtitle: 'Multitasking',
        desc: 'Si está activo, significa que el panadero puede soltar esta máquina e ir a hacer otra masa u orden.',
        bullets: [
            { label: 'Optimización:', text: 'Gemma dirá "Tienes X minutos libres, puedes avanzar otra receta".' }
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
        title: 'Ingredientes Requeridos',
        subtitle: 'Mise en place',
        desc: 'Qué debe tener el panadero a la mano ANTES de arrancar el paso.',
        bullets: [
            { label: 'Checklist:', text: 'Gemma enumerará esto primero para evitar pausas indeseadas luego.' }
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

export const ProcesoProduccionMasaUI = ({ masaId, masaNombre, theme, onClose, onSave, initialData }) => {
    // If theme is not provided (safety fallback), we use a default neutral theme
    const activeTheme = theme || { bg: '#f3f4f6', input: '#ffffff', text: '#1f2937', border: '#e5e7eb' };

    // Initial state matching the 28-column schema we defined
    const [infoModalField, setInfoModalField] = useState(null);

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
                    preguntaQA: '¿Cuántas preparaciones harás hoy?',
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
    ]);

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
            "T_Humano_min", "T_Autonomo_min", "Recurso", "Nivel_Critico",
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
                const row = [pasoId, nombrePaso, grupo, "","","","","","","","","","","","","","","","","",""];
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
                    recurso: 'MESA-TRABAJO-01',
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
                                    <ListOrdered size={16} /> LISTA DE SUBPASOS
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
                                                    <div className="col-span-2 flex flex-col">
                                                        <FieldLabel id="nombreSubpaso" text={`${sp.id} Nombre del Subpaso`} />
                                                        <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nombre} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nombre', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                    </div>
                                                    <div className="col-span-3 flex flex-col relative">
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
                                                </div>

                                                {/* ROW 2: Numbers & Resources */}
                                                <div className="grid grid-cols-4 gap-4">
                                                    <div className="flex flex-col">
                                                        <FieldLabel id="tHumano" text="T. Humano (min)" />
                                                        <input type="number" step="0.1" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.tHumano} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tHumano', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                    </div>
                                                    <div className="flex flex-col">
                                                        <FieldLabel id="tAutonomo" text="T. Autónomo (min)" />
                                                        <input type="number" step="0.1" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.tAutonomo} onChange={e => handleSubpasoChange(paso.id, sp.id, 'tAutonomo', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                    </div>
                                                    <div className="flex flex-col">
                                                        <FieldLabel id="recurso" text="Recurso Asignado" />
                                                        <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.recurso} onChange={e => handleSubpasoChange(paso.id, sp.id, 'recurso', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm">
                                                            <option value="MESA-TRABAJO-01">Mesa de Trabajo 1</option>
                                                            <option value="BATIDORA-01">Batidora 1</option>
                                                            <option value="REVOLVEDORA-01">Revolvedora 1</option>
                                                            <option value="REFINADORA-01">Refinadora 1</option>
                                                            <option value="BASCULA-01">Báscula 1</option>
                                                            <option value="RACK-FERMENTO-01">Rack de Fermento 1</option>
                                                        </select>
                                                    </div>
                                                    <div className="flex flex-col">
                                                        <FieldLabel id="nivelCritico" text="Nivel de Criticidad" />
                                                        <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.nivelCritico} onChange={e => handleSubpasoChange(paso.id, sp.id, 'nivelCritico', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm">
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
                                                    
                                                    <div className="flex items-center gap-2">
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
                                                        <button onClick={(e) => { e.stopPropagation(); setInfoModalField('operarioLibre'); }} className="w-4 h-4 rounded-full bg-orange-500 text-white flex items-center justify-center hover:scale-125 transition-all shadow-sm">
                                                            <Info size={10} fill="currentColor" />
                                                        </button>
                                                    </div>

                                                    <div style={{ backgroundColor: activeTheme.border }} className="h-5 w-px"></div>

                                                    <div className="flex items-center gap-2">
                                                        <label className="flex items-center gap-2 cursor-pointer">
                                                            <input type="checkbox" style={{ accentColor: activeTheme.text }} checked={sp.confirmacionVoz} onChange={e => handleSubpasoChange(paso.id, sp.id, 'confirmacionVoz', e.target.checked)} className="w-5 h-5 rounded border-black/10 cursor-pointer" />
                                                            <span style={{ color: activeTheme.text }} className="text-sm font-black uppercase tracking-widest opacity-80">Confirmación por Voz</span>
                                                        </label>
                                                        <button onClick={(e) => { e.stopPropagation(); setInfoModalField('confirmacionVoz'); }} className="w-4 h-4 rounded-full bg-orange-500 text-white flex items-center justify-center hover:scale-125 transition-all shadow-sm">
                                                            <Info size={10} fill="currentColor" />
                                                        </button>
                                                    </div>

                                                    <div className="flex-1"></div>

                                                    <button onClick={() => toggleAdvanced(paso.id, sp.id)} style={{ color: activeTheme.text }} className="text-xs font-black uppercase tracking-widest hover:underline flex items-center gap-1 opacity-70">
                                                        <Settings size={14} /> {sp.showAdvanced ? 'Ocultar' : 'Mostrar'} Avanzados
                                                    </button>
                                                </div>

                                                {sp.showAdvanced && (
                                                    <div style={{ borderColor: activeTheme.border }} className="grid grid-cols-2 gap-4 mt-2 pt-4 border-t border-dashed animate-in slide-in-from-top-2">
                                                        
                                                        {/* PARÁMETROS OPERATIVOS */}
                                                        <div className="col-span-2"><h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1">Parámetros Operativos del Agente</h5></div>
                                                        
                                                        <div className="flex flex-col">
                                                            <FieldLabel id="triggerInicio" text="Trigger de Inicio" />
                                                            <select style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.triggerInicio} onChange={e => handleSubpasoChange(paso.id, sp.id, 'triggerInicio', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm">
                                                                <option value="inicio_turno">Inicio de Turno</option>
                                                                <option value="confirmacion_anterior">Confirmación Anterior</option>
                                                                <option value="fin_temporizador">Fin de Temporizador Autónomo</option>
                                                                <option value="temp_alcanzada">Temperatura Alcanzada</option>
                                                                <option value="paso_externo">Fin de Paso en Otra Masa</option>
                                                                <option value="hora_fija">Hora Fija / Programada</option>
                                                            </select>
                                                        </div>
                                                        <div className="flex flex-col">
                                                            <FieldLabel id="dependenciaPasoPrevio" text="Dependencia (Opcional)" />
                                                            <input type="text" placeholder="Ej. Paso 1.2" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.dependenciaPasoPrevio || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'dependenciaPasoPrevio', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                        </div>

                                                        <div className="flex flex-col">
                                                            <FieldLabel id="grupoInseparable" text="Grupo Inseparable" />
                                                            <input type="text" style={{ color: activeTheme.text, borderColor: activeTheme.border }} placeholder="Ej. G-VEL-1" value={sp.grupoInseparable} onChange={e => handleSubpasoChange(paso.id, sp.id, 'grupoInseparable', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm placeholder-black/30" />
                                                        </div>
                                                        <div className="flex flex-col">
                                                            <FieldLabel id="ingredientesRequeridos" text="Ingredientes / MEP (Coma separada)" />
                                                            <input type="text" placeholder="Ej. 500g Harina, Agua helada" style={{ color: activeTheme.text, borderColor: activeTheme.border }} value={sp.ingredientesRequeridos || ''} onChange={e => handleSubpasoChange(paso.id, sp.id, 'ingredientesRequeridos', e.target.value)} className="w-full p-4 border rounded-xl bg-white outline-none font-bold text-sm" />
                                                        </div>

                                                        {/* PARÁMETROS DE CALIDAD Y COACHING */}
                                                        <div className="col-span-2 mt-4"><h5 style={{ color: activeTheme.text }} className="text-[10px] font-black uppercase tracking-[0.2em] opacity-50 border-b pb-1">Parámetros de Calidad y Coaching</h5></div>

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
                                            
                                            {/* Actions Side */}
                                            <div className="flex flex-col gap-2 pt-1">
                                                <button onClick={() => { if(onSave) onSave(pasos); }} style={{ color: '#10b981', borderColor: '#a7f3d0' }} className="p-2 border rounded-xl hover:scale-110 bg-white/50 hover:bg-emerald-50 transition-all shadow-sm" title="Guardar Respaldo Rápido">
                                                    <Save size={16} />
                                                </button>
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
        </div>
    );
};
