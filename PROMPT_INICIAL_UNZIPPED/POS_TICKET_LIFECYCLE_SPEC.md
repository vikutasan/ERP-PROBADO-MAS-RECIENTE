# 🛡️ PROTOCOLO MAESTRO: Ciclo de Vida del Ticket POS — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA** para cualquier IA o desarrollador antes de modificar
> CUALQUIER lógica relacionada con tickets, folios, carrito, cobros, auto-save,
> pizarrón, auditoría, o impresión.
>
> **Este documento reemplaza la versión 2.0.** La versión anterior NO documentaba
> los race conditions de closures de React que causaron pérdida de datos en producción.
>
> Última actualización: 2026-04-22
> Versión: 4.0 — ZERO-LOSS ENDURECIMIENTO

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
  accountNumRef
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
| Occupancy | `apps/api/modules/pos/occupancy.py` | Candados de terminal |

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

// Sincronización:
React.useEffect(() => { cartRef.current = cart; }, [cart]);
React.useEffect(() => { accountNumRef.current = currentAccountNum; }, [currentAccountNum]);
React.useEffect(() => { originalCapturerRef.current = originalCapturer; }, [originalCapturer]);
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
        handleTicketAction('OPEN', null, false).catch(e => console.warn("Auto-save failed:", e));
    }, 30000);

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
    if (!account.rawItems?.length) return alert("Cuenta vacía.");

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

    // 3. Mutar estado (React batcha estas operaciones)
    setCart(recovered);
    setCurrentAccountNum(account.accountNum);
    setOriginalCapturer(account.capturedById
        ? { id: account.capturedById, name: account.capturedByName }
        : currentUser);

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
    //    requestAnimationFrame espera al siguiente frame de pintura
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
✅ OBLIGATORIO: Mostrar estado de loading (`isSendingToPizarron`) y limpiar el carrito SOLO si `savedTicket` existe.
```
Además, el ticket debe guardarse automáticamente en el servidor en el momento en que se agrega el primer producto (con status OPEN).

### ⚡ REGLA 10 — BLOQUEO OPTIMISTA ANTI-SOBREESCRITURAS

```
⛔ PROHIBIDO: Actualizar el ticket enviando solo los datos actuales.
✅ OBLIGATORIO: Enviar la `version` del ticket en cada petición de actualización.
```
El servidor validará que la `version` del cliente coincida con la de la BD. Si no coincide, lanzará un error 409 (Conflicto), obligando al usuario a refrescar.

### ⚡ REGLA 11 — VISIBILIDAD DE AUTO-SAVE Y CIERRE DE NAVEGADOR

- El Auto-Save debe tener feedback visual en la UI (`⚠️ SIN GUARDAR` o `✅ 11:05`).
- El componente principal debe incluir un `beforeunload` listener para interceptar cierres accidentales.
- Si se cierra accidentalmente, se debe intentar un `Emergency Save` usando `navigator.sendBeacon`.

---

## 3. FLUJO COMPLETO DEL TICKET

### 3.1 Reserva (Lazy)

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
7. Frontend: setCurrentAccountNum(ticket.account_num)
8. isGeneratingFolioRef.current = false
```

### 3.2 Auto-Save (Pizarrón) — CADA 30 SEGUNDOS

```
1. useEffect se activa cuando cambian: currentAccountNum, cart, showCheckout
2. Si !currentAccountNum || cart.length === 0 || showCheckout → NO crear timer
3. setInterval(30000):
   a. Si isGeneratingFolioRef.current → SKIP
   b. Si isRecoveringRef.current → SKIP (NUEVO — v3.0)
   c. Si !accountNumRef.current || cartRef.current.length === 0 → SKIP
   d. handleTicketAction('OPEN', null, false)
      → LEE cartRef.current (NO cart)
      → LEE accountNumRef.current (NO currentAccountNum)
      → LEE originalCapturerRef.current (NO originalCapturer)
4. Servidor: _upsert_ticket_header() con FOR UPDATE
   → Actualiza total, items, campos OMS, captured_by_id
5. El ticket aparece en el Pizarrón (get_open_tickets WHERE status=OPEN AND total>0)
```

### 3.3 Guardar en Pizarrón (Manual)

```
1. Usuario hace click en botón "Guardar en Pizarrón"
2. handleTicketAction('OPEN', null, true)
   → finalizeUI = true → después de guardar, limpia el carrito
3. Servidor guarda el ticket completo
4. Frontend: clearCart(), setCurrentAccountNum(''), setOriginalCapturer(null)
5. El capturista escribe el papelito con # de cuenta y total
```

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
- **Input:** account_num, items, status, captured_by_id, cashed_by_id
- **Comportamiento:**
  1. `SELECT ... FOR UPDATE` por account_num → bloquea la fila
  2. Si existe y `status == 'PAID'` → **rechaza con HTTP 400** (idempotencia)
  3. Si existe y `status != 'PAID'` → `_update_ticket_fields()`
  4. Si no existe → `_initialize_new_ticket()`
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
- [ ] ¿El ticket envía su `version` para bloqueo optimista?
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
> y verificar que sus cambios no violan NINGUNA de las 8 reglas.
>
> **Las reglas 1, 2 y 3 son las más críticas.** Violarlas causa pérdida
> silenciosa de datos en producción.
