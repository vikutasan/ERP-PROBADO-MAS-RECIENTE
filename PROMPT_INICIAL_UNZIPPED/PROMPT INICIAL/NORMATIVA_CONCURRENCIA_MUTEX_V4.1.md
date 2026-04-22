# NORMATIVA DE CONCURRENCIA V4.1: EL MUTEX DEL CLIENTE ("ZERO-LOSS")

Este documento es una extensión normativa de `POS_TICKET_LIFECYCLE_SPEC.md` y de los principios arquitectónicos del ERP de R de Rico. 
**Cualquier Inteligencia Artificial o desarrollador que modifique el sistema en el futuro DEBE leer y respetar esta regla.**

---

## 1. El Problema: "Self-Collisions" (Condiciones de Carrera del Cliente)

Durante la implementación del Bloqueo Optimista (Optimistic Locking) mediante el campo `version` en la base de datos (v4.0), se descubrió que el sistema arrojaba "Conflictos de Versión" (*Versión Mismatch*) incluso cuando un solo cajero estaba trabajando en una terminal sin interferencia de otros usuarios.

**La causa raíz fue una Condición de Carrera (*Race Condition*) provocada por el propio cliente React:**
1. El cajero captura productos.
2. El temporizador de `useAutoSave` dispara una petición en segundo plano al backend (enviando la `version: N`).
3. Debido a latencia de red, la petición tarda unos segundos en regresar.
4. En ese instante exacto, el cajero presiona el botón "Pagar" o escanea rápidamente otro producto.
5. El sistema envía una *segunda* petición simultánea. Al no haber recibido aún la respuesta de la primera, esta segunda petición también envía la `version: N`.
6. El servidor procesa la primera petición (actualizando la DB a la `version: N+1`).
7. El servidor procesa la segunda petición, y al ver que trae la `version: N`, la rechaza asumiendo erróneamente que otro usuario modificó la cuenta.

## 2. La Solución: Serialización Asíncrona (Mutex)

Para resolver esto sin perder la inmediatez de la interfaz UI, se introdujo un candado de Exclusión Mutua (**Mutex Asíncrono**) directamente en el componente principal de tickets (`handleTicketAction`).

El código implementa el Mutex mediante una cadena de Promesas nativas de JavaScript:

```javascript
const actionMutexRef = React.useRef(Promise.resolve());

const handleTicketAction = async (status, paymentData = null, finalizeUI = true) => {
    // 1. Adquirir el candado
    const previousPromise = actionMutexRef.current;
    let releaseMutex;
    actionMutexRef.current = new Promise(resolve => releaseMutex = resolve);
    
    // 2. Esperar en fila si hay una petición en vuelo
    await previousPromise;

    try {
        // 3. REGLA CRÍTICA: Leer las Refs (estado actual) SOLO DESPUÉS de adquirir el lock.
        // Esto garantiza que si una petición previa modificó el 'ticketVersion',
        // esta nueva petición enviará la versión actualizada correcta.
        const liveVersion = ticketVersionRef.current;
        // ... ejecución del API ...
    } finally {
        // 4. Liberar el candado para el siguiente en la fila
        releaseMutex();
    }
};
```

## 3. Mandato Normativo para Desarrolladores / IA Futuras

Al modificar `RetailVisionPOS.jsx`, `handleTicketAction`, o cualquier lógica de guardado/cobro:

1. **PROHIBIDO ELIMINAR EL MUTEX:** No remuevas `actionMutexRef` ni la lógica de `await previousPromise`. Si lo haces, los cajeros comenzarán a sufrir alertas falsas de "Conflicto de Versión" y no podrán cobrar cuando el internet esté lento.
2. **PROHIBIDO LEER ESTADO ANTES DEL AWAIT:** Todas las lecturas de los punteros actuales (`cartRef.current`, `ticketVersionRef.current`, `accountNumRef.current`) deben realizarse **DENTRO** del bloque `try`, estrictamente **DESPUÉS** del `await previousPromise`. Leerlos antes capturará versiones obsoletas (*Stale Closures* de tiempo).
3. **RESPETAR LOS HOOKS:** La lógica de auto-guardado ha sido extraída a `useAutoSave.js`. Este hook debe permanecer desacoplado para mantener el SRP (Single Responsibility Principle).

## Conclusión
Esta arquitectura garantiza 0% de colisiones accidentales, 0% de sobreescrituras silenciosas (gracias a PostgreSQL y `version`), y soporte total para operativas de alta velocidad (escaneo rápido en ráfaga). No retroceder sobre estos avances.
