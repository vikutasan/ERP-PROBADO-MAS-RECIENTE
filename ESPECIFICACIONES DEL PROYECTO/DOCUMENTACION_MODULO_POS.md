# 🛡️ DOCUMENTACIÓN MAESTRA: MÓDULO PUNTO DE VENTA IA — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA.** Cualquier IA o desarrollador que necesite modificar o auditar CUALQUIER aspecto del Punto de Venta (POS) de R de Rico **DEBE leer este documento completo primero.**
>
> **Última actualización:** 2026-06-11
> **Versión de arquitectura POS:** v6.1 (Modelo SaaS — Persistencia Atómica + Verificación Post-Envío)
> **Archivos gobernados:** `apps/pos/`, `apps/api/modules/pos/`, `apps/api/modules/cash/`

---

> ⛔ **PROHIBICIONES ABSOLUTAS** (si solo lees 5 líneas de este documento, que sean estas):
> 1. **NO** reintroducir auto-save, timers ni `setInterval` para guardar el carrito. La persistencia es atómica por ítem.
> 2. **NO** hacer `clearCart()` sin confirmación HTTP 200 del servidor **Y** verificación post-envío (v6.1).
> 3. **NO** leer variables de estado (`cart`, `currentAccountNum`) dentro de callbacks asíncronos — usar siempre `useRef` (`cartRef.current`).
> 4. **NO** almacenar candados de terminal en RAM de Python — solo en PostgreSQL (tabla `terminal_locks`).
> 5. **NO** generar folios en el frontend — solo el backend los genera vía secuencia atómica de PostgreSQL.

---

## ÍNDICE

1. [Arquitectura Actual (v6.0 - Modelo SaaS)](#1-arquitectura-actual-v60---modelo-saas)
2. [Evolución Histórica: Cómo y Por Qué Llegamos Aquí](#2-evolución-histórica-cómo-y-por-qué-llegamos-aquí)
3. [El Cementerio de Bugs (Lecciones Aprendidas)](#3-el-cementerio-de-bugs-lecciones-aprendidas)
4. [Las Reglas de Oro Supervivientes (v6.0)](#4-las-reglas-de-oro-supervivientes-v60)
5. [Lógica de Terminales y Ocupación](#5-lógica-de-terminales-y-ocupación)
6. [Archivos Críticos — Mapa de Zona Restringida](#6-archivos-críticos--mapa-de-zona-restringida)
7. [Historial de Reglas Pre-v6.0 (Archivo Histórico)](#7-historial-de-reglas-pre-v60-archivo-histórico)

---

## 1. ARQUITECTURA ACTUAL (v6.0 - MODELO SaaS)

### El Gran Cambio de Paradigma

Hasta la versión 4.8, el POS intentaba guardar todo el carrito completo cada 15 segundos (Bulk Auto-Save). Esto causaba problemas infinitos de concurrencia y sobreescrituras.

En la **v6.0 (Modelo SaaS)**, el funcionamiento del POS se simplificó radicalmente imitando a los ERPs SaaS estables: **Persistencia Inmediata y Atómica.**

### ¿Cómo funciona la v6.0?

1. **Un solo camino de escritura atómica:**
   - Cuando el cajero agrega un pan: `handleAddToCart` se ejecuta y llama a `posService.addItemToTicket()`.
   - Cuando cambia la cantidad: `handleUpdateQuantity` llama a `posService.updateItemQuantity()`.
   - Cuando borra un pan: `handleRemoveFromCart` llama a `posService.removeItemFromTicket()`.
   - **Resultado:** La base de datos siempre tiene la versión real de la cuenta. El carrito local de React es solo un reflejo veloz (optimistic update).

2. **Acciones Explícitas (El fin del Auto-Save):**
   - El envío en bloque (`handleTicketAction`) **solo** se usa para dos cosas puntuales y explícitas que el usuario ordena:
     - Dar click en "Guardar en Pizarrón" (estado `OPEN`).
     - Dar click en "Cobrar" (estado `PAID`).
   - El timer asíncrono de auto-guardado masivo **fue eliminado**.

3. **Recuperación Directa:**
   - Al recuperar una cuenta del pizarrón (`handleRecoverAccount`), ya no se hace un "flush" de seguridad. Simplemente se descarga la versión fresca de los items del servidor y se dibuja en la pantalla.

---

## 2. EVOLUCIÓN HISTÓRICA: CÓMO Y POR QUÉ LLEGAMOS AQUÍ

Para evitar que futuras IAs intenten reimplementar arquitecturas pasadas que fracasaron, aquí se documenta el orden cronológico de nuestra evolución:

### Fase 1: El POS Básico y el Caos (v1.0 - v3.0)
- **Febrero/Marzo 2026:** Se construyó el POS básico. Usaba un botón de "Guardar" que enviaba el estado del carrito al backend.
- **El problema:** Los cajeros cerraban la pestaña o perdían la conexión antes de guardar. Se perdieron cuentas.

### Fase 2: La Era de la Complejidad Defensiva (v4.0 - v4.8)
- Para solucionar la pérdida de datos, implementamos un **Auto-Save masivo de 15 segundos**.
- Esto abrió la caja de Pandora de las *race conditions* (condiciones de carrera de JavaScript). Si dos personas tocaban la misma cuenta, o si el Wi-Fi era lento, el Auto-Save sobreescribía los datos del otro.
- **La solución temporal:** Se implementó una ingeniería masiva de candados:
  - `actionMutexRef` para serializar promesas.
  - Bloqueo optimista total con el campo `version`.
  - Modales constantes de "Conflicto de Versión" (HTTP 409) que bloqueaban la pantalla del cajero.
  - Sincronización agresiva de `useRef` para evitar que los timers leyeran *closures* viejos.

### Fase 3: La Simplificación SaaS (v6.0 - Actualidad)
- **Mayo 2026:** Nos dimos cuenta de que la v4.8 era demasiado frágil y compleja. Al analizar cómo funcionaban otros ERPs comerciales tipo SaaS, descubrimos que **no hacían auto-saves de todo el carrito**. Guardaban ítem por ítem en tiempo real.
- Se reescribió `useTicketActions.js`. Se borró el timer de auto-save. Se crearon los endpoints `addItem`, `updateItem`, `removeItem`.
- **El resultado:** El POS se volvió 100x más estable. Los modales 409 desaparecieron porque la base de datos centraliza la verdad átomo por átomo. La complejidad de la v4.8 se desechó por un diseño inmensamente superior.

---

## 3. EL CEMENTERIO DE BUGS (LECCIONES APRENDIDAS)

Estos son los incidentes que nos llevaron a simplificar todo. **No cometer los mismos errores:**

### Incidentes Financieros

| Error Histórico (Pre-v6) | Consecuencia | Cómo la v6.0 lo previene |
|-------------------------|--------------|--------------------------| 
| **Ticket #906 ($124 → $2):** El auto-save leyó variables viejas de un `closure` y sobreescribió un carrito de 8 ítems con 1 ítem. | Pérdida económica severa. | Al no existir auto-save masivo, no hay timers asíncronos que puedan tener closures viejos. Todo es síncrono al clic. |
| **Ticket #125 ($205):** El botón de Pizarrón limpiaba la pantalla antes de que el servidor confirmara el guardado. La red falló. | Cuenta desaparecida. | `clearCart()` solo ocurre si el servidor responde con HTTP 200 (Regla de Oro). |
| **Hora Pico de Falsos Positivos:** El auto-save lanzaba modales bloqueantes de conflicto porque el Wi-Fi tardaba más de 15s en responder. | Cajeros paralizados. | El envío atómico es rápido y si falla, hace 3 reintentos silenciosos con "backoff" (ver `handleAddToCart`). |

### Incidente Ticket #906 — Línea de Tiempo Forense

Este es el bug más grave que sufrimos. Se documenta en detalle para que jamás se repita:

```
T=0s    Víctor abre V11906 (8 items, total $124)
        Auto-save del render N captura: cart=[8 items], account='V11906'

T=10s   Víctor COBRA V11906 → clearCart() → cart = []
        Víctor escanea BOLSA ($2) → nuevo carrito con 1 item
        Nuevo folio: V11907

T=15s   ⛔ AUTO-SAVE DISPARA con datos del render N (CLOSURE VIEJO):
        → Envía: { account_num: 'V11906', items: [BOLSA] }
        → Servidor: _sync_ticket_items() BORRA los 7 items extra
        → V11906 ahora solo tiene 1x BOLSA ($2) 💀

T=30s   Víctor cobra V11906 desde pizarrón
        → Ticket impreso con $2.00 en vez de $124.00
```

**La v6.0 elimina este escenario de raíz:** No existe ningún timer que pueda disparar con datos viejos.

### Incidente Terminal Fantasma OMEGA (23/Abril/2026)

**Terminal afectada:** CAJA + T4/T6 (usuario OMEGA, ID: 20).
**Síntoma:** OMEGA aparecía como ocupante de 2 terminales simultáneamente durante 2+ días.

**Causa raíz (3 bugs interconectados):**
1. **CashSession sin TTL:** OMEGA abrió una sesión de caja que nunca se cerró. El endpoint `/terminals/status` mostraba la terminal CAJA como bloqueada permanentemente.
2. **Doble ocupación:** `lock_terminal()` limpiaba locks previos del usuario pero no sabía de CashSessions. La CashSession huérfana en CAJA generaba una entrada duplicada.
3. **Heartbeat sin purga:** El heartbeat solo renovaba el timestamp sin limpiar locks duplicados del mismo usuario.

**Solución implementada (vigente hoy):**
1. `heartbeat()` ahora ejecuta purga de locks expirados + limpieza de duplicados del mismo usuario en cada ciclo.
2. `/terminals/status` detecta cuando un usuario tiene lock en otra terminal y marca la CashSession huérfana como `"CAJA ABIERTA"` con flag `operator_absent: true`.
3. CashSessions abiertas >24 horas se marcan como `"SESIÓN EXPIRADA"` con flag `stale_session: true`.

### Incidente Cuenta Fantasma $453 — Terminal T3 (11/Junio/2026)

**Terminal afectada:** T3 (cajera Yami, ID: 25).
**Síntoma:** Yami reportó que armó una cuenta por $453 en T3, le dio clic en "Enviar Cuenta" al Pizarrón, creyó que se envió correctamente, pero la cuenta **nunca apareció en el Pizarrón**.

**Investigación forense:**
1. **Base de datos:** No existe ningún ticket con total=$453, ni como OPEN, ni DRAFT, ni CANCELLED. La cuenta nunca llegó al servidor.
2. **Logs del servidor:** Cero errores HTTP. Cero excepciones. El servidor nunca recibió la petición.
3. **Auditoría POS:** Todos los requests de T3 ese día respondieron HTTP 200. No hay registro de un intento fallido.
4. **Tickets de Yami:** Sus 16 tickets de esa noche están todos completos y pagados correctamente. Ninguno suma $453.
5. **DRAFT tickets:** No existe ningún DRAFT de T3, confirmando que los items **nunca se persistieron atómicamente**.

**Causa raíz:** La Terminal T3 sufrió un **corte de WiFi silencioso**. Los productos se agregaron a la pantalla (optimistic update de React), pero las llamadas a `addItemToTicket()` fallaron silenciosamente después de 3 reintentos. Los items solo existieron en la memoria del navegador. Cuando Yami presionó "Enviar Cuenta", el `createTicket()` también falló por falta de red, pero el indicador de error (un toast de 5 segundos y un texto de 10px) fue **insuficiente en hora pico** y la cajera no lo percibió.

```
T=0s    Yami empieza a armar cuenta de $453 en T3
        Agrega productos → aparecen en pantalla (optimistic update)
        PERO: WiFi de T3 está caído

T=1-30s addItemToTicket() falla 3 veces por cada producto
        Toast ⚠️ aparece brevemente → Yami no lo ve en hora pico
        Items SOLO existen en memoria del navegador, NO en PostgreSQL

T=31s   Yami da clic en "Enviar Cuenta"
        createTicket() falla (sin red)
        Toast ❌ aparece 5 segundos → Yami ya está atendiendo al siguiente cliente
        Carrito NO se limpia (Regla de Oro funciona)
        PERO Yami cree que se envió porque el error fue invisible

T=32s+  Yami cambia a otra cuenta → la cuenta de $453 se pierde
```

**Solución implementada (v6.1 — vigente hoy, 3 capas de protección):**
1. **Botón BLOQUEADO:** El botón "Enviar Cuenta" ahora se **deshabilita y se pone rojo** cuando `lastSaveStatus === 'failed'`. Es físicamente imposible enviarlo sin conexión. (`SalesReceipt.jsx`)
2. **Banner Rojo Fijo:** Un banner grande, rojo y parpadeante aparece en el ticket diciendo "⛔ SIN CONEXIÓN AL SERVIDOR — Los productos NO se están guardando". Ya no es un toast que desaparece. (`SalesReceipt.jsx`)
3. **Verificación Post-Envío:** Después de que `createTicket()` retorna HTTP 200, el sistema ejecuta un `GET /tickets/by-account/{folio}` para **confirmar que el ticket realmente existe** en la base de datos. Si la verificación falla, **NO limpia el carrito** y muestra una alerta de 10 segundos. (`useTicketActions.js`)

### Incidente Ticket Secuestrado por la CAJA — Terminal 5 (16/Junio/2026)

**Terminal afectada:** T5 y CAJA.
**Síntoma:** Un ticket (V34538) de $2,550 capturado en la Terminal 5 no aparecía bajo "T5" en la base de datos ni en las auditorías de esa terminal. Parecía estar extraviado, pero en realidad estaba bajo "CAJA".

**Causa raíz:**
1. Cuando la Terminal 5 reserva el ticket, se registra correctamente (`terminal_id='T5'`).
2. El ticket pasa al Pizarrón y queda en estado `OPEN`.
3. El cajero en "CAJA" abre el ticket desde el Pizarrón y lo cobra (`status='PAID'`).
4. **El Bug:** Al hacer `update_ticket_fields`, el backend aplicaba la regla: *"Asegurar que la terminal actual se convierte en la dueña del ticket"*, sobreescribiendo el `terminal_id` original ("T5") con la sesión actual ("CAJA").
5. Esto destruía la trazabilidad de qué tablet originó la venta.

**Solución implementada (vigente hoy):**
1. Se **eliminó** la sobreescritura de `terminal_id` en `apps/api/modules/pos/service.py` (`_update_ticket_fields`).
2. El `terminal_id` solo se asigna en `_initialize_new_ticket` y **jamás cambia**.
3. Las métricas del cobrador se mantienen a salvo porque se utilizan `cashed_by_id` y `cash_session_id`.

---

## 4. LAS REGLAS DE ORO SUPERVIVIENTES (v6.0)

A pesar de la simplificación, estas reglas de ingeniería siguen siendo **obligatorias** en la v6.0:

### ⚡ REGLA 1: Referencias Mutables (`useRef`) vs Closures
Aunque ya no hay timer de auto-save, React sigue siendo asíncrono. **Nunca** leas el carrito desde una variable de estado dentro de la lógica de finalización.
- ✅ OBLIGATORIO: Usar `cartRef.current`, `accountNumRef.current`, `ticketVersionRef.current`.
- ⛔ PROHIBIDO: Usar `cart`, `currentAccountNum` dentro de `handleTicketAction`.

### ⚡ REGLA 2: Mutex para Acciones Finales
El cobro y el envío al pizarrón (`handleTicketAction`) todavía usan `actionMutexRef`.
Esto evita que un cajero desespere, dé doble clic en "Cobrar", y se generen dos registros de pago para la misma cuenta.

### ⚡ REGLA 3: Zero-Loss en Acciones Finales
Cuando se cobra o se manda al pizarrón explícitamente, la UI **nunca** debe hacer `clearCart()` hasta que la petición HTTP finalice con éxito **Y se verifique que el ticket existe en el servidor** (v6.1).

### ⚡ REGLA 4: El Candado Anti-Wipe (v4.6)
Si el cajero pierde internet y presiona F5, React se reinicia con `cart = []`.
Para evitar que eso borre el carrito almacenado en `localStorage`, `useCart.js` tiene un candado estricto: `cartState.key === storageKey`. El localStorage jamás se sobreescribe hasta que el estado se haya hidratado primero.

### ⚡ REGLA 5: Visibilidad en el Pizarrón (DRAFT vs OPEN)
Debido a la persistencia atómica por ítem, un ticket se crea en la base de datos desde que se escanea el primer producto. Para evitar que dos personas abran y editen el mismo ticket al mismo tiempo, el ticket se mantiene en estado `DRAFT` y **NO es visible** en el Pizarrón de las demás terminales.
El ticket **solo cambia a estado `OPEN` (y se vuelve visible en el Pizarrón)** cuando el cajero da clic explícitamente en el botón "Guardar en Pizarrón". Esto previene colisiones multi-usuario de raíz.

### ⚡ REGLA 6: Protección Contra Olvidos (Exit Modal)
Como ahora se requiere una acción explícita para mandar una cuenta al Pizarrón, es frecuente que el personal olvide hacerlo y deje tickets en estado `DRAFT` huérfanos. Para remediarlo, el sistema cuenta con una protección: si un usuario intenta **salir del sistema** o **cambiar de terminal** teniendo un carrito con productos no enviados, se lanza un Modal de Advertencia bloqueante. Este modal le obliga a elegir entre "Enviar al Pizarrón y salir", "Salir perdiendo la cuenta", o "Cancelar".

### ⚡ REGLA 7: El "Draft Guard" (Blindaje Backend)
Por seguridad en la API, un ticket en estado `DRAFT` tiene un "dueño" (la terminal que lo creó). El backend (`_upsert_ticket_header`) prohíbe estrictamente que una terminal intente cobrar (`PAID`) un `DRAFT` que pertenece a otra terminal. Si Terminal B quiere cobrar la cuenta de Terminal A, Terminal A primero debe mandarla al Pizarrón (`OPEN`). Esto evita el "robo" accidental de tickets en progreso a nivel base de datos.

### ⚡ REGLA 8: Garbage Collector (Limpieza de Zombis)
Para evitar que la base de datos se llene de basura por pestañas cerradas bruscamente, el backend ejecuta un *Garbage Collector* silencioso cada vez que se reserva un folio (con un acelerador máximo de 1 vez por minuto). Este proceso:
1. Elimina físicamente los tickets vacíos (sin productos) que tengan más de 1 hora de antigüedad.
2. Cambia a estado `CANCELLED` los tickets `DRAFT` con productos que tengan más de 24 horas de abandono (configurable vía `pos_draft_ttl_days` en `SystemSetting`). Esto evita cuentas fantasma pero mantiene el registro para auditoría.

### ⚡ REGLA 9: Sync Obligatorio de `cartRef` en Recuperación (v4.5)
Cuando se recupera una cuenta del Pizarrón o se ejecuta un auto-heal por conflicto 409, `cartRef.current` debe sincronizarse **ANTES** de llamar a `setCart()`.
- ⛔ PROHIBIDO: `setCart(recovered)` sin sincronizar `cartRef` primero.
- ✅ OBLIGATORIO: `cartRef.current = recovered` seguido de `setCart(recovered)`.

**¿Por qué?** `setCart()` es asíncrono en React. Si otra operación lee `cartRef.current` entre el `setCart` y el siguiente render, leería datos obsoletos.

### ⚡ REGLA 10: Búsqueda Exacta por `account_num` (v4.5)
Para recuperar un ticket por su folio (recovery o auto-heal), se usa el endpoint `/tickets/by-account/{account_num}` con búsqueda exacta (`==`).
- ⛔ PROHIBIDO: Buscar tickets con `ilike('%V1300%')` para recovery. Esto coincide con V1300, V13000, V13001 y devuelve el ticket equivocado.
- ✅ OBLIGATORIO: Usar el endpoint de búsqueda exacta que retorna el ticket correcto o HTTP 404.

### ⚡ REGLA 11: Reciclaje de Tickets — Máximo 5 Minutos (v4.8)
Cuando una terminal reserva un folio, el sistema intenta reciclar un ticket vacío existente antes de generar uno nuevo. Sin embargo, solo se reciclan tickets creados hace **menos de 5 minutos**.
- ⛔ PROHIBIDO: Reciclar tickets vacíos sin límite de antigüedad (un ticket viejo pudo haber sido pagado y liberado en otro ciclo).
- ✅ OBLIGATORIO: Filtro `created_at >= (now - 5min)` en `_find_empty_ticket()`.

### ⚡ REGLA 12: Verificación Post-Envío al Pizarrón (v6.1)
Después de que `createTicket()` retorna éxito, el sistema debe hacer un `GET` de verificación para confirmar que el ticket existe en la base de datos antes de limpiar el carrito.
- ✅ OBLIGATORIO: Verificar existencia del ticket con `posService.getTicketByAccountNum(folio)` antes de `clearCart()`.
- ⛔ PROHIBIDO: Confiar ciegamente en el HTTP 200 de `createTicket()` sin verificar que el commit de PostgreSQL fue exitoso.
- Si la verificación falla: NO limpiar el carrito, mostrar alerta visible de 10+ segundos.

**¿Por qué?** El incidente de la cuenta fantasma $453 demostró que un HTTP 200 no garantiza que los datos persistan si hay problemas de red intermitentes o fallos de commit en la DB. La verificación añade ~50ms de latencia pero previene pérdida de datos.

### ⚡ REGLA 13: Bloqueo de Botón Sin Conexión (v6.1)
El botón "Enviar Cuenta" (Guardar en Pizarrón) debe estar **físicamente deshabilitado** cuando `lastSaveStatus === 'failed'`.
- ✅ OBLIGATORIO: `disabled={... || hasUnsavedItems}` en el botón del Pizarrón.
- ✅ OBLIGATORIO: Banner rojo visible y persistente (no un toast efímero) cuando los items no se están guardando.
- ⛔ PROHIBIDO: Permitir enviar al Pizarrón cuando hay items que fallaron la persistencia atómica.

**¿Por qué?** Un toast que desaparece en 5 segundos es invisible en hora pico. El cajero debe ver un indicador FIJO y el botón debe ser INOPERABLE hasta que la conexión se restablezca y los items se persistan exitosamente.

### ⚡ REGLA 14: Inmutabilidad de la Terminal de Origen
El campo `terminal_id` de un Ticket **solo** se asigna en su creación (`_initialize_new_ticket`).
- ⛔ PROHIBIDO: Sobreescribir el `terminal_id` al actualizar o cobrar el ticket en `_update_ticket_fields`.
- ✅ OBLIGATORIO: Para registrar quién cobró, usar exclusivamente `cashed_by_id` y `cash_session_id`.

**¿Por qué?** Si la CAJA recauda un ticket creado por un vendedor en una tablet, y la base de datos sobreescribe el `terminal_id` a "CAJA", se destruye la trazabilidad física de las ventas y la auditoría.

---

## 5. LÓGICA DE TERMINALES Y OCUPACIÓN

### 5.1 Estados Posibles de una Terminal

| Estado | Lock (DB) | CashSession | Descripción |
|--------|-----------|-------------|-------------|
| **Disponible** | ❌ No | ❌ No | Cualquier empleado puede entrar |
| **Ocupada (Sin Caja)** | ✅ Sí | ❌ No | Solo el dueño del lock la usa |
| **Ocupada (Con Caja)** | ✅ Sí | ✅ Abierta | Puede cobrar e imprimir tickets |
| **Caja Abierta sin Operador** | ❌ No | ✅ Abierta | El cajero se fue pero la CashSession sigue abierta |

### 5.2 Interacción del Usuario con Terminales
- **Logueado sin terminal:** Ve las desocupadas disponibles y las ocupadas con candado rojo.
- **Con terminal ocupada:** Si está usando T1, no puede usar otra sin soltar T1.
- **Sale de la terminal (cierra pestaña o unlock) pero con Caja Abierta:** La terminal se libera de su candado, pero como tiene `CashSession` activa, muestra "CAJA ABIERTA" sin operador.
- **Saca Corte de Caja:** La terminal pierde el estatus de "Caja", vuelve a ser terminal regular.
- **Es Administrador:** Tiene el botón de **FORZAR DESBLOQUEO** en terminales bloqueadas.

### 5.3 Heartbeat, TTL y Configuración

Todos los valores son **configurables desde `system_settings`** (tabla `SystemSetting`):

| Parámetro | Clave en `system_settings` | Default |
|-----------|---------------------------|---------|
| TTL de Lock | `pos_terminal_lock_ttl_m` | 15 min |
| TTL de Drafts para GC | `pos_draft_ttl_days` | 1 día |

**Regla de seguridad:** El `TTL` del lock siempre debe ser al menos **10 veces mayor** que el intervalo de heartbeat del frontend.

### 5.4 Desbloqueo Forzado, Permisos y Auditoría

#### Permisos requeridos (validados en BACKEND, no solo en frontend)

| Permiso en `SecurityProfile.permissions` | Permite |
|------------------------------------------|---------|
| `pos_force_unlock` = `"full"` o `true` | Desbloquear terminales regulares (sin caja) |
| `pos_force_cash_unlock` = `"full"` o `true` | Desbloquear terminales que tienen CashSession activa |
| `role` = `"ADMIN"` | Ambos permisos automáticamente |

> **REGLA ABSOLUTA:** El backend (`router.py → force_terminal_unlock`) valida los permisos consultando `Employee.profile.permissions` antes de ejecutar el desbloqueo. Si el usuario no tiene permisos, responde con HTTP 403. **NUNCA** confiar solo en que el frontend oculta el botón.

#### Traspuesta de Titularidad de Caja

Cuando se ejecuta Force Unlock en una terminal con `CashSession` activa:
1. El backend **elimina** el lock de `terminal_locks`.
2. El backend **cambia** el `employee_id` y `employee_name` de la `CashSession` activa al del usuario que ejecutó el desbloqueo.
3. Ambas operaciones ocurren en un **solo `db.commit()`** (transacción atómica). Si algo falla, ninguna se aplica.
4. **El cajero original pierde definitivamente la titularidad de esa sesión de caja.**

#### Auditoría de Force Unlock

Cada ejecución de `force_unlock` genera un log con: Terminal afectada, quién ejecutó el desbloqueo, a quién le fue quitado, si se transfirió la CashSession y timestamp. **Prohibido** eliminar o reducir este log.

### 5.5 Candados Persistentes (Regla Inamovible)
- Los candados de terminal viven **siempre** en la tabla `terminal_locks` de PostgreSQL.
- **NUNCA** almacenar candados en la RAM de Python (se pierden con cada reinicio de Docker).
- El frontend (`useTerminalLocking.js`) **NUNCA** expulsa automáticamente al cajero si pierde el lock — solo muestra una advertencia visual.
- El frontend **NUNCA** re-adquiere un lock perdido automáticamente.

### 5.6 Sesiones de Caja vs Candados de Terminal
- `terminal_locks`: Bloquea físicamente la pantalla (T1, T2, CAJA).
- `cash_sessions`: Permite que un empleado registre ingresos/egresos monetarios en una terminal habilitada para cobrar.

---

## 6. ARCHIVOS CRÍTICOS — MAPA DE ZONA RESTRINGIDA

| Archivo | Propósito | Peligro |
|---------|-----------|---------|
| `apps/api/modules/pos/occupancy.py` | Candados persistentes en PostgreSQL | ⚠️ NUNCA volver a usar RAM |
| `apps/api/modules/pos/router.py` | Endpoints de lock/unlock/heartbeat/status/force_unlock | ⚠️ force_unlock tiene permisos + auditoría |
| `apps/api/modules/pos/models.py` | Modelo `TerminalLock` + `Ticket` (version, UNIQUE constraints) | ⚠️ No modificar constraints |
| `apps/api/modules/pos/service.py` | Lógica de negocio: persistencia atómica, GC, folios, reciclaje | ⚠️ El corazón del POS |
| `apps/pos/hooks/useTicketActions.js` | Hook maestro v6.0: addToCart atómico, ticketAction, recovery | ⚠️ No reintroducir auto-save |
| `apps/pos/hooks/useCart.js` | Estado + localStorage del carrito (v4.6: Anti-Wipe) | ⚠️ NUNCA guardar a localStorage sin validar `cartState.key === storageKey` |
| `apps/pos/hooks/useTerminalLocking.js` | Polling + heartbeat del frontend | ⚠️ NUNCA re-adquirir lock automáticamente |
| `apps/pos/RetailVisionPOS.jsx` | Componente principal: captura, carrito, cobro | ⚠️ Leer este documento completo antes de tocar |
| `apps/api/modules/cash/models.py` | Modelo `CashSession` | ⚠️ La traspuesta modifica employee_id |
| `apps/api/modules/cash/router.py` | Cierre de caja (corte) | ⚠️ No confundir con force_unlock |

### Checklist para Revisión de Código

Antes de aprobar cualquier cambio que toque terminales, sesiones o tickets, verificar:

- [ ] ¿Los candados se persisten en PostgreSQL (tabla `terminal_locks`)?
- [ ] ¿El frontend NUNCA expulsa automáticamente basándose en fallos de polling?
- [ ] ¿El frontend NUNCA re-adquiere un lock perdido automáticamente?
- [ ] ¿Los folios de ticket se generan SOLO en el backend, sin fallbacks aleatorios?
- [ ] ¿El force_unlock valida permisos en el BACKEND (no solo frontend)?
- [ ] ¿El force_unlock transfiere la CashSession al nuevo operador?
- [ ] ¿El force_unlock y la traspuesta están en UN SOLO commit atómico?
- [ ] ¿El force_unlock registra auditoría?
- [ ] ¿El heartbeat renueva el lock en la base de datos?
- [ ] ¿Las cuentas del pizarrón solo desaparecen por cobro o cancelación explícita?
- [ ] ¿El `useEffect` de localStorage del carrito está protegido con el candado `cartState.key`?
- [ ] ¿`cartRef.current` se sincroniza ANTES de `setCart()` en toda recuperación?
- [ ] ¿El envío al Pizarrón verifica post-envío que el ticket existe antes de `clearCart()`? (v6.1)
- [ ] ¿El botón "Enviar Cuenta" está bloqueado cuando `lastSaveStatus === 'failed'`? (v6.1)
- [ ] ¿Hay un banner rojo FIJO (no toast) cuando los items fallan la persistencia atómica? (v6.1)

---

## 7. HISTORIAL DE REGLAS PRE-v6.0 (ARCHIVO HISTÓRICO)

> **⚠️ ATENCIÓN: Las reglas listadas en esta sección están OBSOLETAS.** Existieron durante la era del auto-save masivo (v4.0-v4.8) y fueron **eliminadas intencionalmente** al migrar a la arquitectura de persistencia atómica (v6.0). **NO deben reimplementarse.** Se documentan aquí únicamente como registro histórico para evitar que futuras IAs o desarrolladores las "redescubran" y las reintroduzcan.

| Regla Eliminada | Qué hacía | Por qué fue eliminada en v6.0 |
|-----------------|-----------|-------------------------------|
| **Auto-Save Bulk (Timer 15s)** | Un `setInterval` de 15 segundos enviaba el carrito completo al servidor. | Causa raíz de las race conditions, closures viejos y sobreescrituras que generaron el incidente del Ticket #906 y los falsos positivos de hora pico. La persistencia atómica por ítem elimina la necesidad de un timer. |
| **Regla de Debounce del Auto-Save** | Controlaba las dependencias del `useEffect` del timer para evitar disparos prematuros. | Ya no existe timer de auto-save que controlar. |
| **Flush de Seguridad en Recovery** | Al recuperar una cuenta del Pizarrón, primero se guardaba el carrito actual como medida de seguridad. | Con persistencia atómica, cada operación ya está en el servidor en el momento en que ocurre. No hay nada pendiente que "flushear". |
| **CollisionModal (UI Bloqueante para 409)** | Un modal que bloqueaba la pantalla del cajero cuando se detectaba un conflicto de versión HTTP 409. | Los conflictos 409 ahora se resuelven silenciosamente con auto-heal inline: el sistema descarga la versión fresca del servidor y actualiza la UI sin interrumpir al cajero. |
| **Actualización Síncrona de `version` en Auto-Save** | Tras cada ciclo de auto-save, se actualizaba `ticketVersionRef` sincrónicamente para evitar que el siguiente ciclo enviara una versión obsoleta. | Ya no hay ciclos de auto-save. La versión se sincroniza directamente en `handleAddToCart` y `handleTicketAction` al recibir la respuesta del servidor. |
| **Reasignación Automática de Folio** | Si un folio ya había sido pagado, el sistema automáticamente generaba un nuevo folio y transfería los items. | Eliminado por ser confuso para los cajeros. Ahora el sistema simplemente informa al usuario: "El folio X ya fue cobrado. Recupere la cuenta del Pizarrón o inicie una nueva." El cajero decide qué hacer. |

---

> **Esta es la FUENTE ÚNICA DE VERDAD de la v6.1.**
> El POS de R de Rico es un monumento a la evolución: construimos sistemas complejos para sobrevivir, aprendimos que la complejidad causaba errores, y los sustituimos por simplicidad atómica robusta.
> La v6.1 agrega una capa de verificación post-envío y bloqueo visual sin conexión, nacida del incidente de la cuenta fantasma $453.
>
> *Tu trabajo como IA no es reintroducir la complejidad antigua, sino proteger y expandir esta simplicidad.*
