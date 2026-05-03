# MANUAL MAESTRO PARA IAs: LÓGICA DE TERMINALES, SESIONES Y CAJAS

> **¡ATENCIÓN A CUALQUIER IA O DESARROLLADOR!**
> Lee este documento **COMPLETO** antes de proponer, modificar o analizar cualquier código relacionado con el Punto de Venta (POS), selección de terminales, candados (locks), cuentas, o sesiones de caja. Cualquier modificación que rompa las reglas descritas aquí es considerada una **falla crítica de arquitectura**.
>
> **Última actualización:** 2026-05-03
> **Versión de arquitectura:** v4.6 (anti-wipe + hardened)
> **Archivos gobernados:** `apps/api/modules/pos/`, `apps/pos/hooks/`, `apps/pos/services/`, `apps/pos/RetailVisionPOS.jsx`, `apps/api/modules/cash/`

---

## 1. LA REGLA DE ORO: CANDADOS PERSISTENTES

**NUNCA** utilices la memoria RAM (diccionarios Python, variables globales, cachés locales) para guardar el estado de "quién está usando qué terminal".
* **Motivo:** Los contenedores Docker (o los servidores uvicorn) se reinician. Si el candado estaba en RAM, se pierde, causando que el usuario sea expulsado en medio de su captura de cobro.
* **Solución Obligatoria:** Todo candado debe vivir en la base de datos PostgreSQL, específicamente en la tabla `terminal_locks`. El backend simplemente consulta la BD.

### Estructura de la tabla `terminal_locks`
```
Columnas:
  - id: INTEGER PRIMARY KEY
  - terminal_id: VARCHAR UNIQUE (ej: "T5", "CAJA")
  - occupier_id: INTEGER (ID del empleado que la ocupa)
  - occupier_name: VARCHAR (nombre del empleado)
  - locked_at: TIMESTAMP (cuándo se adquirió/renovó el lock)
```

### Operaciones sobre Locks

| Operación | Endpoint | Comportamiento |
|-----------|----------|---------------|
| **Adquirir** | `POST /terminals/{id}/lock` | Crea registro. Si ya existe uno del mismo usuario, renueva. Si existe de otro, rechaza con 400. Limpia locks anteriores del mismo usuario en otras terminales (regla 1 usuario = 1 terminal). |
| **Liberar** | `POST /terminals/{id}/unlock` | Elimina registro SOLO si el `occupier_id` coincide. |
| **Forzar liberación** | `POST /terminals/{id}/force_unlock` | Elimina lock, transfiere CashSession, requiere permisos (ver Sección 4). |
| **Heartbeat** | `POST /terminals/{id}/heartbeat` | Actualiza `locked_at`. Purga locks expirados. Limpia locks del mismo usuario en otras terminales. |
| **Consultar** | `GET /terminals/status` | Devuelve todos los locks activos + sesiones de caja abiertas. |

---

## 2. REGLA DE EXPULSIÓN Y ANTI-PATRONES

### Anti-Patrón 1: Robo Involuntario de Candados (Ping-Pong)
* **Historia del Error (resuelto 2026-04-23):** El frontend detectaba que había perdido su candado (por inactividad o porque el usuario inició sesión en otra terminal) y automáticamente intentaba re-adquirirlo llamando a `POST /lock` sin intervención del usuario. Como el backend respeta la regla "1 usuario = 1 terminal activa", borraba el candado de la terminal legítima y se lo daba a la vieja terminal. Inmediatamente la terminal legítima notaba que perdió su candado y hacía lo mismo, creando un ciclo infinito donde el estatus saltaba de una a otra cada pocos segundos.
* **Archivo corregido:** `apps/pos/hooks/useTerminalLocking.js` — Se eliminaron las llamadas a `posService.lockTerminal()` dentro de `checkMyLock` y `sendHeartbeat`.
* **Regla Estricta:** El Frontend **NUNCA DEBE INTENTAR RE-ADQUIRIR** un candado perdido automáticamente en su bloque de `catch` o en sus rutinas de *polling* (como `checkMyLock`). Si el candado se perdió, se debe mostrar una **advertencia visual** en la UI, pero el frontend debe "aceptar la derrota" y no volver a enviar peticiones de candado hasta que el usuario recargue o tome una acción explícita.

### Anti-Patrón 2: Expulsión por Fallos de Red
* **Regla Estricta:** **PROHIBIDO** que el frontend expulse al usuario de su pantalla de trabajo (redirigiendo al inicio) basándose en *timeouts* de red o *polls* fallidos. 
* La **única** forma en que un usuario es forzado a salir de la terminal sin su consentimiento directo es si un Administrador utiliza explícitamente el endpoint `POST /force_unlock`, en cuyo caso el backend asigna la terminal a otra persona, y el *polling* muestra un Modal Informativo de Expulsión justificada.

### Anti-Patrón 3: Candados en RAM
```python
# PROHIBIDO — Se pierde con reinicio de container
_locks: Dict[str, dict] = {}
```

### Anti-Patrón 4: Folios aleatorios como fallback
```javascript
// PROHIBIDO — Puede colisionar con folios existentes
const num = Math.floor(1000 + Math.random() * 9000);
const fallbackNum = `V${num}`;
```

### Anti-Patrón 5: Nombres temporales para tickets
```python
# PROHIBIDO — Puede dejar tickets huérfanos
temp_num = f"TEMP_{uuid.uuid4().hex[:4]}"
```

### Anti-Patrón 6: Inicialización de estado vs Efectos (Sobreescritura de Datos)
* **Historia del Error (resuelto 2026-05-03):** Cuando el cajero perdía la conexión de red (o había un "mal cable LAN"), el sistema guardaba el ticket offline en `localStorage`. Si el cajero presionaba `F5` y volvía a seleccionar su terminal, el sistema inicializaba el estado de React del carrito como vacío (`[]`), y *luego* ejecutaba el `useEffect` para guardar en `localStorage`. Esto sobrescribía silenciosamente los datos guardados, borrando el ticket por completo.
* **Archivo corregido:** `apps/pos/hooks/useCart.js` — Se introdujo una máquina de estados `cartState` que guarda tanto el `storageKey` como los `items`.
* **Regla Estricta:** El `useEffect` encargado de **GUARDAR** al disco local `localStorage` **SIEMPRE** debe estar protegido por un candado de sincronización de llave (`if (cartState.key === storageKey)`). NUNCA debes confiar en la inicialización estática de `useState` cuando la llave de almacenamiento (`storageKey`) dependa de una prop dinámica (`selectedTerminal`). Al cambiar la llave, primero debes cargar los datos antes de permitir cualquier operación de guardado.

---

## 3. LÓGICA Y ESTADOS DE TERMINAL (MATRIZ DE INTERACCIÓN)

La UI ("Selecciona Tu Terminal") debe comportarse estrictamente de acuerdo al estado del usuario y la terminal:

### A) Estados posibles
| Estado | Lock | CashSession | Descripción |
|--------|------|-------------|-------------|
| **Disponible** | ❌ No | ❌ No | Cualquier empleado puede entrar |
| **Ocupada (Sin Caja)** | ✅ Sí | ❌ No | Solo el dueño del lock la usa |
| **Ocupada (Con Caja)** | ✅ Sí | ✅ Abierta | Puede cobrar e imprimir tickets |
| **Caja Abierta sin Operador** | ❌ No | ✅ Abierta | El cajero se fue pero la CashSession sigue abierta |

### B) Interacción del Usuario
* **Logueado sin terminal:** Ve las desocupadas disponibles y las ocupadas con candado rojo.
* **Logueado con terminal ocupada (en uso):** Si está usando la T1, no debe poder usar otra terminal sin soltar la T1.
* **Sale de la terminal (Cierra Pestaña o Unlock) pero con Caja Abierta:** La terminal se libera de su candado, pero como tiene `CashSession` activa, muestra "CAJA ABIERTA" sin operador presente.
* **Saca Corte de Caja:** La terminal pierde el estatus de "Caja", y vuelve a ser una terminal regular.
* **Es Administrador:** Tiene el "Poder" de ver un botón especial de **FORZAR DESBLOQUEO** en terminales bloqueadas.

### C) Heartbeat y TTL

| Parámetro | Valor Default | Valor Producción (03/May/2026) | Clave en `system_settings` |
|-----------|---------------|-------------------------------|---------------------------|
| Status Polling | 5,000 ms | 3,000 ms | `pos_terminal_status_polling_ms` |
| Check Lock Polling | 15,000 ms | 15,000 ms | `pos_terminal_check_lock_interval_ms` |
| Heartbeat | 20,000 ms | 60,000 ms | `pos_heartbeat_interval_ms` |
| TTL de Lock | 15 minutos | **20 minutos** | `pos_terminal_lock_ttl_m` |

**Regla de seguridad:** `TTL` siempre debe ser al menos **10 veces mayor** que `heartbeat_interval`.

> **NOTA DE OPERACIÓN (2026-05-03):** El TTL se incrementó de 15 a 20 minutos tras el incidente del 02/Mayo donde micro-cortes de red causaron expulsiones masivas de cajeros. Con heartbeat=60s y TTL=20min, el ratio es 20x (cumple la regla de 10x). Si la red se estabiliza, se puede reducir a 15 min. **No subir más de 30 min** para evitar que terminales fantasma bloqueen cajeros por demasiado tiempo.

---

## 4. DESBLOQUEO FORZADO, PERMISOS Y AUDITORÍA (v4.4 hardened)

### Permisos requeridos (validados en BACKEND, no solo en frontend)

| Permiso en `SecurityProfile.permissions` | Permite |
|------------------------------------------|---------|
| `pos_force_unlock` = `"full"` o `true` | Desbloquear terminales regulares (sin caja) |
| `pos_force_cash_unlock` = `"full"` o `true` | Desbloquear terminales que tienen CashSession activa |
| `role` = `"ADMIN"` | Ambos permisos automáticamente |

> **REGLA ABSOLUTA:** El backend (`router.py → force_terminal_unlock`) valida los permisos consultando `Employee.profile.permissions` antes de ejecutar el desbloqueo. Si el usuario no tiene permisos, responde con HTTP 403. **NUNCA** confiar solo en que el frontend oculta el botón.

### Traspuesta de Titularidad de Caja

Cuando se ejecuta Force Unlock en una terminal con `CashSession` activa:
1. El backend **elimina** el lock de `terminal_locks`.
2. El backend **cambia** el `employee_id` y `employee_name` de la `CashSession` activa al del usuario que ejecutó el desbloqueo.
3. Ambas operaciones ocurren en un **solo `db.commit()`** (transacción atómica). Si algo falla, ninguna se aplica.
4. **El cajero original pierde definitivamente la titularidad de esa sesión de caja.**

### Auditoría de Force Unlock

Cada ejecución de `force_unlock` genera un log en el servidor con el formato:
```
🔓 FORCE UNLOCK: Terminal=T5 |
   Ejecutado por: VICTOR (id=1) |
   Quitado a: JUAN (id=3) |
   CashSession transferida: True |
   Timestamp: 2026-04-23T19:30:00
```

> **PROHIBIDO** eliminar o reducir este log. Es evidencia de auditoría para operaciones con manejo de efectivo.

---

## 5. GENERACIÓN DE FOLIOS (CUENTAS) Y EL PIZARRÓN

### Reglas de Folios
1. **Folios 100% en Backend:** El Frontend tiene **PROHIBIDO** inventar folios, ni temporales (`TEMP_123`) ni aleatorios (`Math.random()`). El único folio válido es `V{id_incremental_db}`.
2. **Secuencia PostgreSQL atómica:** Los folios se generan con `nextval('ticket_folio_seq')`, garantizando unicidad incluso con 6 terminales pidiendo folio simultáneamente.
3. **Lazy Reservation:** Un ticket vacío no tiene folio. Cuando el usuario agrega el **primer producto**, el frontend pide un `POST /tickets/reserve` y el backend recicla un ticket vacío o le asigna uno secuencial.
4. **Bloqueo Optimista:** Cada ticket tiene un campo `version` que se incrementa en cada update. Si dos terminales intentan modificar la misma cuenta, el backend rechaza con HTTP 409 y el frontend muestra un `CollisionModal`.

### Reglas del Pizarrón (Corkboard)
1. **Solo Total > 0:** Cuentas con total $0.00 NO aparecen en el pizarrón.
2. **Visión Global:** Todas las terminales ven todas las cuentas abiertas de las demás terminales.
3. **Persistencia del Creador:** Si la terminal T4 abre la cuenta de Juan, pero luego la terminal T5 (con Ana) la recupera para cobrarla, el `captured_by_id` debe seguir diciendo "Juan" (creador original).
4. **Desaparición:** Un ticket solo sale del pizarrón si se COBRA (cambia a PAID), se CANCELA, o se vacía su carrito. No pueden "desaparecer" silenciosamente por timeouts de interfaz.

---

## 6. ARCHIVOS CRÍTICOS — NO TOCAR SIN LEER ESTE DOCUMENTO

| Archivo | Propósito | Peligro |
|---------|-----------|---------|
| `apps/api/modules/pos/occupancy.py` | Candados persistentes en PostgreSQL | ⚠️ NUNCA volver a meter RAM |
| `apps/api/modules/pos/router.py` | Endpoints de lock/unlock/heartbeat/status/force_unlock | ⚠️ force_unlock tiene permisos + auditoría |
| `apps/api/modules/pos/models.py` | Modelo `TerminalLock` + `Ticket` (version, UNIQUE constraints) | ⚠️ No modificar constraints |
| `apps/api/modules/pos/service.py` | `_generate_consecutive_ticket` + secuencia atómica | ⚠️ Sin TEMP, sin race conditions |
| `apps/pos/hooks/useTerminalLocking.js` | Polling + heartbeat del frontend | ⚠️ NUNCA re-adquirir lock automáticamente |
| `apps/pos/hooks/useCart.js` | Estado + localStorage del carrito (v4.6: Anti-Wipe) | ⚠️ NUNCA guardar a localStorage sin validar `cartState.key === storageKey` |
| `apps/pos/RetailVisionPOS.jsx` | `generateNewAccountNum` + mutex | ⚠️ Sin fallback aleatorio |
| `apps/api/modules/cash/models.py` | Modelo `CashSession` | ⚠️ La traspuesta modifica employee_id |
| `apps/api/modules/cash/router.py` | Cierre de caja (corte) | ⚠️ No confundir con force_unlock |

---

## 7. CHECKLIST PARA REVISIÓN DE CÓDIGO

Antes de aprobar cualquier cambio que toque terminales, sesiones o tickets, verificar:

- [ ] ¿Los candados se persisten en PostgreSQL (tabla `terminal_locks`)?
- [ ] ¿El frontend NUNCA expulsa automáticamente basándose en fallos de polling?
- [ ] ¿El frontend NUNCA re-adquiere un lock perdido automáticamente?
- [ ] ¿Los folios de ticket se generan SOLO en el backend, sin fallbacks aleatorios?
- [ ] ¿No se usan nombres temporales (TEMP_, DRAFT_) para tickets?
- [ ] ¿El force_unlock valida permisos en el BACKEND (no solo frontend)?
- [ ] ¿El force_unlock transfiere la CashSession al nuevo operador?
- [ ] ¿El force_unlock y la traspuesta están en UN SOLO commit atómico?
- [ ] ¿El force_unlock registra auditoría con ejecutor, víctima y timestamp?
- [ ] ¿El heartbeat renueva el lock en la base de datos?
- [ ] ¿El TTL es al menos 10x mayor que el intervalo de heartbeat?
- [ ] ¿Las cuentas del pizarrón solo desaparecen por cobro o cancelación explícita?
- [ ] ¿El `useEffect` que guarda el `localStorage` del carrito está protegido contra inicializaciones estáticas usando un candado de `cartState.key`? (v4.6 Anti-Wipe)
- [ ] ¿El TTL de producción está calibrado según la estabilidad de la red local? (Recomendado: 20 min con heartbeat de 60s)

---

*Este documento es la fuente de verdad definitiva para la gestión de terminales del ERP R de Rico. Si algún cambio contradice lo aquí especificado, este documento prevalece.*
