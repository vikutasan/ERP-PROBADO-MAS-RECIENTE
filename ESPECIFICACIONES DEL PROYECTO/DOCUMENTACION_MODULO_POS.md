# 🛡️ DOCUMENTACIÓN MAESTRA: MÓDULO PUNTO DE VENTA IA — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA.** Cualquier IA o desarrollador que necesite modificar o auditar CUALQUIER aspecto del Punto de Venta (POS) de R de Rico **DEBE leer este documento completo primero.** 
>
> **Última actualización:** 2026-06-09
> **Versión de arquitectura POS:** v6.0 (Modelo SaaS — Persistencia Atómica)
> **Archivos gobernados:** `apps/pos/`, `apps/api/modules/pos/`, `apps/api/modules/cash/`

---

## ÍNDICE

1. [Arquitectura Actual (v6.0 - Modelo SaaS)](#1-arquitectura-actual-v60---modelo-saas)
2. [Evolución Histórica: Cómo y Por Qué Llegamos Aquí](#2-evolución-histórica-cómo-y-por-qué-llegamos-aquí)
3. [El Cementerio de Bugs (Lecciones Aprendidas)](#3-el-cementerio-de-bugs-lecciones-aprendidas)
4. [Las Reglas de Oro Supervivientes](#4-las-reglas-de-oro-supervivientes)
5. [Lógica de Terminales y Ocupación](#5-lógica-de-terminales-y-ocupación)

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

| Error Histórico (Pre-v6) | Consecuencia | Cómo la v6.0 lo previene |
|-------------------------|--------------|--------------------------|
| **Ticket #906 ($124 → $2):** El auto-save leyó variables viejas de un `closure` y sobreescribió un carrito de 8 ítems con 1 ítem. | Pérdida económica severa. | Al no existir auto-save masivo, no hay timers asíncronos que puedan tener closures viejos. Todo es síncrono al clic. |
| **Ticket #125 ($205):** El botón de Pizarrón limpiaba la pantalla antes de que el servidor confirmara el guardado. La red falló. | Cuenta desaparecida. | `clearCart()` solo ocurre si el servidor responde con HTTP 200 (Regla de Oro). |
| **Hora Pico de Falsos Positivos:** El auto-save lanzaba modales bloqueantes de conflicto porque el Wi-Fi tardaba más de 15s en responder. | Cajeros paralizados. | El envío atómico es rápido y si falla, hace 3 reintentos silenciosos con "backoff" (ver `handleAddToCart`). |
| **Terminal Fantasma (Usuario OMEGA):** Sesiones de caja sin TTL bloqueaban terminales indefinidamente. | Pantalla de inicio bloqueada 2 días. | `/terminals/status` ahora depura usuarios duplicados y el heartbeat limpia candados huérfanos. |

---

## 4. LAS REGLAS DE ORO SUPERVIVIENTES

A pesar de la simplificación, ciertas reglas de ingeniería siguen siendo obligatorias:

### ⚡ REGLA 1: Referencias Mutables (`useRef`) vs Closures
Aunque ya no hay timer, React sigue siendo asíncrono. **Nunca** leas el carrito desde una variable de estado dentro de la lógica de finalización.
- ✅ OBLIGATORIO: Usar `cartRef.current`, `accountNumRef.current`, `ticketVersionRef.current`.
- ⛔ PROHIBIDO: Usar `cart`, `currentAccountNum` dentro de `handleTicketAction`.

### ⚡ REGLA 2: Mutex para Acciones Finales
El cobro y el envío al pizarrón (`handleTicketAction`) todavía usan `actionMutexRef`.
Esto evita que un cajero desespere, dé doble clic en "Cobrar", y se generen dos registros de pago para la misma cuenta.

### ⚡ REGLA 3: Zero-Loss en Acciones Finales
Cuando se cobra o se manda al pizarrón explícitamente, la UI **nunca** debe hacer `clearCart()` hasta que la petición HTTP finalice con éxito. 

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
2. Cambia a estado `CANCELLED` los tickets `DRAFT` con productos que tengan más de 24 horas de abandono (evitando que queden como cuentas por cobrar fantasma, pero manteniendo el registro para auditoría).

---

## 5. LÓGICA DE TERMINALES Y OCUPACIÓN

### Ocupación Amigable (v4.4+)
- **Candados Persistentes:** Siguen viviendo en PostgreSQL (`terminal_locks`), NUNCA en la RAM de Python (para sobrevivir reinicios de Docker).
- **Adiós a la Expulsión Automática:** En el pasado, si la red fallaba, el sistema expulsaba al cajero al perder el candado. **Ya no.** Ahora (`useTerminalLocking.js`) solo muestra una advertencia visual si se pierde el candado.
- **Fuerza Bruta (Force Unlock):** Para robar una terminal bloqueada, el usuario requiere el permiso `pos_force_unlock`. 
  - ⚠️ **Excepción CAJAS:** Si la terminal tiene una **Sesión de Caja activa**, se exige un permiso superior (`pos_force_cash_unlock`). Al forzar el desbloqueo, ocurre una **Traspuesta de Titularidad**: la sesión de caja (y la responsabilidad del dinero en ella) se transfiere automáticamente al usuario que forzó el desbloqueo.
- **Heartbeat:** Cada 20 segundos la terminal avisa que sigue viva. Si una terminal muere (ej. se apaga la tablet), a los 20 minutos el candado caduca y se libera solo.

### Sesiones de Caja vs Candados de Terminal
- `terminal_locks`: Bloquea físicamente la pantalla (T1, T2, CAJA).
- `cash_sessions`: Permite que un empleado registre ingresos/egresos monetarios en una terminal habilitada para cobrar.

---

> **Esta es la FUENTE ÚNICA DE VERDAD de la v6.0.**
> El POS de R de Rico es un monumento a la evolución: construimos sistemas complejos para sobrevivir, aprendimos que la complejidad causaba errores, y los sustituimos por simplicidad atómica robusta. 
> 
> *Tu trabajo como IA no es reintroducir la complejidad antigua, sino proteger y expandir esta simplicidad.*
