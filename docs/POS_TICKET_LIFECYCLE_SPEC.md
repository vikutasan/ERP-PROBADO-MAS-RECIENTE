# 📋 PROTOCOLO MAESTRO: Ciclo de Vida del Ticket POS — R de Rico ERP

> **LECTURA OBLIGATORIA** para cualquier IA o desarrollador antes de modificar cualquier lógica
> relacionada con tickets, folios, cuentas, cobros, auditoría, o el Pizarrón.
> 
> Última actualización: 2026-04-21
> Versión: 2.0

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
  (carrito local)      flat_fields()        (secuencia atómica)
```

### Componentes Clave y sus Archivos

| Componente | Archivo | Responsabilidad |
|-----------|---------|-----------------|
| Terminal POS | `apps/pos/RetailVisionPOS.jsx` | Captura, carrito, cobro, impresión |
| Servicio Frontend | `apps/pos/services/POSService.js` | HTTP client para API |
| Hook de Carrito | `apps/pos/hooks/useCart.js` | Estado + localStorage del carrito |
| Hook de Terminal | `apps/pos/hooks/useTerminalLocking.js` | Candados, heartbeat, polling |
| Pizarrón (Corkboard) | `apps/pos/OpenAccountsCorkboard.jsx` | Visualización de cuentas abiertas |
| Checkout (Cobro) | `apps/pos/components/CheckoutScreen.jsx` | Pagos mixtos, liquidación |
| Auditoría y Control | `apps/AuditoriaControlUI.jsx` | Consulta histórica de tickets |
| API Router | `apps/api/modules/pos/router.py` | Endpoints REST |
| Servicio Backend | `apps/api/modules/pos/service.py` | Lógica de negocio |
| Modelos | `apps/api/modules/pos/models.py` | Definición SQLAlchemy |
| Schemas | `apps/api/modules/pos/schemas.py` | Validación Pydantic |
| Occupancy | `apps/api/modules/pos/occupancy.py` | Candados persistentes de terminal |

---

## 2. REGLAS INQUEBRANTABLES

### 2.1 Generación de Folios — SECUENCIA ATÓMICA

```
⛔ PROHIBIDO: MAX(id) + 1, random(), uuid(), Date.now()
✅ OBLIGATORIO: SELECT nextval('ticket_folio_seq')
```

- Los folios se generan EXCLUSIVAMENTE con la secuencia PostgreSQL `ticket_folio_seq`.
- Esta secuencia es **atómica a nivel de base de datos**: incluso 100 terminales pidiendo folio al mismo instante recibirán valores únicos.
- El formato es `V{NNNN}` (ej: `V0042`).
- **NUNCA** generar folios en el frontend con `Date.now()`, `Math.random()`, o cualquier otro método.
- Si la secuencia no existe, `_ensure_folio_sequence()` la crea automáticamente tomando el máximo folio existente.

### 2.2 Serialización — CAMINO ÚNICO

```
⛔ PROHIBIDO: Diccionarios manuales con campos hardcoded
✅ OBLIGATORIO: selectinload() + _populate_flat_fields()
```

- **TODA** respuesta de ticket (crear, listar, reservar) DEBE usar:
  1. `selectinload()` para cargar relaciones (items, product, category, captured_by, cashed_by, session)
  2. `_populate_flat_fields()` para agregar campos virtuales (`terminal_id`, `captured_by_name`, `cashed_by_name`)
- **NUNCA** construir diccionarios manualmente con campos seleccionados a mano. Esto causa divergencia entre lo que ve el POS y lo que ve Auditoría.

### 2.3 Campo `terminal_id` — DIRECTO EN EL MODELO

```
⛔ PROHIBIDO: Obtener terminal_id solo vía ticket.session.terminal_id
✅ OBLIGATORIO: ticket.terminal_id (columna directa en la tabla tickets)
```

- El modelo `Ticket` tiene un campo directo `terminal_id` que se poblava al crear/actualizar.
- `_populate_flat_fields()` usa el campo directo como prioridad; solo cae a la relación `session` como fallback.
- Al filtrar tickets por terminal, usar `WHERE terminal_id = X`, NO hacer JOIN con terminal_sessions.

### 2.4 Concurrencia — FOR UPDATE

```
⛔ PROHIBIDO: SELECT → UPDATE sin bloqueo
✅ OBLIGATORIO: SELECT ... FOR UPDATE (o FOR UPDATE SKIP LOCKED para reciclaje)
```

- `_upsert_ticket_header()`: usa `FOR UPDATE` para bloquear la fila del ticket durante upsert. Previene race conditions entre auto-save y cobro simultáneo.
- `_find_empty_ticket()`: usa `FOR UPDATE SKIP LOCKED` para que dos terminales no reciclen el mismo ticket vacío.
- El check `status == "PAID"` después del `FOR UPDATE` garantiza idempotencia: si un auto-save llega después del cobro, el servidor rechaza la escritura con "ya ha sido pagado".

### 2.5 `captured_by_id` — DESDE EL PRIMER INSTANTE

```
⛔ PROHIBIDO: Crear ticket sin captured_by_id y asignarlo después
✅ OBLIGATORIO: Enviar captured_by_id en reserve_ticket
```

- El frontend envía `captured_by_id` al llamar `reserveTicket(terminalId, currentUser.id)`.
- El servidor graba `captured_by_id` incluso en el ticket vacío de reserva.
- Si un empleado B cobra un ticket capturado por A, `captured_by_id` permanece como A y `cashed_by_id` se asigna como B.

### 2.6 Auto-Save — ANTI-STALE-CLOSURE

```
⛔ PROHIBIDO: useEffect con setInterval que lea state vía closure
✅ OBLIGATORIO: useRef sincronizados para cart y accountNum
```

- El auto-save (cada 30s) lee `cartRef.current` y `accountNumRef.current` en lugar de los valores de closure.
- Estos refs se sincronizan con state vía `useEffect(() => { ref.current = state }, [state])`.
- El flag `isGeneratingFolioRef` bloquea el auto-save mientras se genera un folio nuevo.

### 2.7 UI — CERO ALERT() BLOQUEANTES

```
⛔ PROHIBIDO: alert(), confirm(), prompt()
✅ OBLIGATORIO: Toast no-bloqueante o modal React
```

- `alert()` bloquea el thread de JavaScript, lo que interfiere con `iframe.print()`, polling de heartbeat, y auto-save.
- Todos los mensajes de error o éxito usan toasts con `setTimeout` para auto-desaparecer.

---

## 3. FLUJO COMPLETO DEL TICKET

### 3.1 Reserva (Lazy)

```
1. Usuario agrega primer producto al carrito
2. handleAddToCart() → addToCart() (síncrono, actualiza UI inmediato)
3. Si !currentAccountNum → generateNewAccountNum() (asíncrono)
4. isGeneratingFolioRef = true (bloquea auto-save)
5. posService.reserveTicket(terminalId, currentUser.id)
6. Servidor: _find_empty_ticket(terminal_id) con FOR UPDATE SKIP LOCKED
   → Si encuentra ticket vacío: lo reutiliza, asigna captured_by_id
   → Si no: _generate_consecutive_ticket() con nextval('ticket_folio_seq')
7. Servidor devuelve ticket con account_num, terminal_id, captured_by_id
8. Frontend: setCurrentAccountNum(ticket.account_num)
9. isGeneratingFolioRef = false (desbloquea auto-save)
```

### 3.2 Auto-Save (Pizarrón)

```
1. Cada 30 segundos, si cartRef.current.length > 0 && accountNumRef.current
2. Verificar: isGeneratingFolioRef === false
3. handleTicketAction('OPEN', null, false)
4. Servidor: _upsert_ticket_header() con FOR UPDATE
   → Encuentra ticket existente por account_num
   → Actualiza total, items, campos OMS, captured_by_id
5. El ticket aparece en el Pizarrón (get_open_tickets WHERE status=OPEN AND total>0)
```

### 3.3 Cobro

```
1. Usuario abre CheckoutScreen → registra pagos mixtos
2. handleFinalize() → onConfirm(finalPayments) → handleTicketAction('PAID', paymentData, true)
3. Servidor: _upsert_ticket_header() con FOR UPDATE
   → ticket.status = 'PAID'
   → ticket.payment_details = paymentData
   → ticket.cashed_by_id = currentUser.id
4. Si es PEDIDO: _create_order_from_ticket() → crea Order en tabla orders
5. Servidor devuelve ticket completo con _get_full_ticket()
6. Frontend: savedTicketRef.current = savedTicket (ref inmediata)
7. handlePrintTicket(savedTicket) → genera HTML → iframe.print()
8. clearCart(), resetState()
9. Toast: "✅ Venta finalizada exitosamente"
```

### 3.4 Recuperación desde Pizarrón

```
1. Usuario abre Pizarrón → get_open_tickets()
2. Selecciona cuenta → handleRecoverAccount(account)
3. Reconstruye carrito desde account.rawItems
4. Restaura originalCapturer del ticket original
5. Si es PEDIDO: restaura orderType + orderData
6. El usuario puede modificar el carrito y luego cobrar normalmente
```

### 3.5 Consulta en Auditoría

```
1. AuditoriaUI → fetchTickets() → GET /pos/tickets
2. Servidor: get_tickets() usa MISMAS opciones selectinload + _populate_flat_fields()
3. Frontend recibe datos IDÉNTICOS a los que recibió el POS al crear
4. Reimpresión: handlePrintTicket(selectedTicket) → mismos datos = mismo ticket
```

---

## 4. MODELO DE DATOS

### Tabla `tickets`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT PK | Auto-incremento |
| `account_num` | STRING UNIQUE | Folio (`V0042`). Generado por `ticket_folio_seq` |
| `terminal_id` | STRING | Terminal donde se creó (campo directo, NO derivado) |
| `total` | FLOAT | Total calculado del carrito |
| `status` | STRING | `OPEN`, `PAID`, `CANCELLED` |
| `payment_details` | JSON | Lista de pagos mixtos (`[{method, amount, type, ...}]`) |
| `session_id` | FK → terminal_sessions | Sesión del terminal |
| `cash_session_id` | FK → cash_sessions | Sesión de caja (si hay) |
| `captured_by_id` | FK → employees | Quién capturó la venta |
| `cashed_by_id` | FK → employees | Quién cobró la venta |
| `order_type` | STRING | `VENTA_DIRECTA` o `PEDIDO` |
| `order_status` | STRING | Estado del OMS |
| `delivery_type` | STRING | `PICKUP`, `DOMICILIO` |
| `customer_name` | STRING | Nombre del cliente |
| `customer_phone` | STRING | Teléfono del cliente |
| `committed_at` | DATETIME | Fecha compromiso de entrega |
| `packaging_type` | STRING | `PROPIO`, `VENTA` |
| `delivery_address` | STRING | Dirección de entrega |
| `order_notes` | TEXT | Notas del pedido |
| `created_at` | DATETIME | Fecha de creación |

### Campos Virtuales (poblados por `_populate_flat_fields`)

| Campo | Fuente |
|-------|--------|
| `terminal_id` | `ticket.terminal_id` (directo) ▸ fallback: `ticket.session.terminal_id` |
| `captured_by_name` | `ticket.captured_by.name` ▸ fallback: `"SISTEMA"` |
| `cashed_by_name` | `ticket.cashed_by.name` ▸ fallback: `"SISTEMA/AUTO"` |

---

## 5. GARBAGE COLLECTION

- `_cleanup_stale_empty_tickets()` elimina tickets con `status=OPEN`, `total=0`, sin items, y `created_at > 24 horas`.
- Se ejecuta automáticamente al reservar un ticket, throttled a máximo 1 vez por minuto.
- Previene la acumulación de tickets vacíos huérfanos tras reinicios del sistema.

---

## 6. CHECKLIST ANTES DE MODIFICAR CÓDIGO

Antes de hacer CUALQUIER cambio en el flujo de tickets, verificar:

- [ ] ¿El folio se genera exclusivamente con `nextval('ticket_folio_seq')`?
- [ ] ¿La serialización usa `selectinload()` + `_populate_flat_fields()`?
- [ ] ¿Los queries de escritura usan `FOR UPDATE` o `FOR UPDATE SKIP LOCKED`?
- [ ] ¿Se envía `captured_by_id` desde el momento de la reserva?
- [ ] ¿Los mensajes de error usan toast, NO `alert()`?
- [ ] ¿El auto-save lee de refs (`cartRef`, `accountNumRef`), NO de closures?
- [ ] ¿El campo `terminal_id` se graba directamente en el modelo Ticket?
- [ ] ¿Cualquier nuevo campo se agrega a `_populate_flat_fields()` si es virtual?
- [ ] ¿Los datos de Auditoría y POS pasan por el MISMO código de serialización?

---

## 7. ERRORES COMUNES A EVITAR

| Error | Consecuencia | Prevención |
|-------|-------------|-----------|
| Crear diccionario manual en `get_tickets()` | Auditoría muestra datos diferentes al POS | Siempre usar `_populate_flat_fields()` |
| `alert()` después de `print()` | Impresión se bloquea o no sale | Usar toast no-bloqueante |
| `setInterval` con closure de state | Auto-save envía datos viejos del carrito | Usar `useRef` sincronizado |
| `FOR UPDATE` sin check de status | Auto-save sobrescribe ticket PAID | Siempre verificar `status == "PAID"` post-lock |
| Filtrar tickets por `session_id` | Tickets de sesiones anteriores no aparecen | Filtrar por `terminal_id` directo |
| Generar folios en frontend | Duplicados bajo concurrencia | Solo usar `reserveTicket()` → `nextval()` |

---

> **Este documento es la fuente de verdad para el flujo de tickets.**
> Cualquier IA o desarrollador que modifique el sistema DEBE leerlo primero y verificar que sus cambios no violan ninguna de las reglas anteriores.
