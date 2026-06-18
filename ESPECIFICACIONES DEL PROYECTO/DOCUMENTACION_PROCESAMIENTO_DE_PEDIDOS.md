# 📦 DOCUMENTACIÓN MAESTRA: PROCESAMIENTO DE PEDIDOS — R de Rico ERP

> **⚠️ LECTURA OBLIGATORIA.** Cualquier IA o desarrollador que necesite modificar o auditar CUALQUIER aspecto del flujo de Pedidos en el POS de R de Rico **DEBE leer este documento completo primero.**
>
> **Última actualización:** 2026-06-14
> **Versión:** v1.1
> **Archivos gobernados:** `apps/pos/`, `apps/pos/components/ProgramacionPedidoModal.jsx`, `apps/pos/components/CheckoutScreen.jsx`, `apps/pos/utils/ticketGenerator.js`, `apps/pos/hooks/useTicketActions.js`

---

## 1. CONTEXTO DE NEGOCIO

R de Rico es una panadería artesanal/industrial. Además de ventas directas al mostrador, ofrece **pedidos programados**: el cliente solicita productos que serán elaborados y entregados en una fecha/hora futura. Por política de la empresa, **un pedido solo se activa cuando está pagado al 100%**. Esto protege al negocio de producir artículos que nunca se cobrarán.

---

## 2. DOS MODALIDADES DE TRANSACCIÓN EN EL POS

El POS maneja dos tipos de transacción mutuamente excluyentes, seleccionables mediante un toggle en el header:

| Modalidad | Identificador (`orderType`) | Descripción |
|---|---|---|
| **Venta Directa** | `VENTA_DIRECTA` | El cliente compra productos ya disponibles en mostrador. Se cobra y se despacha inmediatamente. Flujo estándar del POS. |
| **Pedido** | `PEDIDO` | El cliente solicita productos para una fecha futura. Requiere programación (datos del cliente, fecha de entrega, tipo de entrega). **Debe pagarse al 100% antes de activarse.** |

### 2.1 Toggle Visual
- **Header del POS** (`POSHeader.jsx`): Muestra dos botones `VENTA DIRECTA` y `PEDIDO`.
- Cuando el usuario selecciona `PEDIDO`, aparece un botón adicional `PROGRAMACIÓN` que abre el modal de captura.
- El estado se almacena en `orderType` y `orderData` en el componente principal `RetailVisionPOS.jsx`.

---

## 3. CICLO DE VIDA DE UN PEDIDO

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     CICLO DE VIDA DE UN PEDIDO                             │
│                                                                            │
│  1. CAPTURA DE PRODUCTOS                                                   │
│     └─ El cajero escanea/selecciona productos normalmente.                 │
│        El toggle está en "PEDIDO". Se habilita botón PROGRAMACIÓN.         │
│                                                                            │
│  2. PROGRAMACIÓN DEL PEDIDO (ProgramacionPedidoModal.jsx)                  │
│     └─ El cajero abre el modal y captura:                                  │
│        • Tipo de entrega: PICKUP o DOMICILIO                               │
│        • Fecha/hora compromiso de entrega                                  │
│        • Nombre del cliente                                                │
│        • Teléfono del cliente                                              │
│        • Tipo de empaque: PROPIO del cliente o VENTA de empaque            │
│        • Dirección (solo si es DOMICILIO)                                  │
│        • Notas adicionales (opcional, texto libre)                         │
│     └─ Al dar clic en "Guardar Pedido Tentativo", los datos se almacenan   │
│        en `orderData` (state de React) y se persisten en la DB vía         │
│        el payload del ticket.                                              │
│                                                                            │
│  3. PEDIDO TENTATIVO (estado visual en POS y Pizarrón)                     │
│     └─ La cuenta se identifica visualmente como "PEDIDO TENTATIVO":        │
│        • Header del POS cambia de color verde a naranja.                   │
│        • En el Pizarrón, la nota adhesiva es AMARILLA con badge naranja    │
│          "📌 PEDIDO TENTATIVO", nombre del cliente y tipo de entrega.      │
│     └─ El pedido AÚN NO ESTÁ ACTIVO. Es una promesa de compra.            │
│     └─ El ticket en la DB tiene order_type='PEDIDO' pero status='OPEN'     │
│        o 'DRAFT'. No se ha producido nada aún.                             │
│                                                                            │
│  4. COBRO AL 100% (CheckoutScreen.jsx)                                     │
│     └─ Al presionar COBRAR, se abre la Suite de Cobro.                     │
│     └─ Si la cuenta es un PEDIDO, aparece un panel lateral derecho con     │
│        los datos del pedido para CONFIRMÁRSELOS AL CLIENTE:                │
│        • Tipo de entrega (Pickup/Domicilio)                                │
│        • Nombre del cliente                                                │
│        • Teléfono                                                          │
│        • Fecha compromiso de entrega                                       │
│        • Contenido del pedido (lista de productos)                         │
│        • Empaque (propio o vendido)                                        │
│        • Dirección (si es domicilio)                                       │
│        • Notas adicionales ← DEBE mostrarse siempre                       │
│     └─ Una vez que el cajero confirma el pago total, se liquida.           │
│                                                                            │
│  5. PEDIDO ACTIVO (post-pago)                                              │
│     └─ El ticket cambia de status='OPEN' a status='PAID'.                  │
│     └─ El order_type='PEDIDO' permanece. Ahora es un PEDIDO ACTIVO.        │
│     └─ Se genera el ticket impreso con los datos del pedido.               │
│     └─ El ticket impreso incluye sección "*** DATOS DEL PEDIDO ***" con    │
│        cliente, tipo de entrega, fecha, empaque, dirección y notas.        │
│     └─ Se debe imprimir DOBLE:                                             │
│        • Copia CLIENTE: el comprador se la lleva como comprobante.         │
│        • Copia COMERCIO: se entrega al gerente de producción.              │
│     └─ El pedido activo debería alimentar el módulo de Gestión de          │
│        Producción (Suite de Pedidos en Producción). PENDIENTE.             │
│                                                                            │
│  6. PRODUCCIÓN Y ENTREGA (futuro)                                          │
│     └─ El gerente de producción recibe la copia COMERCIO del ticket.       │
│     └─ Elabora los productos según los detalles del pedido.               │
│     └─ El cliente recoge (PICKUP) o se le entrega (DOMICILIO).             │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. ESTRUCTURA DE DATOS DEL PEDIDO (`orderData`)

El objeto `orderData` se almacena en el estado de React y se inyecta al payload del ticket al enviarlo al backend:

```javascript
{
    delivery_type: 'PICKUP' | 'DOMICILIO',     // Tipo de entrega
    customer_name: 'LARA CAMPOS',               // Nombre del cliente
    customer_phone: '7294941515',               // Teléfono
    earliest_ready_at: '2026-06-14T18:32:00Z',  // Calculado por el sistema
    committed_at: '2026-06-14T18:32:00Z',       // Fecha compromiso del cajero
    packaging_type: 'PROPIO' | 'VENTA',         // Tipo de empaque
    delivery_address: '...' | null,             // Solo para DOMICILIO
    notes: 'BIEN RICO' | null                   // Notas adicionales libres
}
```

### 4.1 Persistencia en el Backend
- Al enviar el ticket (`handleTicketAction`), el `orderData` se fusiona con el payload: `payload = { ...payload, ...orderData }`.
- El backend almacena estos campos en la tabla `tickets` (columnas `order_type`, `delivery_type`, `customer_name`, `customer_phone`, `committed_at`, `packaging_type`, `delivery_address`, `notes`).

### 4.2 Recuperación del Pizarrón
- Al recuperar una cuenta del Pizarrón (`handleRecoverAccount`), si `account.orderType === 'PEDIDO'`, se restaura el `orderData` completo incluyendo `notes` (`account.orderNotes`).

---

## 5. COMPONENTES INVOLUCRADOS

| Archivo | Responsabilidad | Zona |
|---------|----------------|------|
| `RetailVisionPOS.jsx` | Orquestador principal. Almacena `orderType` y `orderData`. | ⚠️ Restringido |
| `POSHeader.jsx` | Toggle VENTA DIRECTA / PEDIDO. Botón PROGRAMACIÓN. Badge visual. | UI |
| `ProgramacionPedidoModal.jsx` | Modal de captura de datos del pedido. Calcula fecha mínima. | Captura |
| `CheckoutScreen.jsx` | Suite de cobro. Panel lateral de confirmación de pedido. | Cobro |
| `useTicketActions.js` | Inyección de `orderData` al payload. Impresión de ticket. | ⚠️ Restringido |
| `ticketGenerator.js` | Generación del HTML del ticket impreso. Sección OMS. | Impresión |
| `OpenAccountsCorkboard.jsx` | Pizarrón. Muestra badge "PEDIDO TENTATIVO" en notas amarillas. | UI |

---

## 6. IMPRESIÓN DEL TICKET DE PEDIDO

### 6.1 Flujo Actual de Impresión
1. El cajero liquida la cuenta en `CheckoutScreen.jsx`.
2. `handleTicketAction('PAID', paymentData)` se ejecuta en `useTicketActions.js`.
3. Tras recibir el `savedTicket` del servidor, se llama a `handlePrintTicket(savedTicket)`.
4. `handlePrintTicket` detecta si el ticket es un PEDIDO:
   - **PEDIDO**: Genera HTML combinado vía `combineOrderTicketsForPrint(ticketData)` con dos copias (CLIENTE + COMERCIO) separadas por `page-break-after`.
   - **VENTA DIRECTA**: Genera HTML simple vía `generateTicketHTML(ticketData)`.
5. El HTML se inyecta en un iframe oculto y se invoca `window.print()` (un solo diálogo de impresión).

### 6.2 Sección OMS en el Ticket
Si `ticketData.order_type === 'PEDIDO'`, el ticket incluye un recuadro con:
- `*** DATOS DEL PEDIDO ***` (título invertido blanco sobre negro)
- Cliente, Tipo de entrega, Fecha compromiso, Empaque
- Dirección (solo domicilio)
- **Notas adicionales** ← campo `notes` del ticket
- Leyenda: "PAGADO - PENDIENTE DE RECOLECCIÓN/ENTREGA"

### 6.3 Impresión Doble para Pedidos (REQUERIDA)
Cuando un pedido se paga, se deben generar **dos copias** del ticket:

| Copia | Leyenda | Propósito |
|-------|---------|-----------|
| **CLIENTE** | `--- COPIA: CLIENTE ---` | El comprador se la lleva como comprobante de su pedido pagado. |
| **COMERCIO** | `--- COPIA: COMERCIO ---` | Se entrega al gerente de producción para que elabore el pedido. |

Ambas copias son idénticas en contenido, solo varía la leyenda identificadora.

---

## 7. ESTADO DE IMPLEMENTACIÓN

### 7.1 ✅ Notas Adicionales en Pantalla de Cobro
**Estado:** IMPLEMENTADO (v1.1). Las notas se muestran en el panel de confirmación del `CheckoutScreen.jsx` con estilo prominente (fondo amber, emoji 📝) para que el cajero las identifique fácilmente y las confirme con el cliente. El mapeo desde el Pizarrón (`orderNotes` → `notes`) está verificado y funciona correctamente.

### 7.2 ✅ Impresión Doble de Ticket para Pedidos
**Estado:** IMPLEMENTADO (v1.1). Al pagar un pedido, se generan automáticamente dos copias en un solo diálogo de impresión:
- Copia `--- COPIA: CLIENTE ---`: para el comprador.
- Copia `--- COPIA: COMERCIO ---`: para el gerente de producción.
La función `combineOrderTicketsForPrint()` en `ticketGenerator.js` combina ambas copias con `page-break-after: always` para que la impresora térmica corte entre ellas.

### 7.3 🔧 Conexión con Módulo de Producción
**Estado:** PENDIENTE. Los pedidos activos (PAID + PEDIDO) deberían aparecer en la Suite de Pedidos en Producción del módulo de Gestión de la Producción. Se abordará en una iteración posterior. Mientras tanto, la copia COMERCIO del ticket impreso sirve como comprobante físico para el gerente de producción.

### 7.4 ✅ Notas en Ticket Impreso
**Estado:** IMPLEMENTADO (v1.1). La sección OMS del ticket ahora incluye las notas adicionales del pedido (campo `NOTAS:`) entre la dirección y la leyenda "PAGADO - PENDIENTE DE...". Compatible con ambos campos del backend (`notes` y `order_notes`).

---

## 8. REGLAS DE NEGOCIO INAMOVIBLES

1. **Un pedido SOLO se activa cuando está pagado al 100%.** No existe el concepto de "anticipo" para pedidos. El flujo es: tentativo → pago completo → activo.
2. **Los datos del pedido deben confirmarse al cliente ANTES de cobrar.** El panel lateral en la Suite de Cobro existe para este propósito. Las notas adicionales deben ser visibles.
3. **El ticket de pedido pagado debe imprimirse en doble copia** (CLIENTE y COMERCIO) para que el gerente de producción tenga un comprobante físico.
4. **Las notas adicionales son texto libre** que puede contener instrucciones especiales de producción ("sin azúcar", "entregar antes de las 10am", "decoración de cars").
5. **Ningún cambio al flujo de pedidos debe afectar el flujo de venta directa.** Ambos comparten la misma infraestructura de persistencia atómica (v6.0).

---

> **Este documento es la FUENTE ÚNICA DE VERDAD del procesamiento de pedidos en el POS de R de Rico.**
> Cualquier IA que trabaje con este flujo debe leerlo antes de hacer cambios.
