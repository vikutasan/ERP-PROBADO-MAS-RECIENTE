# 🛡️ PROTOCOLO MAESTRO: Ciclo de Vida del Ticket POS — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA** para cualquier IA o desarrollador antes de modificar
> CUALQUIER lógica relacionada con tickets, folios, carrito, cobros, auto-save,
> pizarrón, auditoría, o impresión.
>
> **Este documento reemplaza las versiones 3.0, 4.0 y 4.3.1.** La versión 4.5
> cierra la última vulnerabilidad de pérdida de datos: `cartRef` no se sincronizaba
> sincrónicamente en `handleRecoverAccount`, permitiendo que el auto-save sobreescribiera
> el ticket recuperado con el carrito viejo. También reemplaza la búsqueda fuzzy
> (`ilike`) de `getTicketByAccountNum` con un endpoint de búsqueda exacta.
>
> Última actualización: 2026-05-02
> Versión: 4.6 — ANTI-WIPE (STORAGE KEY SYNC)

---

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.6 (OFFLINE DATA WIPE)

**Fecha:** 02/Mayo/2026
**Síntoma:** El sistema "expulsaba" a los usuarios de sus terminales y borraba la información de los tickets que habían capturado (fenómeno reportado en Terminal 2 por sospecha de un "mal cable LAN").

**Causa raíz:** Un defecto de sincronización de estado en React (`useCart.js`). Cuando la red fallaba y el sistema se congelaba, el usuario presionaba `F5`. Al regresar y hacer clic en su terminal, el componente `useCart` se inicializaba con un carrito vacío `[]` y *antes* de cargar los datos de `localStorage`, disparaba el `useEffect` de guardado. El carrito vacío sobrescribía el ticket original en el disco local instantáneamente, y el mecanismo "anti-zombie" de la UI borraba también el folio.

**Solución Implementada (Regla 16):**
1. Implementación de una máquina de estado interna (`cartState`) que almacena explícitamente el `storageKey` junto con los artículos.
2. Un candado lógico (`if (cartState.key === storageKey)`) en el `useEffect` de guardado prohíbe las operaciones de escritura en disco a menos que el estado ya haya sido sincronizado con la llave activa del terminal.

## ⛔ INCIDENTE QUE ORIGINÓ ESTA VERSIÓN (v4.5)

**Fecha:** 21/Abril/2026 ~7:19 PM
**Ticket:** V11906 (#906)
**Síntoma:** Fernando capturó 8 productos por $124 MXN. El ticket impreso y cobrado
solo contenía 1x BOLSA BIODEGRADABLE ($2.00). Pérdida de $122 MXN en datos.

**Causa raíz:** Race condition entre el auto-save de 30 segundos y la función
`handleTicketAction`. La función leía el carrito desde un **closure de JavaScript
obsoleto** en vez de leer el valor actual desde un `useRef`. Cuando el auto-save
disparó con una versión antigua de `handleTicketAction`, envió al servidor un
carrito incorrecto (1 item) con el folio correcto (V11906), **sobreescribiendo**
los 8 items originales en la base de datos.

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.0 (ZERO-LOSS)

**Fecha:** 22/Abril/2026
**Ticket:** #125 ($205) y #169
**Síntoma:** Pérdida silenciosa del ticket #125 enviado al pizarrón (error de red silencioso) y sobrescritura cruzada del ticket #169 (dos usuarios editando la misma cuenta).

**Causa raíz:** 
1. El botón de enviar al pizarrón era "fire-and-forget" y limpiaba el carrito ANTES de confirmar el guardado. Si la red fallaba, el ticket desaparecía para siempre.
2. La falta de bloqueo optimista permitía que un usuario sobreescribiera la versión actualizada de otro.
3. El auto-save fallaba en silencio, sin avisar al usuario.

**Solución Implementada (Reglas 9 a 11):** Guardado inmediato al primer producto, bloqueo optimista con `version` en DB, auto-save visible (badge rojo), confirmación obligatoria al guardar, y protección contra cierre de pestaña (`sendBeacon`).

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.2 (ANTI-SELF-COLLISION)

**Fecha:** 22/Abril/2026
**Síntoma:** El modal "CONFLICTO DE VERSIÓN" aparecía constantemente durante la operación normal de un solo cajero, sin que ningún otro usuario estuviera editando la misma cuenta. Esto bloqueaba el flujo de trabajo y confundía al personal.

**Causa raíz:** El pipeline `setState → useEffect → ref` de React es **asíncrono**. Cuando el auto-save #1 obtenía `version=2` del servidor y lo guardaba con `setTicketVersion(2)`, el `useEffect` que sincronizaba `ticketVersionRef.current` NO se ejecutaba inmediatamente. Si el auto-save #2 se disparaba antes de que el useEffect corriera, leía `ticketVersionRef.current = 1` (stale), enviaba `version=1` al servidor, y el servidor veía `1 ≠ 2` → **HTTP 409 FALSO**.

Además, el auto-save enviaba `version` en TODAS las peticiones, activando la validación de bloqueo optimista incluso para guardados del mismo usuario en la misma terminal — un escenario donde NO existe riesgo real de conflicto.

**Solución Implementada (Regla 12 + Regla 10 actualizada):**
1. `ticketVersionRef.current` se actualiza **sincrónicamente** (ref directa) además del `setState` asíncrono.
2. `actionMutexRef` serializa todas las llamadas a `handleTicketAction` (no hay concurrencia).
3. Con mutex + sync directo, las stale-closures están eliminadas.

> **⚡ ACTUALIZACIÓN v4.3.1:** La solución original (v4.2) enviaba `version: null` en
> auto-save para evitar self-collisions. Esto dejaba una **vulnerabilidad de sobreescritura
> silenciosa multi-usuario**. Como el mutex + sync directo eliminan las stale-closures,
> ahora es seguro enviar `version` SIEMPRE. El auto-save ahora detecta conflictos reales
> y muestra el CollisionModal al operador.

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.5 (CART-REF DESYNC)

**Fecha:** 25/Abril/2026
**Ticket:** V13000 (#000)
**Síntoma:** ARELY capturó N productos en una terminal. Cuando VICTOR lo recuperó desde el Pizarrón en CAJA, el ticket impreso solo contenía 4 artículos por $31.00 (Bolsa Biodegradable, 2x Bolillo, 3x Telera, 1x Multi Coco Moka). Artículos faltantes.

**Causa raíz (4 bugs interconectados):**
1. **`cartRef` no sincronizada en `handleRecoverAccount`:** La función sincronizaba `accountNumRef`, `originalCapturerRef` y `ticketVersionRef` directamente (SYNC), pero `cartRef` solo se actualizaba vía `setCart()` → `useEffect` (ASYNC). Si el auto-save disparaba antes del useEffect, leía `cartRef.current` con el carrito **viejo** del cajero y sobreescribía los items del ticket.
2. **`isActionRunningRef` no existía:** El bloque de auto-heal del 409 referenciaba `isActionRunningRef.current = false` pero esta variable nunca fue declarada. El `ReferenceError` silencioso dentro del `requestAnimationFrame` dejaba `isRecoveringRef = true` permanentemente, deshabilitando el auto-save.
3. **`getTicketByAccountNum` usaba búsqueda fuzzy:** `ilike('%V1300%')` coincidía con V1300, V13000, V13001. El frontend tomaba `tickets[0]` que podía ser el ticket equivocado.
4. **Auto-heal del 409 no limpiaba UI:** `setIsSendingToPizarron(false)` se saltaba porque el `return` prematuro evitaba el `finally` interno.

**Solución Implementada (Reglas 14 y 15):**
1. `cartRef.current = recovered` se sincroniza ANTES de `setCart()` en `handleRecoverAccount` y en el bloque de auto-heal.
2. Referencia huérfana `isActionRunningRef` eliminada.
3. Nuevo endpoint `/tickets/by-account/{account_num}` con búsqueda exacta (`==`, no `ilike`).
4. `setIsSendingToPizarron(false)` agregado al bloque de auto-heal.

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.3 (TERMINAL OCCUPANCY HARDENING)

**Fecha:** 23/Abril/2026
**Terminal afectada:** CAJA + T4 / T6 (usuario OMEGA, ID: 20)
**Síntoma:** La sesión de OMEGA alternaba entre Terminal 4 y Terminal 6, mientras simultáneamente aparecía como ocupante de la terminal CAJA. Un mismo usuario bloqueaba 2 terminales a la vez en la pantalla de selección.

**Causa raíz (3 bugs interconectados):**
1. **CashSession sin TTL:** OMEGA abrió una sesión de caja (CashSession #110) el 21/Abril que **nunca se cerró**. El endpoint `/terminals/status` combina `terminal_locks` (con TTL de 15 min) y `cash_sessions` abiertas (**sin TTL alguno**). Resultado: la terminal CAJA quedó bloqueada permanentemente como "fantasma" por 2+ días.
2. **Doble ocupación simultánea:** La función `lock_terminal()` en `occupancy.py` limpia locks del mismo usuario en otras terminales, pero NO sabe nada de CashSessions. Cuando OMEGA seleccionaba T4 o T6, el lock se creaba ahí, pero la CashSession huérfana en CAJA seguía generando una entrada duplicada.
3. **Heartbeat sin purga:** La función `heartbeat()` solo renovaba el timestamp del lock actual sin ejecutar `_purge_stale_locks()` ni limpiar locks duplicados del mismo usuario en otras terminales.

**Solución Implementada (Regla 13):**
1. `heartbeat()` ahora ejecuta purga de locks expirados + limpieza de locks duplicados del mismo usuario en cada ciclo (cada 20s).
2. `/terminals/status` detecta cuando un usuario ya tiene lock activo en otra terminal y marca la CashSession huérfana como `"CAJA ABIERTA"` con flag `operator_absent: true`.
3. CashSessions abiertas por más de 24 horas se marcan como `"SESIÓN EXPIRADA"` con flag `stale_session: true`.

---

## 1. ARQUITECTURA GENERAL

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  TERMINAL    │────▶│  API (FastAPI)│────▶│  PostgreSQL  │
│  (React)     │◀────│  service.py   │◀────│  (DB)        │
└──────────────┘     └──────────────┘     └──────────────┘
       │                    │                     │
       ▼                    ▼                     ▼
  localStorage         _populate_           ticket_folio_seq
  useRef (CRITICO)     flat_fields()        (secuencia atómica)
  cartRef              FOR UPDATE           FOR UPDATE SKIP LOCKED
  accountNumRef        version (OL)         sendBeacon (emergency)
  ticketVersionRef
```

### Archivos Críticos y sus Responsabilidades

| Componente | Archivo | Responsabilidad |
|-----------|---------|-----------------|
| Terminal POS | `apps/pos/RetailVisionPOS.jsx` | Captura, carrito, cobro, auto-save, impresión |
| Hook de Carrito | `apps/pos/hooks/useCart.js` | Estado + localStorage del carrito |
| Servicio Frontend | `apps/pos/services/POSService.js` | HTTP client para API (v4.5: búsqueda exacta) |
| Pizarrón | `apps/pos/OpenAccountsCorkboard.jsx` | Visualización de cuentas abiertas |
| Checkout | `apps/pos/components/CheckoutScreen.jsx` | Pagos mixtos |
| Auditoría | `apps/AuditoriaControlUI.jsx` | Consulta histórica |
| Servicio Backend | `apps/api/modules/pos/service.py` | Lógica de negocio (v4.5: get_ticket_by_account_num) |
| Router Backend | `apps/api/modules/pos/router.py` | Endpoints FastAPI (v4.5: /tickets/by-account/) |
| Modelos | `apps/api/modules/pos/models.py` | SQLAlchemy ORM |
| Schemas | `apps/api/modules/pos/schemas.py` | Validación Pydantic |
| Occupancy | `apps/api/modules/pos/occupancy.py` | Candados de terminal (v4.3: heartbeat con purga) |

---

## 2. REGLAS INQUEBRANTABLES

### ⚡ REGLA 1 — REFS PARA TODO CALLBACK/TIMER (LA MÁS IMPORTANTE)

```
⛔ PROHIBIDO: Leer `cart`, `currentAccountNum`, `originalCapturer` desde closures
              dentro de handleTicketAction, auto-save, o cualquier setInterval/setTimeout
✅ OBLIGATORIO: Leer SIEMPRE desde `cartRef.current`, `accountNumRef.current`,
               `originalCapturerRef.current` dentro de cualquier función que pueda
               ser invocada asíncronamente o desde un timer
```

**¿Por qué?** En React, `useState` crea valores inmutables por render. Una función
creada en el render N captura los valores del render N en su closure. Si un
`setInterval` creado en el render N dispara en el render N+5, la función sigue
leyendo los datos del render N (DATOS OBSOLETOS).

**`useRef` NO tiene este problema** porque es un puntero mutable que siempre apunta
al valor más reciente, sin importar desde qué render se lea.

**Refs obligatorias en el componente:**
```javascript
const cartRef = React.useRef([]);
const accountNumRef = React.useRef('');
const originalCapturerRef = React.useRef(null);   // ← DEBE EXISTIR
const isGeneratingFolioRef = React.useRef(false);
const isRecoveringRef = React.useRef(false);       // ← DEBE EXISTIR
const ticketVersionRef = React.useRef(null);       // ← v4.0 ZERO-LOSS
const actionMutexRef = React.useRef(Promise.resolve()); // ← v4.1 MUTEX

// Sincronización vía useEffect (backup, NO fuente primaria para version):
React.useEffect(() => { cartRef.current = cart; }, [cart]);
React.useEffect(() => { accountNumRef.current = currentAccountNum; }, [currentAccountNum]);
React.useEffect(() => { originalCapturerRef.current = originalCapturer; }, [originalCapturer]);
React.useEffect(() => { ticketVersionRef.current = ticketVersion; }, [ticketVersion]);
// ⚠️ v4.2: ticketVersionRef TAMBIÉN se actualiza sincrónicamente en handleTicketAction
// (ver Regla 12). El useEffect es solo un backup por si acaso.
```

**Dentro de `handleTicketAction`, las siguientes líneas son OBLIGATORIAS:**
```javascript
// ✅ CORRECTO — Lee del ref (valor vivo)
items: cartRef.current.map(i => ({ product_id: i.id, quantity: i.quantity || 1 })),
captured_by_id: originalCapturerRef.current?.id || currentUser?.id || null,

// ⛔ INCORRECTO — Lee del closure (valor potencialmente muerto)
items: cart.map(i => ({ product_id: i.id, quantity: i.quantity || 1 })),
captured_by_id: originalCapturer?.id || currentUser?.id || null,
```

### ⚡ REGLA 2 — AUTO-SAVE: INTERVALO REAL, NO DEBOUNCE (v4.5)

```
⛔ PROHIBIDO: useEffect deps = [currentAccountNum, cart.length, showCheckout]
⛔ PROHIBIDO: useEffect deps = [currentAccountNum, cart, showCheckout] ← CAUSA DEBOUNCE
✅ OBLIGATORIO: useEffect deps = [currentAccountNum, showCheckout, showCollisionModal, refs]
✅ OBLIGATORIO: Leer el callback de guardado desde un useRef (onSaveRef)
```

**¿Por qué se eliminó `cart` de las dependencias?** Incluir `cart` (el array completo)
en las dependencias del useEffect REINICIA el temporizador de 15 segundos cada vez que
se agrega un producto. Si un capturista escanea productos cada 10 segundos, el auto-save
**NUNCA se ejecuta** porque el timer se destruye y se recrea antes de completar los 15s.

**Incidente real:** ARELY capturó N artículos rápidamente. El auto-save nunca disparó.
Al cambiar de cuenta, los artículos posteriores al guardado inicial se perdieron (V13000).

**¿Cómo se mantienen los datos frescos sin `cart` en las deps?** Mediante `useRef`:
```javascript
const onSaveRef = useRef(onSave);
useEffect(() => { onSaveRef.current = onSave; }, [onSave]);

useEffect(() => {
    if (!currentAccountNum || showCheckout || showCollisionModal) return;

    const autoSaveTimer = setInterval(async () => {
        if (refs.isGeneratingFolioRef.current) return;
        if (refs.isRecoveringRef.current) return;
        if (!refs.accountNumRef.current || refs.cartRef.current.length === 0) return;
        
        await onSaveRef.current();  // ⚡ Lee la versión más fresca del callback
    }, 15000);

    // ⛔ PROHIBIDO incluir 'cart' aquí
    return () => clearInterval(autoSaveTimer);
}, [currentAccountNum, showCheckout, showCollisionModal, refs]);
// ⚡ v4.5: `cart` y `onSave` ELIMINADOS — el timer es un INTERVALO REAL
```

### ⚡ REGLA 3 — RECUPERACIÓN DEL PIZARRÓN: PROTOCOLO ANTI-OVERWRITE

```
⛔ PROHIBIDO: setCart() + setCurrentAccountNum() sin bloquear auto-save
✅ OBLIGATORIO: Bloquear auto-save → mutar estado → desbloquear después de render
```

`handleRecoverAccount` DEBE seguir este protocolo exacto:
```javascript
const handleRecoverAccount = (account) => {
    if (!account.rawItems?.length) {
        setToastMessage("⚠️ Cuenta vacía.");  // ← REGLA 8: Toast, NO alert()
        setTimeout(() => setToastMessage(null), 3000);
        return;
    }

    // 1. BLOQUEAR auto-save ANTES de cualquier mutación
    isRecoveringRef.current = true;

    // 2. Reconstruir carrito desde items del pizarrón
    const recovered = account.rawItems.map(i => ({
        id: i.product.id,
        name: i.product.name,
        price: i.product.price,
        quantity: i.quantity,
        category: i.product.category?.name || 'OTROS',
        nature: i.product.nature || 'PRODUCTO'
    }));

    // 3. Mutar estado — SYNC REFS INMEDIATO antes de setState
    //    ⚡ v4.5: TODAS las refs se sincronizan antes de los setState.
    //    Incluye cartRef que antes se omitía, causando pérdida de datos (V13000).
    cartRef.current = recovered;                                // ⚡ v4.5 SYNC inmediato
    setCart(recovered);
    accountNumRef.current = account.accountNum;              // SYNC inmediato
    setCurrentAccountNum(account.accountNum);
    const capturer = account.capturedById
        ? { id: account.capturedById, name: account.capturedByName }
        : currentUser;
    originalCapturerRef.current = capturer;                  // SYNC inmediato
    setOriginalCapturer(capturer);
    ticketVersionRef.current = account.version || null;      // SYNC inmediato
    setTicketVersion(account.version || null);

    // 4. Restaurar OMS data si es pedido
    if (account.orderType === 'PEDIDO') {
        setOrderType('PEDIDO');
        setOrderData({ ... });
    } else {
        setOrderType('VENTA_DIRECTA');
        setOrderData(null);
    }

    setShowCorkboard(false);

    // 5. DESBLOQUEAR auto-save DESPUÉS de que React procese los estados
    requestAnimationFrame(() => {
        isRecoveringRef.current = false;
    });
};
```

### ⚡ REGLA 4 — GENERACIÓN DE FOLIOS: SECUENCIA ATÓMICA

```
⛔ PROHIBIDO: MAX(id) + 1, random(), uuid(), Date.now()
✅ OBLIGATORIO: SELECT nextval('ticket_folio_seq')
```

- Los folios se generan EXCLUSIVAMENTE con la secuencia PostgreSQL `ticket_folio_seq`.
- Es atómica a nivel de base de datos: 100 terminales simultáneas → 100 folios únicos.
- Formato: `V{NNNN}` (ej: `V11906`).
- Si la secuencia no existe, `_ensure_folio_sequence()` la crea automáticamente.

### ⚡ REGLA 5 — SERIALIZACIÓN: CAMINO ÚNICO

```
⛔ PROHIBIDO: Diccionarios manuales con campos hardcoded
✅ OBLIGATORIO: selectinload() + _populate_flat_fields()
```

- TODA respuesta de ticket (crear, listar, reservar, pizarrón) DEBE usar:
  1. `selectinload()` para cargar relaciones
  2. `_populate_flat_fields()` para campos virtuales
- NUNCA construir diccionarios manuales. Esto causa divergencia POS vs Auditoría.

### ⚡ REGLA 6 — CONCURRENCIA: FOR UPDATE

```
⛔ PROHIBIDO: SELECT → UPDATE sin bloqueo
✅ OBLIGATORIO: FOR UPDATE (upsert) / FOR UPDATE SKIP LOCKED (reciclaje)
```

- `_upsert_ticket_header()`: `FOR UPDATE` — bloquea fila durante upsert
- `_find_empty_ticket()`: `FOR UPDATE SKIP LOCKED` — evita colisiones en reciclaje
- Check `status == "PAID"` post-lock: si ticket ya pagado → rechazar con HTTP 400

### ⚡ REGLA 7 — `captured_by_id` DESDE EL PRIMER INSTANTE

```
⛔ PROHIBIDO: Crear ticket sin captured_by_id
✅ OBLIGATORIO: Enviar captured_by_id en reserve_ticket desde el momento 0
```

- Frontend envía `captured_by_id` en `reserveTicket(terminalId, currentUser.id)`
- Si empleado B cobra ticket de A: `captured_by_id = A`, `cashed_by_id = B`

### ⚡ REGLA 8 — UI: CERO ALERT() BLOQUEANTES

```
⛔ PROHIBIDO: alert(), confirm(), prompt() en flujo de cobro/impresión
✅ OBLIGATORIO: Toast no-bloqueante o modal React
```

- `alert()` bloquea JavaScript → interrumpe `iframe.print()`, polling, auto-save.

### ⚡ REGLA 9 — GUARDADO INMEDIATO Y CONFIRMACIÓN OBLIGATORIA (ZERO-LOSS)

```
⛔ PROHIBIDO: Limpiar el carrito (`clearCart`) sin confirmar que el servidor guardó el ticket (respuesta 200).
⛔ PROHIBIDO: Hacer clearCart() y luego intentar guardar (fire-and-forget).
✅ OBLIGATORIO: Mostrar estado de loading (`isSendingToPizarron`) y limpiar el carrito SOLO si `savedTicket` existe.
✅ OBLIGATORIO: Guardar el ticket al servidor al agregar el PRIMER producto (handleAddToCart).
```

**Flujo obligatorio del botón Pizarrón:**
```javascript
// 1. Bloquear UI
setIsSendingToPizarron(true);

// 2. Enviar al servidor y ESPERAR respuesta
const savedTicket = await handleTicketAction('OPEN', null, true);

// 3. SOLO limpiar si el servidor confirmó
if (savedTicket) {
    clearCart();
    setCurrentAccountNum('');
    toast.success('📌 Cuenta guardada exitosamente.');
} else {
    toast.error('❌ Error al guardar. Tu carrito NO se borró.');
}

// 4. Desbloquear UI
setIsSendingToPizarron(false);
```

### ⚡ REGLA 10 — BLOQUEO OPTIMISTA TOTAL (v4.3.1)

```
⛔ PROHIBIDO: Enviar `version: null` en auto-save (permite sobreescritura silenciosa multi-usuario).
⛔ PROHIBIDO: Actualizar ticketVersionRef solo con setState (async, llega tarde).
✅ OBLIGATORIO: Enviar `version: liveVersion` en TODAS las llamadas (auto-save + manuales).
✅ OBLIGATORIO: Actualizar ticketVersionRef.current SINCRÓNICAMENTE tras respuesta exitosa.
✅ OBLIGATORIO: Mostrar CollisionModal en TODO 409 (auto-save incluido).
```

- La tabla `tickets` tiene una columna `version` (INTEGER, default=1).
- Cada `_update_ticket_fields()` incrementa `version += 1`.
- `_upsert_ticket_header()` valida versión **SOLO si `ticket.version is not None`**.
- ⚡ v4.3.1: TODAS las llamadas envían `version: liveVersion` (mutex + sync directo eliminan stale-closures).
- Si conflicto → **HTTP 409** + modal `CollisionModal` (siempre, incluido auto-save).
- El guard `showCollisionModal` en `useAutoSave` pausa futuros auto-saves automáticamente.

**Código obligatorio en `handleTicketAction`:**
```javascript
// AL CONSTRUIR EL PAYLOAD:
version: liveVersion,  // ← v4.3.1: SIEMPRE enviar version (mutex elimina stale-closures)

// AL RECIBIR RESPUESTA EXITOSA:
if (savedTicket?.version) {
    ticketVersionRef.current = savedTicket.version; // SYNC: anti-stale (INMEDIATO)
    setTicketVersion(savedTicket.version);          // ASYNC: para UI de React
}

// AL CAPTURAR ERROR 409:
if (errorMessage.includes("Conflicto de versión")) {
    // v4.3.1: SIEMPRE mostrar modal. El operador DEBE re-sincronizar desde Pizarrón.
    setShowCollisionModal(true);
    throw err;
}
```

### ⚡ REGLA 11 — VISIBILIDAD DE AUTO-SAVE Y CIERRE DE NAVEGADOR

```
⛔ PROHIBIDO: Auto-save silencioso sin feedback visual al usuario.
⛔ PROHIBIDO: Permitir cerrar la pestaña con items no guardados sin advertencia.
✅ OBLIGATORIO: Badge visible de estado de guardado (⚠️ SIN GUARDAR / ✅ HH:MM).
✅ OBLIGATORIO: Listener `beforeunload` + `navigator.sendBeacon` como último recurso.
```

- Estado `lastSaveStatus`: `'unsaved'` | `'saving'` | `'saved'` | `'failed'` | `'queued'` *(v5.1)*
- Si `failed` → badge rojo parpadeante `⚠️ SIN GUARDAR` visible en el Pizarrón.
- Si `saved` → badge verde `✅ 11:05` con hora del último guardado exitoso.
- Si `queued` → badge ámbar parpadeante `📥 GUARDADO LOCAL` (v5.1: auto-save encolado offline).
- `beforeunload`: muestra diálogo nativo de advertencia si hay items no guardados.
- `sendBeacon`: envía POST a `/api/v1/pos/tickets/emergency-save` con el carrito actual.
- El endpoint de emergencia **nunca lanza excepciones** — siempre retorna 200.

### ⚡ REGLA 12 — MUTEX ANTI-SELF-COLLISION + ACTUALIZACIÓN SÍNCRONA DE VERSION (v4.2)

```
⛔ PROHIBIDO: Dos llamadas a handleTicketAction ejecutándose en paralelo.
⛔ PROHIBIDO: Actualizar ticketVersionRef SOLO con useEffect (async, llega tarde al mutex).
✅ OBLIGATORIO: Serializar TODAS las llamadas con actionMutexRef (Promise chain).
✅ OBLIGATORIO: Escribir ticketVersionRef.current = response.version INMEDIATAMENTE.
```

**¿Qué es el Mutex?** Un candado que serializa llamadas concurrentes. Si el auto-save
dispara mientras un cobro está en progreso, el auto-save ESPERA a que termine.

**¿Por qué actualización síncrona de la ref?** El pipeline de React es:
```
setState(newVersion) → re-render → useEffect → ref.current = newVersion
```
Esto puede tomar 50-200ms. Si el mutex libera y el siguiente auto-save lee la ref
ANTES de que el useEffect corra, lee el valor STALE → 409 falso.

La solución es escribir la ref DIRECTAMENTE:
```javascript
// DENTRO de handleTicketAction, DESPUÉS de recibir respuesta:
ticketVersionRef.current = savedTicket.version; // ← SÍNCRONO, INMEDIATO
setTicketVersion(savedTicket.version);           // ← Asíncrono, para UI
```

**Estructura del Mutex:**
```javascript
const actionMutexRef = React.useRef(Promise.resolve());

const handleTicketAction = async (status, paymentData, finalizeUI) => {
    // 1. Adquirir lock
    const previousPromise = actionMutexRef.current;
    let releaseMutex;
    actionMutexRef.current = new Promise(resolve => releaseMutex = resolve);
    await previousPromise;  // Espera a que la llamada anterior termine

    try {
        // 2. Leer refs DESPUÉS del lock (valores frescos)
        const liveVersion = ticketVersionRef.current;
        // ... lógica ...

        // 3. Actualizar ref SINCRÓNICAMENTE
        ticketVersionRef.current = savedTicket.version;
    } finally {
        releaseMutex(); // 4. Liberar lock para la siguiente llamada
    }
};
```

**Diagrama del problema v4.0 vs la solución v4.3.1:**
```
❌ v4.0 (ROTO — auto-save enviaba version, sin mutex):
  Auto-save#1 → envia version=1 → server guarda → responde version=2
  setState(2) ─── useEffect PENDIENTE ───┐
  Auto-save#2 → lee ref (AÚN =1!) → envia version=1 → server: 1≠2 → 409 💥
                                         │
                           useEffect corre│→ ref=2 (DEMASIADO TARDE)

❌ v4.2 (PARCIAL — auto-save enviaba null, sin protección multi-usuario):
  Auto-save#1 → envia version=null → server guarda (salta check) → version=2
  Auto-save#2 → envia version=null → server guarda (salta check) → version=3
  ⚠️ Otro usuario también envia version=null → SOBREESCRIBE sin 409 💥

✅ v4.3.1 (COMPLETO — mutex + sync directo + version siempre):
  Auto-save#1 ADQUIERE MUTEX
    → lee ref (=1) → envia version=1 → server valida 1==1 → OK → version=2
    → ref.current=2 (INMEDIATO) + setState(2)
    → LIBERA MUTEX
  Auto-save#2 ADQUIERE MUTEX
    → lee ref (=2 ✅) → envia version=2 → server valida 2==2 → OK ✅
    → LIBERA MUTEX
  Otro usuario envia version=1 → server: 1≠2 → 409 → CollisionModal ✅
```

### ⚡ REGLA 13 — OCUPACIÓN DE TERMINAL: 1 USUARIO = 1 TERMINAL (v4.3)

```
⛔ PROHIBIDO: Que un usuario aparezca como ocupante de 2+ terminales simultáneamente.
⛔ PROHIBIDO: CashSessions abiertas sin TTL máximo (causa bloqueo permanente de terminal).
⛔ PROHIBIDO: Heartbeat que solo renueve timestamp sin limpiar locks obsoletos.
✅ OBLIGATORIO: heartbeat() debe purgar locks expirados + eliminar locks del mismo usuario en otras terminales.
✅ OBLIGATORIO: /terminals/status debe deduplicar usuarios entre terminal_locks y cash_sessions.
✅ OBLIGATORIO: CashSessions >24h sin cerrar deben marcarse como "SESIÓN EXPIRADA".
```

**Archivos afectados:**
- `occupancy.py` → `heartbeat()` ahora llama `_purge_stale_locks()` y limpia locks duplicados.
- `router.py` → `get_terminals_status()` ahora detecta usuarios con lock en otra terminal y aplica TTL de 24h a CashSessions.

**Flujo del heartbeat reforzado (v4.3):**
```python
async def heartbeat(db, terminal_id, occupier_id, ttl_minutes=15):
    # 1. Purgar locks expirados de TODAS las terminales
    await _purge_stale_locks(db, ttl_minutes)
    
    # 2. Eliminar locks de este usuario en OTRAS terminales
    #    (regla 1-usuario-1-terminal)
    DELETE FROM terminal_locks 
    WHERE occupier_id = ? AND terminal_id != ?
    
    # 3. Renovar timestamp del lock actual
    UPDATE terminal_locks SET locked_at = NOW()
    WHERE terminal_id = ? AND occupier_id = ?
```

**Flujo del status reforzado (v4.3):**
```
1. Obtener locks activos de terminal_locks (con TTL normal)
2. Construir set de user IDs que ya tienen lock activo
3. Para cada CashSession OPEN:
   a. Si employee_id ya tiene lock en OTRA terminal:
      → Marcar como "NOMBRE (CAJA ABIERTA)" + operator_absent=true
   b. Si opened_at > 24 horas:
      → Marcar como "NOMBRE (SESIÓN EXPIRADA)" + stale_session=true
   c. Si ninguna condición anterior:
      → Mostrar normalmente como ocupante
```

---

## 3. FLUJO COMPLETO DEL TICKET

### 3.1 Reserva + Guardado Inmediato (v4.0)

```
1. Usuario agrega primer producto → handleAddToCart(product)
2. addToCart(product) → actualiza UI inmediatamente
3. Si !currentAccountNum → generateNewAccountNum() (asíncrono)
4. isGeneratingFolioRef.current = true (bloquea auto-save)
5. posService.reserveTicket(terminalId, currentUser.id)
6. Servidor:
   → _find_empty_ticket(terminal_id) con FOR UPDATE SKIP LOCKED
   → Si encuentra ticket vacío del MISMO terminal: lo reutiliza
   → Si no: _generate_consecutive_ticket() con nextval('ticket_folio_seq')
7. Frontend: accountNumRef.current = ticket.account_num (SYNC inmediato, v4.3.1)
8. Frontend: setCurrentAccountNum(ticket.account_num) (ASYNC, para UI)
9. Frontend: originalCapturerRef.current = capturer (SYNC inmediato, v4.3.1)
10. isGeneratingFolioRef.current = false
11. ⚡ v4.0: handleTicketAction('OPEN') — GUARDADO INMEDIATO al servidor
   → El ticket se persiste con el primer producto sin esperar al auto-save
   → Si falla: setLastSaveStatus('failed') → badge visible
```

### 3.2 Auto-Save (Pizarrón) — CADA 15 SEGUNDOS (v4.3.1)

```
1. useEffect se activa cuando cambian: currentAccountNum, cart, showCheckout, showCollisionModal
2. Si !currentAccountNum || cart.length === 0 || showCheckout || showCollisionModal → NO crear timer
3. setInterval(15000):  ← v4.0: reducido de 30s a 15s
   a. Si isGeneratingFolioRef.current → SKIP
   b. Si isRecoveringRef.current → SKIP (NUEVO — v3.0)
   c. Si !accountNumRef.current || cartRef.current.length === 0 → SKIP
   d. handleTicketAction('OPEN', null, false)  ← finalizeUI=false
      → ADQUIERE MUTEX (espera si hay otra operación en curso)
      → LEE cartRef.current (NO cart)
      → LEE accountNumRef.current (NO currentAccountNum)
      → LEE originalCapturerRef.current (NO originalCapturer)
      → ⚡ v4.3.1: ENVÍA version: liveVersion (protección multi-usuario total)
        El mutex + sync directo garantizan que la version siempre es fresca.
4. Servidor: _upsert_ticket_header() con FOR UPDATE + validación de version
   → Actualiza total, items, campos OMS, captured_by_id
   → Incrementa version += 1
5. Frontend:
   → ticketVersionRef.current = response.version (SYNC, inmediato)
   → setTicketVersion(response.version) (ASYNC, para UI)
6. setLastSaveStatus('saved') o setLastSaveStatus('failed')
7. ⚡ v4.3.1: Si ocurre un 409 → CollisionModal se muestra al operador
   → showCollisionModal pausa futuros auto-saves automáticamente
8. LIBERA MUTEX
9. El ticket aparece en el Pizarrón (get_open_tickets WHERE status=OPEN AND total>0)

**v5.1 Resiliencia Offline:**
Si en el paso 4 la conexión con el servidor falla (TypeError: Failed to fetch), y el status
es `DRAFT`, el wrapper `resilientCreateTicket()` encola el payload completo en localStorage
vía `enqueueOffline()`. El auto-save marca `setLastSaveStatus('queued')` y la UI muestra
`📥 GUARDADO LOCAL`. Cuando `useNetworkHealth` detecta `netStatus = 'good'`,
`useOfflineSync` hace flush FIFO automático de la cola.
```

### 3.3 Guardar en Pizarrón (Manual) — PROTOCOLO ZERO-LOSS (v4.0)

```
1. Usuario hace click en botón "ABRIR NUEVA CUENTA"
2. ⚡ setIsSendingToPizarron(true) → botón se bloquea, muestra "⏳ GUARDANDO..."
3. const savedTicket = await handleTicketAction('OPEN', null, true)
   → Envía items + version al servidor
4. Servidor: _upsert_ticket_header() + validación de version
5. ⚡ SI savedTicket existe (respuesta 200):
   → clearCart(), setCurrentAccountNum(''), setOriginalCapturer(null)
   → Toast verde: "📌 Cuenta guardada en el Pizarrón exitosamente."
   → setIsSendingToPizarron(false)
6. ⚡ SI savedTicket es null (error de red/servidor):
   → El carrito NO se limpia — los items permanecen en pantalla
   → Toast rojo: "❌ Error al guardar. Tu carrito NO se borró."
   → setIsSendingToPizarron(false)
   → El usuario puede reintentar
7. El capturista escribe el papelito con # de cuenta y total
```

> **⛔ CAMBIO CRÍTICO v4.0:** En versiones anteriores (v3.0 y previas), el paso 4
> hacía `clearCart()` ANTES de verificar la respuesta del servidor. Esto causó la
> pérdida del ticket #125 ($205 MXN) cuando la red falló silenciosamente.

### 3.4 Recuperación desde Pizarrón — PROTOCOLO CRÍTICO

```
1. Usuario abre Pizarrón → posService.getOpenTickets()
2. Selecciona cuenta → handleRecoverAccount(account)
3. ⚡ isRecoveringRef.current = true (BLOQUEA auto-save)
4. Reconstruye carrito desde account.rawItems
5. setCart(recovered), setCurrentAccountNum(accountNum)
6. Restaura originalCapturer del ticket original
7. Si es PEDIDO: restaura orderType + orderData
8. Cierra pizarrón
9. requestAnimationFrame → isRecoveringRef.current = false
10. El usuario puede modificar y cobrar normalmente
```

### 3.5 Cobro

```
1. Usuario abre CheckoutScreen → registra pagos
2. handleFinalize() → handleTicketAction('PAID', paymentData, true)
3. handleTicketAction LEE de refs:
   → items: cartRef.current.map(...)
   → captured_by_id: originalCapturerRef.current?.id
   → cashed_by_id: currentUser.id
4. Servidor: _upsert_ticket_header() con FOR UPDATE
   → status = 'PAID', payment_details, cashed_by_id
5. Si es PEDIDO: _create_order_from_ticket()
6. Respuesta: _get_full_ticket() con _populate_flat_fields()
7. Frontend:
   → savedTicketRef.current = savedTicket (ref inmediata)
   → handlePrintTicket(savedTicket) → genera HTML → iframe.print()
   → clearCart(), resetState()
   → Toast: "✅ Venta finalizada exitosamente"
```

### 3.6 Consulta en Auditoría

```
1. AuditoriaUI → GET /pos/tickets
2. Servidor: get_tickets() usa MISMAS opciones selectinload + _populate_flat_fields()
3. Frontend recibe datos IDÉNTICOS a los del POS
```

---

## 4. MODELO DE DATOS

### Tabla `tickets`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT PK | Auto-incremento |
| `account_num` | STRING UNIQUE | Folio (`V11906`). Generado por `ticket_folio_seq` |
| `terminal_id` | STRING | Terminal donde se creó (campo directo, NO derivado) |
| `total` | FLOAT | Total calculado por el servidor desde items |
| `status` | STRING | `DRAFT`, `OPEN`, `PAID`, `CANCELLED` |
| `version` | INT | Bloqueo optimista (se incrementa en cada update) |
| `payment_details` | JSON | Lista de pagos mixtos |
| `session_id` | FK → terminal_sessions | Sesión del terminal |
| `cash_session_id` | FK → cash_sessions | Sesión de caja |
| `captured_by_id` | FK → employees | Quién capturó la venta |
| `cashed_by_id` | FK → employees | Quién cobró la venta |
| `order_type` | STRING | `VENTA_DIRECTA` o `PEDIDO` |
| `order_status` | STRING | Estado del OMS |
| `delivery_type` | STRING | `PICKUP`, `DOMICILIO` |
| `customer_name` | STRING | Nombre del cliente |
| `customer_phone` | STRING | Teléfono |
| `committed_at` | DATETIME | Fecha compromiso |
| `packaging_type` | STRING | `PROPIO`, `VENTA` |
| `delivery_address` | STRING | Dirección |
| `order_notes` | TEXT | Notas |
| `created_at` | DATETIME | Fecha de creación |

### Tabla `ticket_items`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT PK | Auto-incremento |
| `ticket_id` | FK → tickets | Ticket padre |
| `product_id` | FK → products | Producto |
| `quantity` | INT | Cantidad |
| `unit_price` | FLOAT | Precio unitario (snapshot) |
| `subtotal` | FLOAT | quantity × unit_price |

### Campos Virtuales (`_populate_flat_fields`)

| Campo | Fuente |
|-------|--------|
| `terminal_id` | `ticket.terminal_id` → fallback: `ticket.session.terminal_id` |
| `captured_by_name` | `ticket.captured_by.name` → fallback: `"SISTEMA"` |
| `cashed_by_name` | Si DRAFT/OPEN: `"--- PENDIENTE ---"` / Si PAID: `ticket.cashed_by.name` → fallback: `"SISTEMA/AUTO"` |

---

## 5. BACKEND: FUNCIONES CRÍTICAS Y SUS CONTRATOS

### `_upsert_ticket_header()` — service.py
- **Input:** account_num, items, status, captured_by_id, cashed_by_id, **version** (v4.0)
- **Comportamiento:**
  1. `SELECT ... FOR UPDATE` por account_num → bloquea la fila
  2. Si existe y `status == 'PAID'` → **rechaza con HTTP 400** (idempotencia)
  3. ⚡ v4.0: Si existe y `ticket.version != payload.version` → **rechaza con HTTP 409** (conflicto optimista)
  4. Si existe y `status != 'PAID'` → `_update_ticket_fields()` → `version += 1`
  5. Si no existe → `_initialize_new_ticket()` con `version = 1`
- **NUNCA modificar sin FOR UPDATE**

### `_sync_ticket_items()` — service.py
- **PELIGRO:** Esta función **ELIMINA items** que no estén en el payload.
  Si el frontend envía 1 item cuando el ticket tenía 8, los 7 restantes **SE BORRAN**.
- Esto es comportamiento correcto SI el payload tiene los datos correctos.
- Por eso es VITAL que `handleTicketAction` lea de `cartRef.current`, no de un closure.

### `_find_empty_ticket()` — service.py
- Busca tickets con `status=OPEN`, `total=0`, `terminal_id=X`
- Usa `FOR UPDATE SKIP LOCKED` → si otra terminal ya bloqueó uno, salta al siguiente
- SOLO recicla tickets del MISMO terminal

### `_populate_flat_fields()` — service.py
- Puebla `terminal_id`, `captured_by_name`, `cashed_by_name`
- TODA respuesta de ticket DEBE pasar por aquí
- Si se agrega un campo virtual nuevo → agregarlo aquí

---

## 6. GARBAGE COLLECTION

- `_cleanup_stale_empty_tickets()` elimina tickets con:
  - `status = OPEN` **o** `status = DRAFT`
  - `total = 0`
  - Sin items
  - `created_at` > 24 horas de antigüedad
- Throttled: máximo 1 ejecución por minuto
- Se ejecuta automáticamente al reservar un ticket
- ⚡ v5.0: El GC limpia ambos estados para no acumular borradores vacíos huérfanos

---

## 7. CHECKLIST OBLIGATORIO ANTES DE MODIFICAR CÓDIGO

Antes de hacer CUALQUIER cambio en el flujo de tickets:

- [ ] ¿Las funciones asíncronas/timers leen de **refs** (`cartRef`, `accountNumRef`, `originalCapturerRef`, `ticketVersionRef`), NO de closures de state?
- [ ] ¿TODAS las llamadas a `handleTicketAction` envían `version: liveVersion`? (REGLA 10 v4.3.1)
- [ ] ¿El CollisionModal se muestra en TODO 409 (incluido auto-save)? (REGLA 10 v4.3.1)
- [ ] ¿`ticketVersionRef.current` se actualiza SINCRÓNICAMENTE tras respuesta exitosa? (REGLA 12)
- [ ] ¿`handleTicketAction` está envuelto en el mutex (`actionMutexRef`)? (REGLA 12)
- [ ] ¿`generateNewAccountNum` sincroniza `accountNumRef` y `originalCapturerRef` inmediatamente? (v4.3.1)
- [ ] ¿`handleRecoverAccount` sincroniza TODAS las refs inmediatamente (accountNum, originalCapturer, ticketVersion)? (v4.3.1)
- [ ] ¿El botón Pizarrón espera la confirmación del servidor ANTES de hacer `clearCart()`?
- [ ] ¿Existe feedback visual explícito si el auto-save falla?
- [ ] ¿El useEffect del auto-save tiene dependencia en **`cart`** (array completo), NO en `cart.length`?
- [ ] ¿`handleRecoverAccount` activa `isRecoveringRef` ANTES de mutar estado y lo desactiva DESPUÉS del render?
- [ ] ¿El folio se genera exclusivamente con `nextval('ticket_folio_seq')`?
- [ ] ¿La serialización usa `selectinload()` + `_populate_flat_fields()`?
- [ ] ¿Los queries de escritura usan `FOR UPDATE`?
- [ ] ¿Se envía `captured_by_id` desde la reserva?
- [ ] ¿Los mensajes usan toast, NO `alert()`?
- [ ] ¿El campo `terminal_id` se graba directo en el modelo?
- [ ] ¿Cualquier campo virtual nuevo se agrega a `_populate_flat_fields()`?
- [ ] ¿Los datos de Auditoría y POS pasan por el MISMO código?
- [ ] ¿El `heartbeat()` purga locks expirados y limpia locks del mismo usuario en otras terminales? (REGLA 13)
- [ ] ¿El endpoint `/terminals/status` deduplica usuarios entre `terminal_locks` y `cash_sessions`? (REGLA 13)
- [ ] ¿Las CashSessions >24h se marcan como expiradas? (REGLA 13)
- [ ] ¿El `useEffect` que guarda el `localStorage` del carrito está protegido contra inicializaciones estáticas usando un candado de `cartState.key`? (v4.6 Anti-Wipe)
- [ ] ¿Los tickets nuevos se crean con `status = 'DRAFT'` (no `OPEN`)? (REGLA 16 v5.0)
- [ ] ¿El auto-save envía `status: 'DRAFT'` para cuentas en captura? (REGLA 16)
- [ ] ¿El botón "Abrir Nueva Cuenta" envía `status: 'OPEN'` para publicar al Pizarrón? (REGLA 16)
- [ ] ¿El endpoint `/tickets/drafts/{terminal_id}` se consulta al login de terminal? (REGLA 16)
- [ ] ¿El DRAFT Guard en `_upsert_ticket_header` impide cobrar DRAFTs desde otra terminal? (REGLA 16)
- [ ] ¿`handleTicketAction` usa `resilientCreateTicket()` para envolver `posService.createTicket()`? (REGLA 17 v5.1)
- [ ] ¿Solo operaciones DRAFT se encolan offline? PAID y OPEN fallan ruidosamente (REGLA 17 v5.1)
- [ ] ¿`useOfflineSync` está integrado y recibe `netStatus`, `createTicketFn`, `ticketVersionRef`? (REGLA 17)
- [ ] ¿El banner de MODO OFFLINE se muestra cuando `offlinePending > 0`? (REGLA 17)
- [ ] ¿La cola offline expira entradas > 10 minutos automáticamente? (REGLA 17)

---

## 8. ERRORES QUE CAUSARON PÉRDIDA DE DATOS EN PRODUCCIÓN

| Error | Consecuencia Real | Cómo Prevenirlo |
|-------|-------------------|-----------------|
| `cart.map()` dentro de `handleTicketAction` en vez de `cartRef.current.map()` | **Ticket #906: $124 → $2** — Auto-save envió carrito viejo del closure | REGLA 1: SIEMPRE usar refs |
| Auto-save con dependencia `cart.length` en vez de `cart` | Timer no se reinicia al cambiar contenido del carrito (misma cantidad, items diferentes) | REGLA 2: Dependencia debe ser `cart` |
| `handleRecoverAccount` sin bloquear auto-save | Auto-save puede disparar entre `setCart()` y el render, enviando datos mixtos | REGLA 3: `isRecoveringRef` |
| Diccionario manual en `get_tickets()` | Auditoría mostraba datos diferentes al POS | REGLA 5: `_populate_flat_fields()` |
| `alert()` después de cobro | Impresión bloqueada | REGLA 8: Toast |
| `SELECT → UPDATE` sin `FOR UPDATE` | Race condition entre auto-save y cobro simultáneo | REGLA 6: FOR UPDATE |
| Crear ticket sin `captured_by_id` | Auditoría mostraba "SISTEMA" en vez del empleado real | REGLA 7: Desde reserva |
| `clearCart()` antes de confirmar respuesta del servidor | **Ticket #125: $205 perdidos** — Red falló, carrito se borró, ticket nunca llegó al servidor | REGLA 9: Confirmar 200 antes de limpiar |
| Sin bloqueo optimista (`version`) | **Ticket #169: sobrescritura cruzada** — Dos usuarios editaron la misma cuenta, el último borró los cambios del primero | REGLA 10: `version` en cada update |
| Auto-save fallaba en silencio | Usuario no sabía que su ticket no se había guardado. Continuaba trabajando creyendo que estaba respaldado | REGLA 11: Badge visual obligatorio |
| Auto-save enviaba `version` al servidor (v4.0) | **Modal "CONFLICTO DE VERSIÓN" aparecía constantemente** sin que otro usuario editara la cuenta. El pipeline async de React (setState→useEffect→ref) causaba lecturas stale de `ticketVersionRef` | REGLA 12: Mutex serializa llamadas + ref se actualiza sincrónicamente. v4.3.1 envía `version` siempre (mutex elimina stale-closures) |
| Auto-save enviaba `version: null` (v4.2) | **Sobreescritura silenciosa multi-usuario** — Dos terminales editaban la misma cuenta, el auto-save de una sobreescribía el trabajo de la otra sin 409 | REGLA 10 v4.3.1: SIEMPRE enviar `version: liveVersion` + CollisionModal en todo 409 |
| `generateNewAccountNum` no sincronizaba refs | **Folios huérfanos** — `handleTicketAction` leía `accountNumRef` vacío y generaba un segundo folio duplicado | v4.3.1: Sync inmediato de `accountNumRef` y `originalCapturerRef` antes de setState |
| `handleRecoverAccount` no sincronizaba todas las refs | **409 falsos post-recuperación** — `requestAnimationFrame` se disparaba antes del `useEffect` sync, auto-save leía refs stale | v4.3.1: Sync inmediato de `accountNumRef`, `originalCapturerRef`, `ticketVersionRef` |
| CashSession sin cerrar bloqueaba terminal permanentemente | **OMEGA aparecía en CAJA + T4/T6 simultáneamente** durante 2+ días. La sesión de caja #110 nunca se cerró y no tenía TTL, causando un candado fantasma permanente en la pantalla de selección | REGLA 13: TTL de 24h para CashSessions + deduplicación de usuarios + heartbeat con purga |
| `handleRecoverAccount` no sincronizaba `cartRef` | **Ticket V13000: artículos faltantes** — ARELY capturó items, VICTOR recuperó desde Pizarrón, auto-save envió carrito viejo de VICTOR sobreescribiendo items de ARELY | REGLA 14 v4.5: `cartRef.current = recovered` ANTES de `setCart()` |
| `getTicketByAccountNum` usaba búsqueda fuzzy `ilike` | **Recuperación de ticket equivocado** — `ilike('%V1300%')` podía devolver V13000 o V13001 en vez de V1300 | REGLA 15 v4.5: Endpoint exacto `/tickets/by-account/{account_num}` |
| `isActionRunningRef` nunca declarada | **Mutex bloqueado permanentemente** — ReferenceError silencioso en auto-heal del 409 dejaba `isRecoveringRef = true`, deshabilitando auto-save | v4.5: Referencia eliminada. El mutex se libera en `finally` con `releaseMutex()` |
| Tickets nacen como `OPEN` (visible al Pizarrón de inmediato) | **Incidente V17484→V17485 (06/May/2026)** — OMEGA invocó desde el Pizarrón una cuenta de ALICIA que aún estaba en captura. El sistema auto-reasignó el folio al detectar colisión, confundiendo a ambas operadoras | REGLA 16 v5.0: Tickets nacen como `DRAFT` (invisibles). Solo aparecen en Pizarrón al enviar explícitamente → `OPEN` |
| Auto-save fallaba silenciosamente al caerse la red | **Pérdida potencial de items en captura** — Si la red se caía durante >15s, los auto-saves consecutivos fallaban sin persistir. El capturista seguía trabajando creyendo que sus datos se guardaban, pero no había protección local | REGLA 17 v5.1: `resilientCreateTicket()` encola payloads DRAFT en localStorage. `useOfflineSync` hace flush automático al restablecerse la red. Banner `⚠️ MODO OFFLINE` alerta al operador |

---

## 9. ANATOMÍA DE UN RACE CONDITION (CASO REAL #906)

```
TIMELINE:

T=0s    Fernando agrega 8 productos ($124) en T2, folio V11906
T=5s    Auto-save o manual save → V11906 tiene 8 items en DB ✅
T=6s    Fernando escribe papelito "#906 $124"
T=7s    clearCart() → carrito vacío, folio vacío

T=10s   Siguiente cliente: se agrega 1x BOLSA ($2) al carrito
T=10s   generateNewAccountNum() → obtiene V11907 (nuevo folio)

        ⚠️ PERO: El setInterval del auto-save del ciclo anterior puede seguir
        corriendo si cart.length no cambió (dependencia incorrecta).
        Y la función handleTicketAction capturada por ese timer tiene
        cart=[BOLSA] y currentAccountNum='V11906' en su CLOSURE.

T=30s   ⛔ AUTO-SAVE DISPARA con función del closure viejo:
        → Envía: { account_num: 'V11906', items: [BOLSA] }
        → Servidor: _sync_ticket_items() BORRA los 7 items extra
        → V11906 ahora solo tiene 1x BOLSA ($2) 💀

T=60s   Víctor cobra V11906 desde pizarrón
        → Imprime ticket con $2.00 en vez de $124.00
```

**Con las REGLAS 1, 2, y 3 aplicadas:**
```
T=30s   ✅ Auto-save lee cartRef.current (que es [BOLSA para V11907])
        ✅ Auto-save lee accountNumRef.current (que es 'V11907')
        ✅ Envía: { account_num: 'V11907', items: [BOLSA] }
        ✅ V11906 NUNCA se toca → permanece con 8 items ($124) ✅
```

---

## REGLAS NUEVAS v4.5

*(Ver secciones 14 y 15 más abajo — estas reglas preexistían antes del incidente V17484)*

---

## REGLA 16 — DRAFT: CAPTURA INVISIBLE HASTA CONFIRMACIÓN EXPLÍCITA (v5.0)

```
⛔ PROHIBIDO: Crear tickets con status='OPEN' desde el backend.
⛔ PROHIBIDO: Auto-save enviando status='OPEN' (hace visible la cuenta en Pizarrón prematuramente).
⛔ PROHIBIDO: Cobrar (→PAID) un DRAFT desde una terminal diferente a la que lo creó.
✅ OBLIGATORIO: Tickets nuevos (reserve_ticket) y auto-save envían status='DRAFT'.
✅ OBLIGATORIO: Solo el botón "ABRIR NUEVA CUENTA" (usuario explícito) envía status='OPEN'.
✅ OBLIGATORIO: Al login de terminal, consultar /tickets/drafts/{terminal_id} y mostrar OrphanDraftModal.
```

**¿Por qué?** El Pizarrón mostraba tickets que el capturista **aún estaba editando**.
Un cajero podía invocar una cuenta incompleta desde otra terminal, cobrarla, y al detectar
la colisión el sistema auto-reasignaba el folio — confundiendo a ambos operadores
(Incidente real: ALICIA en T5 → OMEGA en TCAJA → V17484 reasignado a V17485, 06/May/2026).

**Flujo correcto v5.0:**
```
  Capturista agrega productos
       ↓
  auto-save → DRAFT (invisible al Pizarrón)
  [el cajero NO puede ver esta cuenta]
       ↓
  Capturista termina de capturar
  Click "ABRIR NUEVA CUENTA"
       ↓
  handleTicketAction('OPEN') → OPEN (visible al Pizarrón) ✅
  [el cajero ve la cuenta lista, con todos los productos]
       ↓
  Cajero invoca → cobra → folio correcto, sin reasignaciones ✅
```

**DRAFT Guard en `_upsert_ticket_header()` (service.py):**
```python
# Un DRAFT solo puede cobrarse (→PAID) desde la MISMA terminal que lo creó.
# Si otra terminal intenta cobrar un DRAFT → HTTP 400.
if db_ticket.status == "DRAFT" and ticket.status == "PAID":
    if safe_req_terminal != safe_db_terminal:
        raise HTTPException(400,
            f"El folio {ticket.account_num} es un borrador de {safe_db_terminal}. "
            f"Debe enviarse al Pizarrón antes de cobrarse desde {safe_req_terminal}.")
```

**Flujo de borradores huérfanos (OrphanDraftModal):**
```
1. Juana captura en T2, no termina, cierra sesión → DRAFT queda en DB asociado a T2
2. Alicia entra a T2
3. Frontend: checkOrphanDrafts() → GET /api/v1/pos/tickets/drafts/T2
4. Servidor responde: [{ account_num: 'V17900', total: 340, captured_by: 'Juana', items: [...] }]
5. OrphanDraftModal aparece con 3 opciones:
   a. "Cargar y Continuar" → handleRecoverAccount() → carrito de Juana cargado para Alicia
   b. "Enviar al Pizarrón" → DRAFT→OPEN → visible en CAJA para cobrar
   c. "Descartar Borrador" → DRAFT→CANCELLED → se pierde (con confirmación implícita)
```

**Badge BORRADOR en el POS:**
```jsx
{/* Mientras el ticket está en DRAFT, mostrar badge discreto */}
{currentAccountNum && cart.length > 0 && !orderData && (
    <span className="text-amber-400 text-xs">📝 BORRADOR</span>
)}
```

**Endpoints v5.0:**
```
GET  /api/v1/pos/tickets/drafts/{terminal_id}
     → Retorna array de DRAFTs con items para la terminal.
     → Usado al login para detectar borradores huérfanos.

POST /api/v1/pos/tickets (status: 'DRAFT')
     → auto-save y primer guardado al agregar producto.

POST /api/v1/pos/tickets (status: 'OPEN')
     → Solo al click de "Abrir Nueva Cuenta".
```

---

> **Este documento es la FUENTE ÚNICA DE VERDAD para el flujo de tickets.**
>
> Cualquier IA o desarrollador que modifique el sistema DEBE leerlo primero
> y verificar que sus cambios no violan NINGUNA de las 17 reglas.
>
> **Las reglas 1, 2, 3, 9, 10, 12, 13, 14, 15, 16 y 17 son las más críticas.** Violarlas causa pérdida
> silenciosa de datos en producción, modales falsos que interrumpen la operación,
> sesiones fantasma que bloquean terminales indefinidamente, recuperación del ticket equivocado,
> cobro de cuentas incompletas con reasignación de folios, o pérdida de auto-saves durante caídas de red.

### ⚡ REGLA 14 — SYNC OBLIGATORIO DE `cartRef` EN TODA RECUPERACIÓN (v4.5)

```
⛔ PROHIBIDO: setCart(recovered) sin sincronizar cartRef primero.
⛔ PROHIBIDO: Asumir que useEffect sincroniza cartRef antes del próximo auto-save.
✅ OBLIGATORIO: cartRef.current = recovered ANTES de setCart(recovered).
```

**¿Por qué?** `setCart()` es asíncrono. El `useEffect(() => { cartRef.current = cart; }, [cart])` se ejecuta DESPUÉS del siguiente render. Si el auto-save dispara antes (cosa que pasa en <16ms en modo concurrente de React), lee `cartRef.current` con el carrito **viejo** del cajero y lo envía al servidor, que ejecuta `_sync_ticket_items()` eliminando los items que no están en el payload.

**Código obligatorio en `handleRecoverAccount`:**
```javascript
cartRef.current = recovered;  // ⚡ v4.5 SYNC inmediato
setCart(recovered);           // ASYNC para UI de React
```

**Código obligatorio en el bloque auto-heal del 409:**
```javascript
cartRef.current = recovered;  // ⚡ v4.5 SYNC inmediato
setCart(recovered);
setIsSendingToPizarron(false);  // Limpiar UI (el return salta el finally interno)
```

### ⚡ REGLA 15 — BÚSQUEDA EXACTA POR ACCOUNT_NUM (v4.5)

```
⛔ PROHIBIDO: Buscar tickets por account_num usando ilike('%search%') para recovery/auto-heal.
✅ OBLIGATORIO: Usar endpoint /tickets/by-account/{account_num} con match exacto (==).
```

**¿Por qué?** `ilike('%V1300%')` coincide con V1300, V13000, V13001, V13002. El frontend tomaba `tickets[0]` (el más reciente), que podía ser un ticket **diferente** al buscado. La búsqueda exacta usa `WHERE account_num = 'V13000'` y solo devuelve el ticket correcto o 404.

**Endpoint nuevo:**
```
GET /api/v1/pos/tickets/by-account/{account_num}
→ Búsqueda exacta. Retorna ticket o HTTP 404.
→ Usa selectinload() + _populate_flat_fields() (misma serialización).
```

**Frontend (POSService.js):**
```javascript
async getTicketByAccountNum(accountNum) {
    const res = await fetch(`${API}/pos/tickets/by-account/${encodeURIComponent(accountNum)}`);
    if (res.status === 404) return null;
    return res.json();
}
```

---

## REGLA 17 — RESILIENCIA OFFLINE: AUTO-SAVE NUNCA SE PIERDE (v5.1)

```
⛔ PROHIBIDO: Que un auto-save falle silenciosamente sin respaldo local.
⛔ PROHIBIDO: Encolar operaciones PAID u OPEN offline (requieren confirmación del servidor).
⛔ PROHIBIDO: Reintentar entradas de la cola indefinidamente (máximo 3 intentos, expiración 10 min).
✅ OBLIGATORIO: Envolver posService.createTicket() con resilientCreateTicket() en handleTicketAction.
✅ OBLIGATORIO: Si la red falla y el status es DRAFT → enqueueOffline(payload) en localStorage.
✅ OBLIGATORIO: useOfflineSync hace flush FIFO automático cuando netStatus transiciona a 'good'.
✅ OBLIGATORIO: Banner visual persistente cuando offlinePending > 0.
```

**¿Por qué?** El auto-save cada 15 segundos es la línea de vida del POS. Si la red se cae
(cable suelto, Docker reiniciando, switch apagado), el auto-save falla con `TypeError: Failed to fetch`.
Sin resiliencia offline, los datos del capturista existen solo en la memoria del navegador.
Si alguien presiona F5 o la pestaña se cierra, los datos se pierden.

**Arquitectura:**
```
handleTicketAction()
  ↓
resilientCreateTicket(posService.createTicket, payload)
  ↓
┌─── RED OK? ───┐
│  SÍ           │  NO (TypeError / AbortError)
↓               ↓
Servidor OK     ¿status === 'DRAFT'?
→ version++     ├── SÍ → enqueueOffline(payload) → localStorage
→ respuesta     │       → return { queued: true, localId }
                │       → setLastSaveStatus('queued')
                │       → badge "📥 GUARDADO LOCAL"
                │
                └── NO (PAID/OPEN) → throw Error
                    → "Sin conexión. La operación requiere conexión."
                    → El operador VE el error y puede reintentar
```

**Cola Offline (`cartPersistence.js`):**
```javascript
// Estructura de cada entrada en localStorage (key: 'rdr_offline_queue')
{
  id: '1715132400000-a7f3bk',  // timestamp-random
  payload: { ... },             // Payload COMPLETO del ticket
  enqueuedAt: '2026-05-08T...',
  attempts: 0,
  lastAttempt: null,
  synced: false,
  error: null
}

// Funciones disponibles:
enqueueOffline(payload)   // Agrega a la cola FIFO
dequeueNext()             // Toma la primera entrada pendiente (< 10 min)
markSynced(entryId)       // Marca como sincronizada
markAttempt(entryId, err) // Incrementa intentos
getQueueSize()            // Cantidad de entradas pendientes
cleanupQueue()            // Elimina entradas procesadas
```

**Sincronizador (`useOfflineSync.js`):**
```javascript
// Triggers:
// 1. Transición netStatus: 'down' → 'good' (con 2s de delay)
// 2. Polling cada 10s si hay pendientes y red está bien

// Proceso de flush:
while (entry = dequeueNext()) {
    try {
        result = await posService.createTicket(entry.payload); // Bypass del wrapper
        markSynced(entry.id);
        
        // Si el ticket sincronizado es el activo en pantalla:
        if (result.version && accountNumRef.current === entry.payload.account_num) {
            ticketVersionRef.current = result.version; // SYNC inmediato
        }
    } catch (error) {
        markAttempt(entry.id, error.message);
        if (entry.attempts >= 3 || !isNetworkError(error)) {
            markSynced(entry.id); // Descartar (error del servidor = payload inválido)
        } else {
            break; // Error de red — reintentar en el próximo ciclo
        }
    }
}
cleanupQueue(); // Limpiar entradas procesadas
```

**Banner visual:**
```jsx
{/* Barra persistente top-of-screen */}
{offlinePending > 0 && (
    <div className="fixed top-0 left-0 right-0 z-[250]">
        <div className={offlinePending >= 3 ? 'bg-red-600' : 'bg-amber-500'}>
            {isOfflineSyncing
                ? '🔄 SINCRONIZANDO N OPERACIONES PENDIENTES...'
                : '⚠️ MODO OFFLINE — N OPERACIONES PENDIENTES DE SINCRONIZACIÓN'}
        </div>
    </div>
)}
```

**Reglas de encolamiento:**
| Condición | Comportamiento |
|---|---|
| Red falla + status `DRAFT` | ✅ Se encola en localStorage |
| Red falla + status `PAID` | ❌ Error ruidoso: "requiere conexión" |
| Red falla + status `OPEN` | ❌ Error ruidoso: "requiere conexión" |
| Entrada > 10 minutos en cola | ⏰ Se marca como EXPIRED automáticamente |
| Entrada con 3+ intentos fallidos | ❌ Se descarta (payload probablemente inválido) |
| Error del servidor (4xx/5xx) | ❌ Se propaga sin encolar (la red funciona) |

**Archivos involucrados:**
```
services/resilientFetch.js    → Wrapper que detecta error de red y encola
services/cartPersistence.js   → Cola FIFO en localStorage (enqueue/dequeue/mark)
hooks/useOfflineSync.js       → Sincronizador automático (flush cuando red=good)
RetailVisionPOS.jsx           → Integración: import + hook + banner + status 'queued'
```

**Cero cambios de backend.** Los payloads encolados son idénticos a los que se envían
normalmente. Cuando la cola se sincroniza, el servidor los procesa como auto-saves normales.

---

## REGLA 18 — NUNCA MODIFICAR ARCHIVOS EN EL VOLUMEN DOCKER MONTADO MIENTRAS LOS CONTAINERS CORREN (v5.2)

```
⛔ PROHIBIDO: Editar archivos Python (.py) en apps/api/ mientras rderico-api-dev está corriendo.
⛔ PROHIBIDO: Editar archivos JS/JSX en la raíz del proyecto mientras rderico-pos-dev está corriendo.
⛔ PROHIBIDO: Ejecutar git add/commit/checkout que modifique archivos en el directorio montado con containers activos.
✅ OBLIGATORIO: Detener los containers ANTES de modificar código fuente.
✅ OBLIGATORIO: Para migraciones SQL puras → detener solo la API, ejecutar SQL, reiniciar API.
✅ OBLIGATORIO: Verificar que el API responde 200 OK después de cada reinicio.
```

**¿Por qué?** El ERP R de Rico corre en Docker con volúmenes montados (bind mounts):
```yaml
# docker-compose.yml
pos:
  volumes:
    - .:/app              # ← TODO el proyecto montado en vivo
api:
  volumes:
    - ./apps/api:/app     # ← Backend montado en vivo
```

Esto significa que **cualquier cambio en un archivo local se refleja INMEDIATAMENTE dentro del container**.
Tanto Vite (frontend, hot-reload) como Uvicorn (backend, --reload) vigilan cambios en `/app` y se
reinician automáticamente al detectarlos.

### Incidente Real — 15 de Mayo 2026

**Contexto:** Se intentó migrar campos monetarios de FLOAT a DECIMAL (Fase 1 del plan de estabilización
basado en el análisis del POS de SISYTEC). Se modificaron 3 archivos de modelos Python directamente
en la carpeta montada mientras los containers corrían.

**Cadena de fallos:**

```
1. Se editaron models.py (pos, catalog, cash) en la carpeta local
       ↓
2. Uvicorn (API) detectó cambios → se reinició con modelos nuevos
   Vite (POS) detectó cambios → crash con error "EIO: i/o error, stat '/app'"
       ↓
3. Frontend crasheó completamente (Vite FSWatcher bug en Docker/Windows)
   → Todas las terminales perdieron la interfaz web
       ↓
4. Se intentó docker compose up --build para reconstruir
   → python-multipart se perdió al recrear el container
   → API no arrancaba: "RuntimeError: Form data requires python-multipart"
       ↓
5. Se instaló python-multipart manualmente + reinicio
   → API arrancó pero las terminales mostraban "Sin conexión al servidor"
       ↓
6. Se revirtieron TODOS los cambios (git checkout + ALTER TABLE a FLOAT + restart)
   → POS volvió a funcionar normalmente
```

**Tiempo de interrupción total: ~45 minutos durante horario de cierre.**

### Procedimiento Correcto para Modificaciones

**Para migraciones de base de datos (SQL puro, sin cambios de código):**
```bash
# 1. Detener SOLO la API (el frontend puede seguir corriendo, la DB sigue arriba)
docker stop rderico-api-dev

# 2. Ejecutar SQL directamente contra PostgreSQL
docker exec rderico-db-dev psql -U user -d rderico -c "ALTER TABLE ...;"

# 3. Reiniciar la API
docker start rderico-api-dev

# 4. Verificar
# Esperar ~10 segundos y probar un endpoint
curl http://192.168.1.117:5001/api/v1/pos/tickets/open
```

**Para cambios de código fuente (modelos, servicios, componentes):**
```bash
# 1. Detener TODOS los containers
docker compose down

# 2. Hacer los cambios de código (editar archivos)
# ... editar models.py, service.py, etc.

# 3. Levantar todo
docker compose up -d

# 4. Verificar que TODO arrancó
docker logs rderico-api-dev --tail 5   # Debe decir "Application startup complete"
docker logs rderico-pos-dev --tail 5   # Debe decir "VITE ready in Xms"
```

**Para operaciones git (commit, checkout, branch):**
```bash
# Los comandos git modifican archivos → activan hot-reload → pueden crashear containers
# 1. Detener containers ANTES de git
docker compose stop

# 2. Hacer operaciones git
git add . && git commit -m "..."
git checkout otra-rama

# 3. Levantar containers
docker compose start
```

### Resultado Final de la Migración FLOAT → DECIMAL

La migración se completó exitosamente usando el procedimiento correcto (SQL puro):

```bash
docker stop rderico-api-dev
docker exec rderico-db-dev psql -U user -d rderico -c "
  ALTER TABLE tickets ALTER COLUMN total TYPE NUMERIC(12,2);
  ALTER TABLE ticket_items ALTER COLUMN unit_price TYPE NUMERIC(12,2);
  ALTER TABLE ticket_items ALTER COLUMN subtotal TYPE NUMERIC(12,2);
  ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(12,2);
  ALTER TABLE products ALTER COLUMN cost TYPE NUMERIC(12,2);
  ALTER TABLE cash_sessions ALTER COLUMN opening_float TYPE NUMERIC(12,2);
  ALTER TABLE cash_sessions ALTER COLUMN physical_cash TYPE NUMERIC(12,2);
  ALTER TABLE cash_sessions ALTER COLUMN physical_credit TYPE NUMERIC(12,2);
  ALTER TABLE cash_sessions ALTER COLUMN physical_debit TYPE NUMERIC(12,2);
  ALTER TABLE cash_movements ALTER COLUMN amount TYPE NUMERIC(12,2);
"
docker start rderico-api-dev
```

**10 columnas migradas. Cero downtime perceptible. Los modelos SQLAlchemy con `Float` funcionan
correctamente contra columnas `NUMERIC` en PostgreSQL — la conversión es automática y transparente.
Los archivos de modelos se actualizarán en la próxima ventana de mantenimiento programada.**

### Checklist Actualizado (agregar a Sección 7)

- [ ] ¿Los containers Docker están DETENIDOS antes de modificar cualquier archivo de código?
- [ ] ¿Las migraciones SQL se ejecutan con la API detenida para evitar deadlocks?
- [ ] ¿Se verificó que la API responde 200 OK después de cada reinicio?
- [ ] ¿Las operaciones git (add, commit, checkout) se hacen con containers detenidos?
- [ ] ¿Todas las variables aritméticas que interactúan con columnas NUMERIC usan `Decimal`, no `float`?

### Bug Crítico: TypeError float + Decimal (15 de Mayo 2026)

**Contexto:** Tras migrar las columnas monetarias de `FLOAT` a `NUMERIC(12,2)` en PostgreSQL,
el endpoint `POST /api/v1/pos/tickets` comenzó a devolver **500 Internal Server Error**.

**Error exacto:**
```
TypeError: unsupported operand type(s) for +=: 'float' and 'decimal.Decimal'
```

**Ubicación:** `service.py`, línea 51 en `_get_items_and_total()`:
```python
# ❌ ANTES (ROTO):
total = 0.0                      # ← float
subtotal = product.price * qty   # ← Decimal (viene de columna NUMERIC)
total += subtotal                # ← float + Decimal = TypeError 💥

# ✅ DESPUÉS (CORREGIDO):
from decimal import Decimal
total = Decimal(0)               # ← Decimal
subtotal = product.price * qty   # ← Decimal
total += subtotal                # ← Decimal + Decimal = OK ✅
```

**¿Por qué pasó?** Cuando SQLAlchemy lee de una columna `NUMERIC`, retorna objetos `decimal.Decimal`
de Python, no `float`. Python **no permite** mezclar `float + Decimal` en operaciones aritméticas
(a diferencia de `float + int` que sí funciona). Esto causó que TODA operación de guardar tickets
fallara con 500, lo cual el frontend interpretaba como "Sin conexión al servidor" porque
`resilientFetch.js` clasifica cualquier error no-red como error del servidor y lo re-lanza,
que a su vez hace que `handleTicketAction` falle y muestre el toast de error.

**Regla derivada:** Cuando se migran columnas de FLOAT a NUMERIC en PostgreSQL, se DEBE:
1. Buscar TODAS las variables Python que inicializan con `0.0` y que interactúan con esas columnas
2. Cambiarlas a `Decimal(0)` o simplemente `0` (Python auto-promueve `int` a `Decimal`)
3. Verificar el endpoint con un POST real, no solo con GET (los GET no hacen aritmética)

**Comando para buscar posibles problemas futuros:**
```bash
grep -rn "= 0\.0" apps/api/modules/*/service.py
```

