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

- **Cálculo:** El sistema lee el campo `order_lead_time_hours` (Tiempo para pedidos) incrustado en el modelo `ProductTechnicalSheet`.
- **Restricción:** El frontend (`GrandezaDriverUI.jsx`) filtra los productos seleccionados en el pedido, busca el mayor `lead_time_hours` y auto-sugiere la `Fecha y Hora Mínima de Entrega`. Impide hacer `submit` si la fecha elegida es anterior a este cálculo.

---

## 5. Registro de Errores Enfrentados y Sus Soluciones (Troubleshooting)

A lo largo del desarrollo hemos topado con peculiaridades del ecosistema (Timezones, Lazy Loading, Redes). Se listan a continuación para que ninguna IA futura tropiece con la misma piedra.

### Error A: "Desaparición" de la Ruta (Efecto Zona Horaria / Timezone)
**Síntoma:** Al probar la aplicación del repartidor en la tablet después de cierta hora de la tarde (ej. 6:00 PM), la ruta del día en curso desaparecía y el sistema mostraba "Sin ruta activa". Sin embargo, en la base de datos la jornada seguía abierta.
**Diagnóstico:** México (America/Mexico_City) está desfasado del horario UTC. La función del frontend `todayStr()` utilizaba `new Date()`. Al caer la tarde en México, en UTC ya es el día siguiente (medianoche). El navegador de la tablet pasaba a solicitar a la API la ruta "de mañana", devolviendo `404 Not Found`.
**Solución:** Se forzó explícitamente el timezone de México en la construcción de la fecha, extrayendo las partes exactas usando `formatToParts` para evitar diferencias de renderizado (slashes vs dashes) entre distintos navegadores (Chrome vs Safari).

\`\`\`javascript
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
    return \`\${year}-\${month}-\${day}\`;
};
\`\`\`

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

\`\`\`python
# SOLUCIÓN APLICADA EN apps/api/modules/grandeza/service.py
stmt = (
    select(GrandezaProductConfig)
    # Eager loading vital para evitar MissingGreenlet en FastAPI Async
    .options(selectinload(GrandezaProductConfig.product).selectinload(Product.technical_sheet))
    .where(GrandezaProductConfig.is_enabled == True)
    .order_by(GrandezaProductConfig.id)
)
\`\`\`

---

## 6. Directivas Generales para Modificar este Módulo
1. **Jamás modificar el POS para arreglar Grandeza:** Si Grandeza requiere una adaptación, se debe hacer mediante nuevas columnas específicas en tablas `grandeza_` o interfaces únicas en su módulo de React. 
2. **Prevenir errores de red falsos:** Siempre utilizar herramientas como `Invoke-RestMethod` o `curl` directamente en el entorno de backend para desenmascarar errores 500, en lugar de confiar ciegamente en el `TypeError: Failed to fetch` del frontend.
3. **Zona horaria inquebrantable:** Toda operación relacionada a fechas y días de la semana (`hoy`) debe calcularse forzando explícitamente `America/Mexico_City`. No depender del reloj local no-filtrado del dispositivo móvil.
