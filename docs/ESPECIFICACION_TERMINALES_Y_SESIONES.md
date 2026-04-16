# ESPECIFICACIÓN TÉCNICA: GESTIÓN DE TERMINALES, SESIONES Y CUENTAS

> **DOCUMENTO NORMATIVO** — Cualquier IA, desarrollador o sistema que modifique la lógica de terminales, sesiones, polling, bloqueo/desbloqueo, creación de cuentas (tickets) o el pizarrón de cuentas abiertas **DEBE** leer y respetar este documento en su totalidad antes de escribir una sola línea de código.
>
> **Última actualización:** 2026-04-15
> **Aplicable a:** `apps/api/modules/pos/`, `apps/pos/hooks/`, `apps/pos/services/`, `apps/pos/RetailVisionPOS.jsx`

---

## 1. GLOSARIO DE CONCEPTOS

| Término | Definición |
|---------|-----------|
| **Terminal** | Una estación de trabajo física o lógica (T1, T2, T3, T4, T5, T6, CAJA) desde la que un empleado opera el POS. |
| **Lock (Candado)** | Registro en base de datos que indica que una terminal está siendo usada por un empleado específico. |
| **Sesión de Terminal** | Registro de apertura/cierre de una terminal para la operación del día. No confundir con lock. |
| **Sesión de Caja (CashSession)** | Registro que indica que una terminal está **habilitada como caja registradora** con fondo de apertura y tiene la capacidad de cobrar. |
| **Heartbeat** | Señal periódica que el frontend envía al backend para informar que el usuario sigue activo en la terminal. |
| **Polling** | Consulta periódica que el frontend hace al backend para obtener el estado actual de las terminales. |
| **TTL (Time To Live)** | Tiempo máximo que un lock puede existir sin recibir un heartbeat antes de ser considerado expirado. |
| **Pizarrón (Corkboard)** | Vista que muestra todas las cuentas abiertas (tickets con status OPEN y total > 0) de todas las terminales. |
| **Folio / Número de Cuenta** | Identificador único de un ticket, con formato `V{NNNN}` (ej: V0001, V0002). |
| **Cuenta Fantasma** | Bug donde un ticket aparece y luego desaparece del pizarrón, o donde un número de cuenta se reutiliza inesperadamente. |
| **Expulsión** | Acción de sacar a un usuario de su terminal, cerrando su acceso al POS en esa estación. |

---

## 2. REGLA DE ORO: LOS CANDADOS SON PERSISTENTES

> **PROHIBIDO TERMINANTEMENTE** almacenar el estado de ocupación de terminales en memoria RAM (diccionarios Python, variables globales, caché en proceso, etc.).

### Fundamentación

El backend (API) corre dentro de Docker. Docker puede reiniciar el container en cualquier momento por:
- Health checks fallidos
- Actualizaciones de imagen
- Reinicio del host
- Hot-reload de uvicorn en desarrollo
- Límites de memoria

Si los candados viven en RAM, **todos se pierden instantáneamente** con cualquier reinicio. El frontend, que sigue haciendo polling, detecta que "su candado ya no existe" y expulsa al usuario — aunque el usuario esté en medio de una captura de cuenta.

### Implementación Correcta

```
Los candados DEBEN vivir en una tabla de PostgreSQL: terminal_locks

Columnas:
  - id: INTEGER PRIMARY KEY
  - terminal_id: VARCHAR UNIQUE (ej: "T5", "CAJA")
  - occupier_id: INTEGER (ID del empleado que la ocupa)
  - occupier_name: VARCHAR (nombre del empleado, para mostrar en UI)
  - locked_at: TIMESTAMP (cuándo se adquirió/renovó el lock)
```

### Operaciones sobre Locks

| Operación | Endpoint | Comportamiento |
|-----------|----------|---------------|
| **Adquirir** | `POST /terminals/{id}/lock` | Crea registro en `terminal_locks`. Si ya existe uno del mismo usuario, renueva `locked_at`. Si existe de otro usuario, rechaza con 400. Un usuario solo puede tener 1 terminal activa a la vez (locks anteriores del mismo usuario se eliminan). |
| **Liberar** | `POST /terminals/{id}/unlock` | Elimina registro de `terminal_locks` SOLO si el `occupier_id` coincide con el solicitante. |
| **Forzar liberación** | `POST /terminals/{id}/force_unlock` | Elimina registro de `terminal_locks` SIN verificar quién lo posee. Solo administradores deben poder invocarlo. |
| **Heartbeat** | `POST /terminals/{id}/heartbeat` | Actualiza `locked_at` al timestamp actual. Solo si el `occupier_id` coincide. |
| **Consultar** | `GET /terminals/status` | Devuelve todos los locks activos (no expirados) + sesiones de caja abiertas. |

---

## 3. ESTADOS DE UNA TERMINAL

Una terminal puede estar en uno de estos estados, **y solo estos**:

```
┌─────────────────────┐
│    DISPONIBLE        │  No hay lock ni CashSession
│    (Desocupada)      │  Cualquier empleado puede entrar
└─────────┬───────────┘
          │ Empleado selecciona terminal
          ▼
┌─────────────────────┐
│    OCUPADA           │  Hay un lock en terminal_locks
│    (Sin Caja)        │  Solo el dueño del lock la usa
└─────────┬───────────┘
          │ Empleado habilita caja (abre CashSession)
          ▼
┌─────────────────────┐
│    OCUPADA           │  Hay lock + CashSession abierta
│    (Con Caja)        │  Puede cobrar, imprimir tickets
└─────────┬───────────┘
          │ Empleado saca corte (cierra CashSession)
          ▼
┌─────────────────────┐
│    OCUPADA           │  Hay lock pero ya no hay CashSession
│    (Post-Corte)      │  No puede cobrar, solo capturar
└─────────┬───────────┘
          │ Empleado sale de terminal (unlock)
          ▼
┌─────────────────────┐
│    DISPONIBLE        │  Lock eliminado
└─────────────────────┘
```

### Caso Especial: Terminal con CashSession pero sin Lock

Esto ocurre cuando:
- El empleado cerró el navegador sin hacer logout
- El container se reinició y el lock expiró por TTL
- El empleado fue desconectado de la red

En este caso, la terminal aparece como **OCUPADA** porque la CashSession sigue abierta en la base de datos. Nadie más puede usarla como caja hasta que se cierre la CashSession (corte) o un admin fuerce la liberación.

---

## 4. REGLAS DE POLLING Y HEARTBEAT

### 4.1 Heartbeat (Frontend → Backend)

| Parámetro | Valor por Defecto | Configurable Vía |
|-----------|-------------------|-------------------|
| Intervalo | 20,000 ms (20s) | `pos_heartbeat_interval_ms` en tabla `system_settings` |

**Comportamiento:**
- El frontend envía `POST /terminals/{id}/heartbeat` cada N segundos con el `occupier_id`.
- El backend actualiza `locked_at` en `terminal_locks`.
- **Si el heartbeat falla** (error de red, timeout), el frontend **DEBE intentar re-adquirir el lock** automáticamente con `POST /terminals/{id}/lock`. No debe expulsar al usuario.

### 4.2 Polling de Estado (Frontend → Backend)

| Parámetro | Valor por Defecto | Propósito |
|-----------|-------------------|-----------|
| Status Polling | 5,000 ms (5s) | Actualizar la UI de selección de terminales |
| Check Lock Polling | 15,000 ms (15s) | Verificar si el lock propio sigue activo |

**Comportamiento del Check Lock:**
- El frontend consulta `GET /terminals/status` cada N segundos.
- Si su lock NO aparece en la respuesta:
  1. **Primer intento:** Re-adquirir el lock silenciosamente con `POST /lock`.
  2. **Si la re-adquisición tiene éxito:** Continuar sin notificar al usuario.
  3. **Si la re-adquisición falla porque OTRA persona tiene la terminal:** Mostrar modal de expulsión.
  4. **Si la re-adquisición falla por error de red:** NO expulsar. Reintentar en el siguiente ciclo de polling.

### 4.3 TTL (Time To Live) de Locks

| Parámetro | Valor por Defecto | Configurable Vía |
|-----------|-------------------|-------------------|
| TTL | 15 minutos | `pos_terminal_lock_ttl_m` en tabla `system_settings` |

**Comportamiento:**
- Al consultar locks, el backend elimina automáticamente los que tengan `locked_at` más viejo que `ahora - TTL`.
- El heartbeat renueva `locked_at`, evitando que el lock expire.
- **El TTL es una red de seguridad**, no un mecanismo de operación normal. Si el TTL expira, significa que algo falló (el navegador se cerró, la red se cayó, etc.).

---

## 5. REGLA ABSOLUTA: NUNCA EXPULSAR AUTOMÁTICAMENTE

> **PROHIBIDO** que el frontend expulse automáticamente a un usuario basándose en conteos de polls fallidos, timeouts de red, o cualquier heurística.

### ¿Quién puede expulsar?

| Acción | ¿Puede expulsar? | Mecanismo |
|--------|-------------------|-----------|
| El propio usuario sale voluntariamente | ✅ Sí | Botón "Cambiar Estación" → `POST /unlock` |
| Un admin fuerza la liberación | ✅ Sí | Botón "Forzar Desbloqueo" → `POST /force_unlock` |
| El TTL expira por inactividad real | ✅ Sí (pasivo) | El lock se purga automáticamente después de 15 min sin heartbeat |
| El polling detecta que otro usuario tomó la terminal | ✅ Sí | Mostrar modal informativo + redirigir a selección |
| El polling detecta que el lock "desapareció" | ❌ **NO** | Re-adquirir silenciosamente |
| Hay errores de red | ❌ **NO** | Ignorar y reintentar |
| El heartbeat falla N veces | ❌ **NO** | Re-intentar el heartbeat o el lock |

---

## 6. GENERACIÓN DE NÚMEROS DE CUENTA (FOLIOS)

### Formato

Todos los folios siguen el formato: `V{NNNN}` donde NNNN es el ID auto-incrementado del ticket en la base de datos, con padding de ceros a la izquierda.

Ejemplos: `V0001`, `V0042`, `V0123`, `V1050`

### Reglas Absolutas

1. **Los folios se generan SOLO en el backend.** El frontend NUNCA debe inventar un número de cuenta.
2. **No existen folios temporales.** PROHIBIDO crear tickets con nombres como `TEMP_xxxx`, `DRAFT_xxxx`, o cualquier prefijo temporal que luego se renombre. El folio definitivo se asigna desde la creación.
3. **No existen folios aleatorios.** PROHIBIDO generar folios con `Math.random()`, `uuid()`, o cualquier mecanismo de azar. Los folios son estrictamente secuenciales.
4. **Si la reserva falla, el frontend debe reintentar**, no inventar un número local. Después de 3 reintentos fallidos, mostrar un error al usuario.
5. **Los folios son ÚNICOS.** La columna `account_num` en la tabla `tickets` tiene constraint `UNIQUE`. Si se intenta crear un ticket con un folio que ya existe, la base de datos lo rechaza.

### Proceso de Reserva (Lazy Reservation)

```
1. El usuario agrega el PRIMER producto al carrito
2. El frontend llama POST /tickets/reserve con el terminal_id
3. El backend:
   a. Busca un ticket vacío (OPEN, total=0, sin items) de la misma sesión → lo recicla
   b. Si no hay reciclables, crea uno nuevo con folio V{max_id + 1}
   c. Devuelve el ticket con su folio definitivo
4. El frontend usa ese folio para todas las operaciones subsecuentes
```

**¿Por qué "Lazy"?** El folio NO se reserva al abrir la terminal ni al crear una nueva venta. Se reserva solo cuando el usuario agrega el primer producto. Esto evita la creación de tickets vacíos que llenan el pizarrón de ruido.

---

## 7. PIZARRÓN DE CUENTAS ABIERTAS (CORKBOARD)

### ¿Qué muestra?

El pizarrón muestra **todas las cuentas con status `OPEN` y total > 0** de todas las terminales.

### Reglas

1. **Los tickets con total $0.00 NO aparecen** en el pizarrón. Son "reservas vacías" y no tienen valor operativo.
2. **Los tickets con status `PAID` o `CANCELLED` NO aparecen.**
3. **Cualquier terminal puede ver todas las cuentas** de todas las terminales (visión global).
4. **Cualquier terminal puede recuperar cualquier cuenta** del pizarrón y continuar la captura o cobrarla.
5. **Al recuperar una cuenta**, el sistema DEBE preservar el `captured_by_id` original (quién la creó), incluso si otro empleado es quien la cobra finalmente.

### Integridad del Pizarrón

> **PROHIBIDO** que una cuenta "desaparezca" del pizarrón sin una acción explícita del usuario (cobrar, cancelar, o eliminar).

Las únicas formas legítimas de que una cuenta salga del pizarrón son:
1. Se cobra (status cambia a `PAID`)
2. Se cancela (status cambia a `CANCELLED`)
3. Se eliminan todos sus items (el total baja a $0.00 y el filtro la oculta)

---

## 8. FORCE UNLOCK — DESBLOQUEO FORZADO POR ADMIN

### ¿Qué hace?

Elimina el registro de `terminal_locks` para una terminal específica, sin importar quién la tenía.

### ¿Qué NO debe hacer?

- **NO debe cerrar la CashSession.** El corte de caja es una operación contable separada.
- **NO debe transferir la propiedad de la CashSession** al admin que fuerza el desbloqueo.
- **NO debe eliminar tickets abiertos** de esa terminal.
- **NO debe cerrar la TerminalSession.**

### Flujo Esperado

```
1. Admin ve que Terminal T5 está bloqueada por "JUAN"
2. Admin presiona "Forzar Desbloqueo"
3. Backend: Elimina el lock de T5 en terminal_locks
4. El polling del frontend de JUAN detecta que su lock ya no existe
5. JUAN recibe modal informativo: "Un administrador liberó tu terminal"
6. JUAN es redirigido a la pantalla de selección de terminal
7. La CashSession de T5 (si existía) sigue abierta — JUAN u otro empleado
   pueden volver a entrar a T5 y continuar con la sesión de caja existente
```

---

## 9. RELACIÓN ENTRE CONCEPTOS

```
┌───────────────────────────────────────────────────────────────┐
│                        EMPLEADO                               │
│  (id, name, employee_code, role, profile)                     │
└───────┬───────────────────────┬───────────────────────────────┘
        │                       │
        │ OCUPA (1 a la vez)    │ ABRE/CIERRA
        ▼                       ▼
┌───────────────┐       ┌───────────────────┐
│ TerminalLock  │       │   CashSession     │
│ (terminal_id, │       │ (terminal_id,     │
│  occupier_id, │       │  employee_id,     │
│  locked_at)   │       │  status: OPEN/    │
│               │       │  CLOSED,          │
│ PERSISTENTE   │       │  opening_float)   │
│ en PostgreSQL │       │                   │
└───────┬───────┘       │  PERSISTENTE      │
        │               │  en PostgreSQL    │
        │               └───────┬───────────┘
        │                       │
        │  AMBOS apuntan a      │
        ▼  la misma terminal    ▼
┌───────────────────────────────────────────┐
│              TERMINAL (lógica)            │
│  ID: "T1", "T2", "T3", "T4", "T5", etc. │
│                                           │
│  Estado visible = Lock ∪ CashSession      │
│  - Si tiene Lock → OCUPADA               │
│  - Si tiene CashSession OPEN → CAJA ACT. │
│  - Si tiene ambos → OCUPADA + CAJA ACT.  │
│  - Si no tiene nada → DISPONIBLE          │
└───────────────────────────────────────────┘
```

---

## 10. AJUSTES CONFIGURABLES DEL SISTEMA

Todos los parámetros de polling y TTL son configurables desde el módulo "Ajustes del Sistema" del ERP, almacenados en la tabla `system_settings`:

| Clave | Valor Default | Unidad | Descripción |
|-------|---------------|--------|-------------|
| `pos_terminal_status_polling_ms` | 5000 | ms | Frecuencia de consulta del estado de terminales en la pantalla de selección |
| `pos_terminal_check_lock_interval_ms` | 15000 | ms | Frecuencia de verificación del lock propio cuando ya estás dentro de una terminal |
| `pos_heartbeat_interval_ms` | 20000 | ms | Frecuencia del heartbeat que renueva el TTL del lock |
| `pos_terminal_lock_ttl_m` | 15 | minutos | Tiempo máximo que un lock puede existir sin heartbeat antes de expirar |

### Relación entre Parámetros

```
heartbeat_interval < TTL
         20s       <  15min    ✅ CORRECTO: el heartbeat renueva antes de expirar

Si heartbeat_interval >= TTL → El lock expirará antes del siguiente heartbeat → EXPULSIÓN GARANTIZADA
                                Esto es un ERROR DE CONFIGURACIÓN.
```

**Regla de seguridad:** `TTL` siempre debe ser al menos **10 veces mayor** que `heartbeat_interval`.

---

## 11. ANTI-PATRONES — LO QUE NUNCA SE DEBE HACER

### ❌ Almacenar candados en RAM
```python
# PROHIBIDO — Se pierde con reinicio
_locks: Dict[str, dict] = {}
```

### ❌ Expulsar por conteo de polls fallidos
```javascript
// PROHIBIDO — Causa expulsiones falsas por errores de red
if (failedChecks >= 5) {
    setForceLogoutModal(true);  // NUNCA hacer esto
}
```

### ❌ Generar folios aleatorios como fallback
```javascript
// PROHIBIDO — Puede colisionar con folios existentes y sobrescribir tickets
const num = Math.floor(1000 + Math.random() * 9000);
const fallbackNum = `V${num}`;
```

### ❌ Usar nombres temporales para tickets
```python
# PROHIBIDO — Puede dejar tickets huérfanos con nombre TEMP_
temp_num = f"TEMP_{uuid.uuid4().hex[:4]}"
db_ticket = Ticket(account_num=temp_num, ...)
# ... y luego renombrar
db_ticket.account_num = f"V{db_ticket.id:04d}"
```

### ❌ Transferir propiedad de CashSession en force_unlock
```python
# PROHIBIDO — Causa que el admin "herede" una caja ajena
await db.execute(
    update(CashSession)
    .where(CashSession.terminal_id == tid, CashSession.status == "OPEN")
    .values(employee_id=req.occupier_id, employee_name=req.occupier_name)
)
```

### ❌ Dejar que el frontend "adivine" si fue forzado el desbloqueo
```javascript
// PROHIBIDO — El frontend no debe tener lógica heurística de expulsión
// La ÚNICA forma de expulsar es que el backend confirme explícitamente
// que otra persona ahora ocupa la terminal
```

---

## 12. CHECKLIST PARA REVISIÓN DE CÓDIGO

Antes de aprobar cualquier cambio que toque terminales, sesiones o tickets, verificar:

- [ ] ¿Los candados se persisten en PostgreSQL (tabla `terminal_locks`)?
- [ ] ¿El frontend NUNCA expulsa automáticamente basándose en fallos de polling?
- [ ] ¿Los folios de ticket se generan SOLO en el backend, sin fallbacks aleatorios?
- [ ] ¿No se usan nombres temporales (TEMP_, DRAFT_) para tickets?
- [ ] ¿El force_unlock NO toca la CashSession?
- [ ] ¿El heartbeat renueva el lock en la base de datos?
- [ ] ¿El TTL es al menos 10x mayor que el intervalo de heartbeat?
- [ ] ¿Las cuentas del pizarrón solo desaparecen por cobro o cancelación explícita?

---

## 13. ARCHIVOS RELEVANTES

| Archivo | Propósito | Tocar con cuidado |
|---------|-----------|-------------------|
| `apps/api/modules/pos/occupancy.py` | Lógica de candados persistentes | ⚠️ Nunca volver a meter RAM |
| `apps/api/modules/pos/models.py` | Modelo `TerminalLock` + `Ticket` | ⚠️ No modificar constraints |
| `apps/api/modules/pos/router.py` | Endpoints de lock/unlock/heartbeat/status | ⚠️ Todas las rutas pasan `db` |
| `apps/api/modules/pos/service.py` | `_generate_consecutive_ticket` | ⚠️ Sin TEMP, sin race conditions |
| `apps/pos/hooks/useTerminalLocking.js` | Polling + heartbeat del frontend | ⚠️ NUNCA auto-expulsar |
| `apps/pos/RetailVisionPOS.jsx` | `generateNewAccountNum` | ⚠️ Sin fallback aleatorio |
| `apps/pos/services/POSService.js` | Llamadas HTTP al backend | Interfaz estable |
| `apps/api/modules/settings/` | Ajustes configurables de polling/TTL | Valores en `system_settings` |

---

*Este documento es la fuente de verdad para la gestión de terminales del ERP R de Rico. Si algún cambio contradice lo aquí especificado, este documento prevalece.*
