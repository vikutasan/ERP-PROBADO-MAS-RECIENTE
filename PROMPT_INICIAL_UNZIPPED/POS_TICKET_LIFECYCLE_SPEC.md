# 📜 Protocolo Maestro: Ciclo de Vida del Ticket POS (R de Rico ERP)

Este documento es la **Única Fuente de Verdad** sobre cómo se deben gestionar los tickets. Cualquier modificación al código DEBE respetar estos patrones para evitar pérdida de datos, folios duplicados o bloqueos de concurrencia.

---

## 1. Arquitectura de Identidad (Folios)

### 1.1 Estructura del Folio
- Los folios tienen el formato `V####` (ej. `V11274`).
- **REGLA CRÍTICA:** NUNCA se debe usar `MAX(id)` o `count()` en Python para calcular el siguiente folio.
- **Mecanismo:** Se utiliza una secuencia nativa de PostgreSQL llamada `ticket_folio_seq`. 
- **Atomicidad:** La generación del folio ocurre en la base de datos mediante `nextval('ticket_folio_seq')`. Esto garantiza que incluso 100 terminales pidiendo un folio al mismo milisegundo reciban valores únicos.

---

## 2. Fase de Reserva (Lazy Reservation)

El sistema usa una estrategia de **Reserva Perezosa** para evitar folios "huecos" por accidentes o recargas de página.

### 2.1 El Flujo de Reserva
1. El frontend NO pide un folio al abrir la terminal.
2. Al agregar el **primer producto**, el frontend llama a `reserve_ticket`.
3. El backend intenta **reciclar**:
    - Busca tickets en estado `OPEN` que pertenezcan a la sesión activa y que tengan `total == 0` y `items == 0`.
    - **Protección de Concurrencia:** Usa `SELECT ... FOR UPDATE SKIP LOCKED`. Esto evita que dos pestañas del mismo navegador o dos terminales "agarren" el mismo ticket vacío.
4. Si no hay nada que reciclar, genera uno nuevo usando la secuencia `ticket_folio_seq`.

---

## 3. Fase de Persistencia (Heartbeat / Sync)

### 3.1 Smart Upsert (Sincronización Inteligente)
Cada 30 segundos (o al guardar manual), el frontend envía la "foto" actual del carrito.
- **PROHIBIDO:** Borrar todos los items y reinsertarlos (`delete & insert`). Esto rompe los IDs internos y la trazabilidad.
- **DEBE:** Comparar el `product_id` entrante contra los existentes en la DB:
    - Si existe: Actualiza cantidad y precio (mantiene el ID de la fila).
    - Si es nuevo: Inserta.
    - Si ya no viene en el JSON: Elimina de la DB.

### 3.2 Trazabilidad de Usuarios
- **`captured_by_id`:** Se asigna permanentemente en la primera persistencia. No debe cambiar aunque otro usuario cobre el ticket.
- **`cashed_by_id`:** Se asigna únicamente al momento de cambiar el estado a `PAID`.

---

## 4. Fase de Cobro y Cierre (Check-out)

### 4.1 Transición Atómica a PAID
El cambio a `PAID` es el punto de no retorno.
1. Se validan los `payment_details` (JSON que almacena método, monto, recibido y cambio).
2. Se marca el ticket como `PAID`.
3. Si el ticket es de tipo `PEDIDO`, se dispara el puente al Módulo de Producción.
4. **Idempotencia:** El puente a producción debe verificar si el ticket ya fue procesado para evitar órdenes duplicadas en cocina.

### 4.2 Lógica de Impresión (Non-Blocking)
- El frontend debe usar un `useRef` (`savedTicketRef`) para almacenar la respuesta oficial del servidor tras el cobro.
- **NUNCA** usar `alert()` justo después de mandar a imprimir, ya que bloquea el hilo de ejecución y cancela el spooler de la impresora. Usar Notificaciones (Toasts) visuales.

---

## 5. Fase de Auditoría y Control

### 5.1 Serialización Completa
El endpoint `get_tickets` NO debe confiar en la serialización automática de Pydantic/SQLAlchemy debido al riesgo de `LazyLoad` fuera del contexto de la sesión.
- **REGLA:** El backend debe construir un diccionario manual que incluya:
    - Relaciones cargadas vía `selectinload` (Items, Product, Category, CapturedBy, CashedBy).
    - Campos OMS (Order Management System) completos.
    - Desglose de pagos (`payment_details`).

---

## 6. Diccionario de Estados

| Estado | Significado | Ubicación |
|---|---|---|
| `OPEN` | Ticket en proceso de captura. | Pizarrón / Terminal activa. |
| `PAID` | Venta finalizada y dinero en caja. | Histórico / Auditoría. |
| `CANCELLED` | Ticket anulado (requiere motivo). | Auditoría (No borra de DB). |

---

> [!IMPORTANT]
> **Nota para IAs:** Antes de modificar `POSService.py` o `RetailVisionPOS.jsx`, verifica que tu cambio no invalide el uso de la secuencia `ticket_folio_seq` o el bloqueo `SKIP LOCKED`. Si intentas implementar un contador manual en Python, estarás introduciendo un bug de colisión.
