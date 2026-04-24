# 🛡️ PROTOCOLO MAESTRO: Ciclo de Vida del Ticket POS — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA** para cualquier IA o desarrollador antes de modificar
> CUALQUIER lógica relacionada con tickets, folios, carrito, cobros, auto-save,
> pizarrón, auditoría, o impresión.
>
> **Este documento reemplaza las versiones 3.0 y 4.0.** La versión 4.0 introdujo
> Zero-Loss pero causaba falsos positivos de "Conflicto de Versión" por auto-colisiones
> del propio sistema (misma terminal disparando auto-save con versión stale).
> La versión 4.3.1 cerró las últimas vulnerabilidades de race condition en la
> sincronización de refs y habilitó bloqueo optimista total (incluido auto-save).
>
> Última actualización: 2026-04-23
> Versión: 4.6 — CACHE BUSTING & IDEMPOTENCY WHITESPACE FIX

---

## ⛔ INCIDENTE QUE ORIGINÓ ESTA VERSIÓN

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

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.4 (HORA PICO FALSE POSITIVES)

**Fecha:** 23/Abril/2026
**Síntoma:** Durante la hora pico, los cajeros que trabajaban solos en sus propias terminales recibían constantemente el modal rojo de "CONFLICTO DE VERSIÓN (409)", bloqueando su trabajo aunque nadie más estuviera editando su cuenta.

**Causa raíz:** Las micro-desconexiones de Wi-Fi (*timeouts*) causaban que el servidor guardara exitosamente los datos e incrementara la versión, pero la terminal no recibía la respuesta de éxito. Al reintentar, la terminal enviaba una versión obsoleta que el servidor rechazaba, disparando un falso positivo de bloqueo optimista. Además, los tickets "reciclados" vacíos no inicializaban su versión en la UI.

**Solución Implementada:** 
1. **Bypass Idempotente de Red:** Si el servidor detecta un conflicto de versión, pero comprueba que la petición proviene de la MISMA terminal dueña del ticket (`req_terminal_id == db_ticket.terminal_id`), asume un timeout de red y perdona el conflicto.
2. `reserveTicket` ahora envía la versión inicial (`ticketVersionRef.current = ticket.version`) para no enviar un primer auto-save "ciego".

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.5 (STALE CORKBOARD POLLING)

**Fecha:** 23/Abril/2026
**Síntoma:** El cliente llega a caja con su "papelito", el cajero abre el Pizarrón de inmediato, selecciona el número de cuenta y la cuenta aparece **incompleta** (solo con los primeros artículos capturados). Al salir, esperar unos segundos y volver a entrar, la cuenta ya aparecía completa.

**Causa raíz:** El "Pizarrón" (Corkboard) realiza polling (`getOpenTickets`) cada 5 segundos. Si el cajero abría el pizarrón antes de que pasara ese intervalo de refresco, le daba clic a un "post-it viejo" (datos *stale* en la memoria del frontend). `handleRecoverAccount` usaba `account.rawItems` directamente desde ese post-it viejo, en vez de consultar a la base de datos por los datos reales actualizados.

**Solución Implementada:** 
**Fetch Asíncrono en Recuperación**. `handleRecoverAccount` ya no confía en los datos cacheados visualmente en el Pizarrón. Ahora es `async` y hace un `fetch` pidiendo la versión *Live* (fresca) del ticket (`getTicketByAccountNum`) justo antes de inyectarlo en el estado de React. Esto garantiza latencia cero entre terminales.

---

## ⛔ INCIDENTE QUE ORIGINÓ LA VERSIÓN 4.6 (CACHE BUSTING & WHITESPACE STRIP)

**Fecha:** 23/Abril/2026
**Síntoma:** A pesar de la versión 4.5, el "Conflicto de Versión" (HTTP 409) seguía apareciendo constantemente para un mismo usuario (auto-colisión). Además, al enviar un ticket al pizarrón y abrirlo, a veces seguía cargando incompleto.

**Causa raíz (2 bugs interactuando):**
1. **Caché agresivo del Navegador:** Las llamadas `fetch` a `getOpenTickets` y `getTicketByAccountNum` estaban siendo cacheadas por el navegador. El Pizarrón mostraba datos obsoletos, y al recuperar el ticket, la terminal inyectaba una `version` anticuada. Al hacer auto-save, se enviaba esta versión vieja, desencadenando el conflicto.
2. **Espacios en Blanco en Terminal IDs:** El Bypass Idempotente de la v4.4 estaba fallando silenciosamente porque `req_terminal_id` y `db_ticket.terminal_id` no coincidían exactamente debido a espacios invisibles (`"T1 "` != `"T1"`), impidiendo que el sistema perdonara la auto-colisión.

**Solución Implementada (Regla 14):** 
1. **Cache Busting:** Se agregó `{ cache: 'no-store' }` a todas las peticiones `GET` en `POSService.js` para forzar siempre la lectura de la base de datos viva.
2. **Comparación Segura:** Se agregó `.strip()` a las variables `req_terminal_id` y `db_ticket.terminal_id` en `service.py` antes de validarlas para el bypass idempotente.

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
| Servicio Frontend | `apps/pos/services/POSService.js` | HTTP client para API |
| Pizarrón | `apps/pos/OpenAccountsCorkboard.jsx` | Visualización de cuentas abiertas |
| Checkout | `apps/pos/components/CheckoutScreen.jsx` | Pagos mixtos |
| Auditoría | `apps/AuditoriaControlUI.jsx` | Consulta histórica |
| Servicio Backend | `apps/api/modules/pos/service.py` | Lógica de negocio |
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

### ⚡ REGLA 2 — AUTO-SAVE: DEPENDENCIAS COMPLETAS

```
⛔ PROHIBIDO: useEffect deps = [currentAccountNum, cart.length, showCheckout]
✅ OBLIGATORIO: useEffect deps = [currentAccountNum, cart, showCheckout]
```

**¿Por qué?** Si la dependencia es `cart.length` (un número), y el carrito viejo
tiene 5 items y el carrito nuevo también tiene 5 items (pero DIFERENTES), React
NO reinicia el useEffect. El timer viejo sigue corriendo con la versión vieja
de `handleTicketAction` que tiene el carrito viejo en su closure.

Al usar `cart` (el array completo), React compara por referencia. Cada `setCart()`
crea un nuevo array, por lo que el timer SIEMPRE se reinicia.

**Además**, el auto-save DEBE respetar el flag `isRecoveringRef`:
```javascript
useEffect(() => {
    if (!currentAccountNum || cart.length === 0 || showCheckout) return;

    const autoSaveTimer = setInterval(() => {
        if (isGeneratingFolioRef.current) return;
        if (isRecoveringRef.current) return;  // ← OBLIGATORIO
        if (!accountNumRef.current || cartRef.current.length === 0) return;
        handleTicketAction('OPEN', null, false).catch(e => {
            console.warn("Auto-save failed:", e);
            setLastSaveStatus('failed');  // ← v4.0: feedback visual obligatorio
        });
    }, 15000);  // ← v4.0: reducido de 30s a 15s

    return () => clearInterval(autoSaveTimer);
}, [currentAccountNum, cart, showCheckout]);  // ← cart, NO cart.length
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
    //    ⚡ v4.3.1: requestAnimationFrame puede dispararse ANTES de los
    //    useEffect que sincronizan refs → el auto-save leería refs stale.
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
- ⚡ v4.4: **Bypass Idempotente:** Si hay conflicto, pero `req_terminal_id == db_ticket.terminal_id`, se asume timeout de red y se perdona el conflicto.
- ⚡ v4.3.1: TODAS las llamadas envían `version: liveVersion` (mutex + sync directo eliminan stale-closures).
- Si conflicto real (distinta terminal) → **HTTP 409** + modal `CollisionModal`.
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

- Estado `lastSaveStatus`: `'unsaved'` | `'saving'` | `'saved'` | `'failed'`
- Si `failed` → badge rojo parpadeante `⚠️ SIN GUARDAR` visible en el Pizarrón.
- Si `saved` → badge verde `✅ 11:05` con hora del último guardado exitoso.
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
| `status` | STRING | `OPEN`, `PAID`, `CANCELLED` |
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
| `cashed_by_name` | Si OPEN: `"--- PENDIENTE ---"` / Si PAID: `ticket.cashed_by.name` → fallback: `"SISTEMA/AUTO"` |

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
  - `status = OPEN`
  - `total = 0`
  - Sin items
  - `created_at` > 24 horas de antigüedad
- Throttled: máximo 1 ejecución por minuto
- Se ejecuta automáticamente al reservar un ticket

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
- [ ] ¿`handleRecoverAccount` descarga los datos más recientes (Live Data) del servidor ANTES de restaurar el estado local? (v4.5)

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
| Timeouts de red desincronizaban `version` (v4.3.1) | **Falso Positivo de Conflicto en Hora Pico** — El servidor guardaba pero la UI perdía la conexión. Al reintentar la UI enviaba version vieja y el servidor la bloqueaba. | v4.4: Bypass idempotente. Si la terminal atacante = terminal dueña, perdonar 409. |
| `generateNewAccountNum` no sincronizaba refs | **Folios huérfanos y Version=null** — `handleTicketAction` leía `accountNumRef` vacío y generaba folio duplicado. Además, enviaba version=null rompiendo bloqueo optimista. | v4.4: Sync inmediato de `accountNumRef`, `originalCapturerRef`, y `ticketVersionRef` |
| `handleRecoverAccount` no sincronizaba todas las refs | **409 falsos post-recuperación** — `requestAnimationFrame` se disparaba antes del `useEffect` sync, auto-save leía refs stale | v4.3.1: Sync inmediato de `accountNumRef`, `originalCapturerRef`, `ticketVersionRef` |
| CashSession sin cerrar bloqueaba terminal permanentemente | **OMEGA aparecía en CAJA + T4/T6 simultáneamente** durante 2+ días. La sesión de caja #110 nunca se cerró y no tenía TTL, causando un candado fantasma permanente en la pantalla de selección | REGLA 13: TTL de 24h para CashSessions + deduplicación de usuarios + heartbeat con purga |
| Pizarrón cargaba cuentas incompletas temporalmente | **Delay visual en recuperación de cuenta** — Polling cada 5s causaba que `handleRecoverAccount` usara un `rawItems` viejo si se le daba clic muy rápido. | v4.5: `handleRecoverAccount` realiza fetch `getTicketByAccountNum` para obtener versión *Live* ignorando caché local. |

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

> **Este documento es la FUENTE ÚNICA DE VERDAD para el flujo de tickets.**
>
> Cualquier IA o desarrollador que modifique el sistema DEBE leerlo primero
> y verificar que sus cambios no violan NINGUNA de las 13 reglas.
>
> **Las reglas 1, 2, 3, 9, 10, 12 y 13 son las más críticas.** Violarlas causa pérdida
> silenciosa de datos en producción, modales falsos que interrumpen la operación,
> o sesiones fantasma que bloquean terminales indefinidamente.
