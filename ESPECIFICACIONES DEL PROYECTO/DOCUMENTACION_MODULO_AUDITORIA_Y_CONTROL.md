# 🛡️ DOCUMENTACIÓN MAESTRA: MÓDULO DE AUDITORÍA Y CONTROL — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA.** Cualquier IA o desarrollador que necesite interactuar, depurar o extender el Módulo de Auditoría y Control **DEBE** leer este documento. Aquí se detalla la lógica de trazabilidad de tickets y cortes de caja, así como los *gotchas* (problemas ocultos) resueltos durante el desarrollo.
>
> **Última actualización:** 2026-06-16
> **Archivos gobernados:** `apps/AuditoriaControlUI.jsx`, `apps/api/modules/pos/service.py`, `apps/api/modules/cash/service.py`

---

## 1. PROPÓSITO Y FUNCIONAMIENTO DEL MÓDULO

El **Módulo de Auditoría y Control** es el centro de monitoreo operativo donde la gerencia puede rastrear la trazabilidad de cada centavo ingresado en el sistema. Su funcionamiento se divide en dos secciones principales:

1. **Pestaña de Tickets (Ventas):** Muestra el historial completo de ventas, indicando no solo el folio y el monto, sino la trazabilidad humana y física: **quién capturó** el pedido, **quién lo cobró**, y **en qué terminal** (tablet física) se originó.
2. **Pestaña de Cortes de Caja:** Lista los cierres de sesión de las terminales recaudadoras (`CashSessions`). Muestra los fondos iniciales, ventas por método de pago (Efectivo, Crédito, Débito), movimientos manuales (entradas/salidas) y el monto físico reportado por el empleado.

### Comportamiento de la Interfaz (Filtros y Limpieza)
- **Por defecto / Al hacer clic en "Limpiar":** La UI envía peticiones a los endpoints `/pos/tickets` o `/cash/sessions/history` **sin parámetros**. El backend responde enviando los **últimos 100 tickets** o **últimos 50 cortes**, ordenados desde el más reciente al más antiguo.
- **Búsqueda por Fecha:** Si el gerente selecciona una fecha, la API devuelve todos los registros correspondientes estrictamente a ese "día operativo" (ajustado a la zona horaria UTC-6).

---

## 2. EL CEMENTERIO DE BUGS (LECCIONES APRENDIDAS Y CORREGIDAS)

A continuación se documentan los 3 incidentes críticos resueltos en el desarrollo del módulo. **PROHIBIDO revertir estas soluciones o cometer los mismos errores en el futuro.**

### 🐛 BUG 1: El Secuestro de la Terminal de Origen (Ticket Extraviado)

**El Síntoma:**
La gerencia reportó que un ticket de $2,550 capturado en la **Terminal 5** "desapareció" de los registros de dicha terminal y no podía ser encontrado. Al buscar a fondo, el ticket sí existía pero estaba registrado bajo la terminal **"CAJA"**.

**Causa Raíz:**
1. Un vendedor en la Terminal 5 tomaba el pedido y lo mandaba al Pizarrón (Estado `OPEN`). En este paso, el ticket nacía correctamente con `terminal_id='T5'`.
2. El cajero en la CAJA abría el Pizarrón y cobraba el ticket (Estado `PAID`).
3. En el backend (`_update_ticket_fields` en `pos/service.py`), existía una regla que sobreescribía el campo `terminal_id` del ticket original con la sesión de quien estuviera haciendo la actualización. Esto **robaba** la autoría a la T5 y se la daba a la CAJA.

**Solución Implementada:**
- Se **eliminó permanentemente** la línea de sobreescritura de `terminal_id` al actualizar tickets.
- **Regla de Oro:** El campo `terminal_id` es **inmutable** una vez que el ticket nace (`_initialize_new_ticket`). Representa el origen físico de la venta. Para saber quién cobró el dinero, el módulo de auditoría utiliza los campos `cashed_by_id` y `cash_session_id`. Nunca destruir la información de origen.

---

### 🐛 BUG 2: La Zona Horaria y los Tickets/Cortes Nocturnos Desaparecidos

**El Síntoma:**
Al utilizar el filtro de búsqueda por "Fecha" en la Auditoría, el gerente notó que el sistema mostraba los tickets y cortes del día seleccionado, pero **solo hasta las 6:00 PM**. Cualquier venta u operación realizada a las 7:00 PM, 10:00 PM o media noche simplemente **desaparecía** de la consulta de ese día.

**Causa Raíz:**
1. PostgreSQL guarda todos los timestamps (`created_at`, `opened_at`) en **UTC** (Tiempo Universal Coordinado), el cual está **6 horas adelantado** respecto a México (UTC-6).
2. El código anterior hacía un simple `cast(models.Ticket.created_at, Date) == target_date`. Para el servidor UTC, las 6:01 PM de México ya son las 00:01 del día siguiente. El cast cortaba el día prematuramente.

**Solución Implementada:**
- En `apps/api/modules/pos/service.py` y `apps/api/modules/cash/service.py`, el filtrado por fecha (`search_date`) ya no utiliza `cast`.
- Ahora, el backend recibe la fecha (ej. `2026-06-15`), le suma el desfase horario local (`+ 6 horas`) para obtener `start_utc` y `end_utc`, y ejecuta una consulta de **rango**: `WHERE created_at >= start_utc AND created_at < end_utc`. Esto alinea perfectamente los "días" de la base de datos con los "días" reales de operación del negocio.

---

### 🐛 BUG 3: Cortes de Caja Invisibles (El Error 500 Silencioso)

**El Síntoma:**
Al entrar a la pestaña de "Cortes de Caja", la interfaz aparecía **completamente vacía**, sin mostrar el historial de los últimos realizados ni al usar el botón "Limpiar". La creencia inicial del usuario era que los cortes eran muy viejos para mostrarse.

**Causa Raíz:**
1. No era que no hubiera cortes (había más de 100 guardados). Era un **Internal Server Error 500** del API (`/cash/sessions/history`).
2. La API intentaba inyectar un `CashSummary` calculando los esperados de efectivo. Para ello, sumaba el fondo inicial (`opening_float` - tipo `Decimal` de SQLAlchemy) con las ventas cobradas en efectivo (tipo `float` calculado en un diccionario en Python).
3. **El fallo:** En Python, intentar sumar `decimal.Decimal` + `float` directamente lanza un `TypeError`. Este error rompía la respuesta del API y mandaba un arreglo vacío al frontend de React.

**Solución Implementada:**
- En `apps/api/modules/cash/service.py` -> `calcular_resumen`, se forzó el cast seguro a `float()` en todos los campos provenientes de la base de datos (`opening_float`, `m.amount`) antes de mezclarlos con los diccionarios de ventas y construir la respuesta Pydantic final. Esto estabilizó la API y los cortes volvieron a aparecer de inmediato.
