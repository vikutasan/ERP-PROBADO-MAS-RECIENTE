# Documentación Módulo de Reparto "Grandeza"

Este documento está diseñado para proporcionar contexto técnico, funcional y de arquitectura a las IAs y desarrolladores que interactúen con el módulo "Reparto Pan Grandeza".

## 1. Visión General
El módulo "Grandeza" es un sistema especializado dentro del ERP R de Rico, diseñado exclusivamente para administrar rutas de reparto, inventarios móviles, visitas a clientes (programadas y no programadas), y el registro de ventas o pedidos (anticipos/saldos) directamente en campo a través de una tablet o dispositivo móvil utilizado por el repartidor.

**Pilar Arquitectónico Crítico:**
El módulo "Grandeza" **VIVE TOTALMENTE AISLADO** del Punto de Venta (POS) de las sucursales. 
- **Base de datos:** Utiliza tablas con el prefijo `grandeza_` (ej. `grandeza_orders`, `grandeza_clients`, `grandeza_journeys`). No interfiere con las tablas `tickets`, `ticket_items` ni interrumpe la operación de los cajeros en mostrador.
- **Frontend:** Tiene su propia UI independiente (`GrandezaDriverUI.jsx`) montada en Vite, separada de `POS.jsx`.
- **Backend:** Sus rutas están en `apps/api/modules/grandeza/router.py`, lo que previene que fallos o lentitud en el reparto afecten al POS físico.

---

## 2. Flujo de Trabajo del Repartidor (Jornada)

1. **Apertura de Jornada (`GrandezaJourney`)**: Se abre un día de reparto. Queda ligado a un chofer, fecha y una cantidad de dinero como "Fondo de Caja".
2. **Carga de Inventario Inicial (`GrandezaInventory`)**: Antes de salir, se registra el inventario (productos) subido a la camioneta.
3. **Ruta del Día (`GrandezaRouteSlot`)**: Se define una secuencia de visitas (`visits`) basadas en los clientes (`GrandezaClient`) asignados para ese día específico de la semana.
4. **Ejecución en Campo**:
    - El repartidor atiende clientes, usando geolocalización (GPS) al llegar a la tienda.
    - Levanta pedidos o registra ventas directas (`GrandezaOrder`).
    - Al final, reporta el retorno, dinero en mano y mercancía sobrante.

---

## 3. Estructura de Base de Datos y Modelos

Todos los modelos residen en `apps/api/modules/grandeza/models.py`. Destacan:
- `GrandezaProductConfig`: Define qué productos del catálogo general están habilitados para reparto y a qué precio B2B.
- `GrandezaClient`: Ficha del cliente, ubicación GPS, historial y foto de fachada.
- `GrandezaRouteSlot`: Plantilla semanal de rutas (lunes a domingo).
- `GrandezaOrder` / `GrandezaOrderItem`: 
    - Registra la venta.
    - Soporta los campos `delivery_time` (fecha/hora de entrega).
    - Soporta `advance_payment` (anticipos) y calcula el estado del pago (`PAGADO`, `ANTICIPO`, `PENDIENTE`).

---

## 4. Lógica de Tiempos de Producción y Entregas
Para los pedidos, el sistema evita que el repartidor prometa entregas imposibles al cliente consultando la **Ficha Técnica** del producto en el momento.

- **Cálculo:** El sistema lee el campo `order_lead_time_hours` (Tiempo para pedidos) desde la relación `ProductTechnicalSheet` del catálogo. El backend lo extrae en `service.py` usando `cfg.product.technical_sheet.order_lead_time_hours`.
- **Auto-sugerencia:** Cuando el campo de fecha está vacío y se agregan productos con lead time, el frontend auto-rellena la fecha/hora mínima posible. **Si el usuario ya capturó una fecha/hora, el sistema la respeta y NO la sobreescribe.**
- **Bloqueo al enviar:** Si la fecha/hora capturada es anterior a la mínima viable, el botón de "Levantar Pedido" se bloquea con un toast de error que dice exactamente cuántas horas de producción se necesitan. El pedido NO se envía.
- **Indicador visual:** Debajo de los campos fecha/hora aparece una etiqueta:
    - **Morada (⏱️):** Indica la fecha más próxima posible, todo está bien.
    - **Roja (⚠️):** La fecha capturada no alcanza, se necesita más tiempo.

---

## 5. Integración con el Módulo de Producción

Los pedidos levantados desde la tablet del repartidor aparecen automáticamente en **Pedidos en Producción** (`PedidosProduccionUI.jsx`), sin intervención del POS.

### Status de Pedido vs. Status de Pago
Existen **dos campos de status independientes** en `GrandezaOrder`:
- `status`: Controla el **flujo de producción** (TENTATIVO → TURNO_ASIGNADO → EN_PREPARACION → ... → ENTREGADO). Este es el que lee Producción para saber qué hacer.
- `payment_status`: Controla el **estado financiero** (PENDIENTE, ANTICIPO, PAGADO). Este es el que lee el repartidor para saber cuánto cobrar.

### Reglas de Negocio
1. **Los pedidos Grandeza entran a Producción como `TENTATIVO`**, no como `PAGADO`. Esto permite que se levanten pedidos sin pago completo (con anticipo o pendientes).
2. **La información financiera real** se muestra en Producción:
    - En la tarjeta del pedido: una etiqueta de color indica PAGADO (verde), ANTICIPO con montos (ámbar), o PENDIENTE (rojo).
    - En el modal de detalles: un bloque muestra Total, Anticipo y Resta desglosados.
3. **La hora de compromiso** se construye combinando `delivery_date` + `delivery_time` (ej: `2026-06-18T10:00`) para que Producción vea la hora real que capturó el repartidor.

### Mapeo de Datos (PedidosProduccionUI.jsx → loadOrders)
Al cargar pedidos, Producción hace fetch a `/api/v1/grandeza/orders` y mapea los datos así:
```javascript
committed_at: o.delivery_time ? `${o.delivery_date}T${o.delivery_time}` : o.delivery_date,
payment_status: o.payment_status || 'PENDIENTE',
advance_payment: o.advance_payment || 0,
balance_due: o.balance_due || 0,
```

---

## 6. Registro de Errores Enfrentados y Sus Soluciones (Troubleshooting)

A lo largo del desarrollo hemos topado con peculiaridades del ecosistema (Timezones, Lazy Loading, Redes, Mapeo de datos). Se listan a continuación para que ninguna IA futura tropiece con la misma piedra.

### Error A: "Desaparición" de la Ruta (Efecto Zona Horaria / Timezone)
**Síntoma:** Al probar la aplicación del repartidor en la tablet después de cierta hora de la tarde (ej. 6:00 PM), la ruta del día en curso desaparecía y el sistema mostraba "Sin ruta activa". Sin embargo, en la base de datos la jornada seguía abierta.
**Diagnóstico:** México (America/Mexico_City) está desfasado del horario UTC. La función del frontend `todayStr()` utilizaba `new Date()`. Al caer la tarde en México, en UTC ya es el día siguiente (medianoche). El navegador de la tablet pasaba a solicitar a la API la ruta "de mañana", devolviendo `404 Not Found`.
**Solución:** Se forzó explícitamente el timezone de México en la construcción de la fecha, extrayendo las partes exactas usando `formatToParts` para evitar diferencias de renderizado (slashes vs dashes) entre distintos navegadores (Chrome vs Safari).

```javascript
// SOLUCIÓN APLICADA EN GrandezaDriverUI.jsx
const todayStr = () => {
    const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone: 'America/Mexico_City',
        year: 'numeric', month: '2-digit', day: '2-digit'
    });
    const parts = formatter.formatToParts(new Date());
    const year = parts.find(p => p.type === 'year').value;
    const month = parts.find(p => p.type === 'month').value;
    const day = parts.find(p => p.type === 'day').value;
    return `${year}-${month}-${day}`;
};
```

### Error B: "Failed to fetch" engañoso (Internal Server Error 500 encubierto por CORS)
**Síntoma:** Tras agregar la lógica de "lead time", la tablet del repartidor falló drásticamente en la carga inicial y arrojó un error en rojo que decía `FETCH ERR en products: Failed to fetch`.
**Diagnóstico:** 
1. Originalmente, se creía que era un problema de red, IPs caídas, puertos bloqueados o solicitudes HTTP desde HTTPS (Mixed Content).
2. Se comprobó que el servidor FastApi (puerto 5001) respondía. Al atacar el endpoint `/api/v1/grandeza/products` directo, se descubrió un `HTTP 500 Internal Server Error`.
3. Cuando FastAPI falla con un 500 no controlado, **no adjunta cabeceras CORS**. Por tanto, el navegador de la tablet bloquea la respuesta y lo disfraza como un "Failed to fetch" de red.
**Causa real (Typo + Lazy Loading):** 
- Se intentó leer `cfg.product.technical_data.get()` cuando el ORM en realidad tiene la relación definida como `technical_sheet`, no `technical_data`.
- Además, `technical_sheet` es una relación ORM asíncrona de SQLAlchemy. Al intentar accederla de forma síncrona dentro del bucle de serialización sin haber hecho un *eager load* (`selectinload`), se disparaba un `MissingGreenlet` o `AttributeError`.
**Solución:** Se modificó la consulta en `service.py` para obligar a la base de datos a precargar (`selectinload`) la ficha técnica asíncronamente en una sola llamada, y se corrigió el nombre del atributo.

```python
# SOLUCIÓN APLICADA EN apps/api/modules/grandeza/service.py
stmt = (
    select(GrandezaProductConfig)
    # Eager loading vital para evitar MissingGreenlet en FastAPI Async
    .options(selectinload(GrandezaProductConfig.product).selectinload(Product.technical_sheet))
    .where(GrandezaProductConfig.is_enabled == True)
    .order_by(GrandezaProductConfig.id)
)
```

### Error C: Hora de entrega incorrecta en Producción (6 PM en vez de 10 AM)
**Síntoma:** El repartidor capturaba un pedido con hora de entrega 10:00 AM, pero en el módulo de Producción aparecía como las 6:00 PM.
**Diagnóstico:** En `PedidosProduccionUI.jsx`, al mapear los pedidos Grandeza se asignaba `committed_at: o.delivery_date` pasando solo la fecha (ej: `"2026-06-18"`) e ignorando completamente `o.delivery_time`. JavaScript interpreta una fecha sin hora como medianoche UTC, que al convertir a zona horaria de México resulta en las 6:00 PM del día anterior.
**Solución:** Se combinan ambos campos: `committed_at: o.delivery_time ? \`${o.delivery_date}T${o.delivery_time}\` : o.delivery_date`

### Error D: Status "PAGADO" falso en Producción (siendo ANTICIPO o PENDIENTE)
**Síntoma:** El repartidor levantaba un pedido con anticipo parcial, pero en Producción aparecía marcado como "Pagado".
**Diagnóstico:** En `service.py`, la función `create_grandeza_order` forzaba `status="PAGADO"` para que Producción lo aceptara en su flujo. Pero el módulo de Producción ya acepta pedidos con `status="TENTATIVO"` (sección "EN ESPERA DE ASIGNACIÓN DE TURNO", línea 35 de PedidosProduccionUI.jsx).
**Solución:** Se cambió el status inicial de `"PAGADO"` a `"TENTATIVO"`, y se agregaron campos `payment_status`, `advance_payment` y `balance_due` al mapeo de datos de Producción para mostrar la información financiera real.

### Error E: Auto-modificación silenciosa de la hora capturada
**Síntoma:** El repartidor capturaba una hora de entrega (ej. 10:00 AM), pero el sistema automáticamente la cambiaba a las 6:00 PM sin avisar, porque calculaba que el lead time de producción no alcanzaba.
**Diagnóstico:** El `useEffect` de auto-rellenado verificaba si la fecha/hora capturada era "demasiado temprana" y la sobreescribía con la mínima calculada, sin informar al usuario.
**Solución:** El auto-rellenado ahora SOLO actúa si el campo de fecha está completamente vacío. Si el usuario ya capturó algo, el sistema lo respeta y simplemente bloquea el envío al intentar guardar, mostrando un toast de error claro.

---

## 7. Directivas Generales para Modificar este Módulo
1. **Jamás modificar el POS para arreglar Grandeza:** Si Grandeza requiere una adaptación, se debe hacer mediante nuevas columnas específicas en tablas `grandeza_` o interfaces únicas en su módulo de React. 
2. **Prevenir errores de red falsos:** Siempre utilizar herramientas como `Invoke-RestMethod` o `curl` directamente en el entorno de backend para desenmascarar errores 500, en lugar de confiar ciegamente en el `TypeError: Failed to fetch` del frontend.
3. **Zona horaria inquebrantable:** Toda operación relacionada a fechas y días de la semana (`hoy`) debe calcularse forzando explícitamente `America/Mexico_City`. No depender del reloj local no-filtrado del dispositivo móvil.
4. **Respetar la captura del usuario:** Nunca sobreescribir silenciosamente datos que el usuario ya capturó (fechas, horas, montos). Si hay un problema de validación, bloquearlo al intentar guardar con un mensaje claro, no modificar el dato a sus espaldas.
5. **Status de producción ≠ Status de pago:** El campo `status` es el flujo de producción (TENTATIVO, EN_PREPARACION, etc.). El campo `payment_status` es el estado financiero (PAGADO, ANTICIPO, PENDIENTE). Nunca mezclarlos.
6. **Eager loading obligatorio en SQLAlchemy Async:** Cualquier relación ORM que se acceda dentro de un bucle de serialización DEBE precargarse con `selectinload()` en la consulta inicial. De lo contrario, FastAPI dispara un error 500 silencioso que el frontend reporta como "Failed to fetch".

