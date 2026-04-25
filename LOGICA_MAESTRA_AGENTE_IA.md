# 🤖 DOCUMENTO MAESTRO: LÓGICA DEL AGENTE DE IA (COACH)

Este documento es una **DIRECTIVA TÉCNICA** obligatoria para cualquier IA o desarrollador que trabaje en el módulo de producción. Define cómo debe operar el Coach de IA y qué reglas son inamovibles.

## 1. FILOSOFÍA DEL SISTEMA: "EL RITMO" (ARREANDO)
El Agente de IA no es un simple observador; es quien dicta el ritmo de la planta.
- **Modo Pacing:** El Agente tiene el control del tiempo. Al agotarse el tiempo de un subpaso, DEBE lanzar proactivamente la pregunta de confirmación.
- **Fast-Track (Adelantamiento):** El operario puede "vencer" al reloj. Si dice la palabra de confirmación antes de que el tiempo termine, el Agente debe reaccionar de inmediato, ignorar el resto del temporizador y proceder a la confirmación.

## 2. PARÁMETROS GLOBALES (ESTRUCTURA CORE)
Los parámetros definidos en la suite de **Parámetros Generales** son **GLOBALES**.
- **Impacto:** Un cambio en la palabra "VOY" o el tiempo de "REPREGUNTAR" afecta a **TODAS** las masas y procesos de la planta.
- **Persistencia:** Se almacenan en la tabla `SystemSetting`. 
- **Keys Obligatorias:**
    - `ai_agent_start_word`: Palabra para iniciar actividad.
    - `ai_agent_completion_word`: Palabra para terminar actividad.
    - `ai_agent_pause_word`: Palabra para pausar/esperar.
    - `ai_agent_start_retry_mins`: Tiempo de reintento si no hay respuesta al inicio.
    - `ai_agent_completion_retry_mins`: Tiempo de reintento si no hay respuesta al fin.

## 3. PROTOCOLO DE INTERACCIÓN (FLUJO DE VOZ)
Cualquier modificación en el motor de voz debe seguir este flujo:
1. **Detección de Palabra Clave:** (Operario dice "LISTO") o **Fin de Tiempo**.
2. **Pregunta de Validación:** El Agente pregunta: "Si terminaste di 'LISTO', si no di 'PAUSA'".
3. **Doble Confirmación:** Solo si el operario vuelve a decir la palabra clave, se marca el paso como completado.
4. **Bucle de Pausa:** Si el operario dice la palabra de pausa o no responde en el tiempo de reintento, el Agente vuelve a preguntar tras el lapso definido en la suite global.

## 4. REGLAS DE ORO (NO TOCAR / NO MODIFICAR)
- **NO HARDCODE:** Nunca escribas palabras como "VOY" o "LISTO" directamente en el código de producción. Siempre deben leerse del estado global sincronizado con el backend.
- **ESTÉTICA INDUSTRIAL:** Los componentes `GlobalAgentSettingsUI.jsx` y los botones de acceso en `DoughManagerUI.jsx` deben mantener su diseño de alta densidad, bordes redondeados (30px-40px) y paletas de colores basadas en el tema de la masa.
- **Z-INDEX:** La suite global debe permanecer en `z-[110]` o superior para evitar quedar atrapada detrás de los modales del Wizard.
- **SYNCHRONICITY:** Cualquier cambio en la suite debe propagarse a los dos renglones de configuración (Inicio y Cumplimiento) simultáneamente si comparten el parámetro (como la Palabra de Pausa).

---
**ESTADO DEL DOCUMENTO:** V1.0 - ACTIVADO
**AUTOR:** Antigravity (Advanced Agentic Coding AI)
