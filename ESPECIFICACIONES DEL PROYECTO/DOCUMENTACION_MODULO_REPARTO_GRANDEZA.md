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

### Error F: "Failed to fetch" al abrir nueva jornada (Columna de base de datos faltante)
**Síntoma:** Al intentar "ABRIR JORNADA DE HOY" desde la interfaz, el frontend lanzaba inmediatamente un `Error de red: Failed to fetch`.
**Diagnóstico:** El modelo en Python definía el campo `dispatched_at` (añadido recientemente para rastrear la hora de despacho de ruta), pero la tabla física en la base de datos carecía de esta columna. El script inicial (`auto_seed_on_first_boot`) usa `Base.metadata.create_all`, el cual **no realiza migraciones** en tablas ya existentes.

### Error G: "SIN CONEXIÓN — MODO LOCAL ACTIVO" falso al acceder desde internet (12/Julio/2026)
**Síntoma:** El repartidor accedía al sistema desde su celular con datos móviles vía `reparto.rdericotoluca.com`. La interfaz cargaba correctamente, pero el banner ámbar permanecía fijo en la parte superior porque el heartbeat al endpoint `/health` fallaba al intentar atacar una URL pública con puerto local (ej: `http://reparto.rdericotoluca.com:5001/health`).
**Solución:** Se reemplazó la construcción manual de la URL por una derivada de `CONFIG.API_BASE_URL`.

### Error H: Timestamps del Backend en UTC en vez de Hora de México (13/Julio/2026)
**Síntoma:** Las visitas del repartidor se registraban con hora UTC en la base de datos. Una visita realizada a las 22:00 hora de México aparecía como `04:00` del día siguiente en `arrived_at` y `completed_at`.
**Diagnóstico:** La función `create_visit()` en `service.py` usaba `datetime.now()`, que devuelve la hora del **sistema operativo del contenedor Docker**. Los contenedores Docker corren en UTC por defecto, independientemente del timezone del host Windows.
**Solución:** Se creó una función helper `_now_mexico()` a nivel de módulo en `service.py` que fuerza explícitamente `America/Mexico_City`:
```python
# SOLUCIÓN APLICADA EN apps/api/modules/grandeza/service.py
from zoneinfo import ZoneInfo
MEXICO_TZ = ZoneInfo('America/Mexico_City')
def _now_mexico():
    return datetime.now(MEXICO_TZ).replace(tzinfo=None)
```
Se reemplazaron los 3 usos de `datetime.now()` en el archivo (despacho, llegada, cierre).

---

## 7. Directivas Generales para Modificar este Módulo
1. **Jamás modificar el POS para arreglar Grandeza:** Si Grandeza requiere una adaptación, se debe hacer mediante nuevas columnas específicas en tablas `grandeza_` o interfaces únicas en su módulo de React. 
2. **Prevenir errores de red falsos:** Siempre utilizar herramientas como `Invoke-RestMethod` o `curl` directamente en el entorno de backend para desenmascarar errores 500, en lugar de confiar ciegamente en el `TypeError: Failed to fetch` del frontend.
3. **Zona horaria inquebrantable:** Toda operación relacionada a fechas y días de la semana (`hoy`) debe calcularse forzando explícitamente `America/Mexico_City`. No depender del reloj local no-filtrado del dispositivo móvil.
4. **Respetar la captura del usuario:** Nunca sobreescribir silenciosamente datos que el usuario ya capturó (fechas, horas, montos). Si hay un problema de validación, bloquearlo al intentar guardar con un mensaje claro, no modificar el dato a sus espaldas.
5. **Status de producción ≠ Status de pago:** El campo `status` es el flujo de producción (TENTATIVO, EN_PREPARACION, etc.). El campo `payment_status` es el estado financiero (PAGADO, ANTICIPO, PENDIENTE). Nunca mezclarlos.
6. **Eager loading obligatorio en SQLAlchemy Async:** Cualquier relación ORM que se acceda dentro de un bucle de serialización DEBE precargarse con `selectinload()` en la consulta inicial. De lo contrario, FastAPI dispara un error 500 silencioso que el frontend reporta como "Failed to fetch".
7. **Sincronización de Base de Datos (Migraciones):** Ya que el sistema usa `create_all` al arrancar, este no altera tablas existentes. Si agregas columnas a los modelos de SQLAlchemy, DEBES ejecutar el `ALTER TABLE` correspondiente en la base de datos; de lo contrario, provocarás caídas silenciosas (Error 500).
8. **No instalar Service Workers ni PWA plugins globales:** El frontend del POS y Grandeza comparten el mismo Vite build. Registrar un Service Worker global interceptaría las peticiones del POS. La funcionalidad offline se resuelve exclusivamente con IndexedDB dentro de `GrandezaDriverUI.jsx`.
9. **Toda URL de API debe derivarse de `CONFIG.API_BASE_URL`:** Nunca construir URLs de API manualmente con `window.location.hostname + ':5001'`. El archivo `config.js` es la **única fuente de verdad** para la base de la URL de API. Cualquier servicio interno (networkMonitor, GPS, sync) debe derivar su URL desde `CONFIG.API_BASE_URL`. Hardcodear puertos causa falsos negativos de conectividad cuando se accede desde internet vía Cloudflare Tunnels (ver Error G).
10. **Timestamps del backend en hora de México:** Dentro del módulo Grandeza, **nunca usar `datetime.now()` directamente**. Siempre usar la función helper `_now_mexico()` definida en `service.py`, que fuerza `America/Mexico_City` y devuelve un datetime naive compatible con PostgreSQL. Los contenedores Docker corren en UTC por defecto (ver Error H).

---

## 8. Arquitectura Offline-First (Modo Sin Conexión)

La herramienta del repartidor (`GrandezaDriverUI.jsx`) está diseñada para funcionar en zonas sin cobertura celular.

### Archivos Involucrados
- `apps/pos/services/offlineStore.js`: Capa de persistencia local usando IndexedDB nativo (sin librerías externas).
- `apps/pos/services/networkMonitor.js`: Monitor de conectividad con doble verificación (eventos del navegador + heartbeat al endpoint `/health`).

### Flujo Offline
1. **Al cargar con internet (mañana en la panadería):** `loadAll()` descarga toda la información (jornada, productos, clientes, inventario, ruta) y la guarda en IndexedDB (`cacheRouteData()`).
2. **Al perder señal:** Un banner discreto ámbar aparece: "📡 Sin conexión — Modo local activo". La app sigue funcionando normalmente.
3. **Al registrar una visita sin red:** El `saveVisit()` detecta el error de red y en lugar de mostrar "Error de red", encola la operación en `sync_queue` de IndexedDB. La visita se muestra optimistamente en la UI.
4. **GPS sin red:** Las coordenadas no se descartan (antes `.catch(() => {})`). Se guardan en `gps_buffer` de IndexedDB.
5. **Al recuperar señal:** El monitor de red detecta conectividad real (heartbeat exitoso a `/health`), procesa la cola automáticamente (`processQueue()`), envía el GPS buffereado (`flushGPSBuffer()`), y recarga datos frescos del servidor.

### IndexedDB: 3 Object Stores
| Store | Propósito | Clave |
|---|---|---|
| `cached_data` | Snapshot de jornada, productos, clientes, inventario, ruta | `key` (string) |
| `sync_queue` | Cola de operaciones HTTP pendientes | Auto-increment `id` |
| `gps_buffer` | Coordenadas GPS capturadas sin internet | Auto-increment `id` |

### Resolución de Conflictos al Sincronizar
- **HTTP 200/201:** Exitoso → eliminar de la cola
- **HTTP 409/422/404:** Conflicto (jornada cerrada, duplicado) → eliminar de cola + notificar al repartidor
- **HTTP 500:** Error del servidor → reintentar en el siguiente ciclo

### Por qué NO se usa Service Worker
El POS y Grandeza comparten el mismo dominio y build de Vite. Un Service Worker registrado globalmente interceptaría las peticiones del POS, arriesgando cachear datos obsoletos o bloquear actualizaciones críticas del punto de venta. La solución con IndexedDB es más segura porque actúa solo a nivel de componente React, no a nivel de navegador.

---

## 9. Integración WhatsApp (Deep Links)

La función `sendWhatsApp()` en `GrandezaDriverUI.jsx` genera una nota de venta formateada y la envía al cliente vía WhatsApp usando enlaces profundos (`wa.me`).

### Flujo
1. El repartidor captura la venta (productos, cantidades, pago).
2. Presiona "Enviar ticket por WhatsApp".
3. Se genera un mensaje con formato Markdown de WhatsApp: fecha, nombre del cliente, productos, cantidades (entregas y recompras), importes netos, total, cambio y el número de Servicio al Cliente (SAC).
4. El formato está diseñado para ser profesional, compacto y fácil de leer en un sola pantalla de móvil, omitiendo leyendas promocionales.
5. Se abre `https://wa.me/52XXXXXXXXXX?text=...` que dispara la app de WhatsApp con el mensaje pre-escrito.

### Validación de Teléfono
- Se limpian caracteres no numéricos (`replace(/\D/g, '')`)
- Se valida longitud de 10 dígitos (formato México)
- Si el teléfono tiene más de 10 dígitos, se toman los últimos 10
- Si no hay teléfono registrado, se abre WhatsApp sin destinatario para que el repartidor elija el contacto manualmente

### Costo
Gratuito. No requiere API de WhatsApp Business ni aprobación de Meta. Usa el número del celular del repartidor.

---

## 10. Despliegue en Internet (Cloudflare Tunnels)

Aunque el módulo cuenta con una arquitectura Offline-First para lidiar con pérdida de señal, el objetivo principal es que el repartidor opere en **tiempo real** desde la calle usando sus datos móviles.

Para lograr esto de forma segura sin exponer el servidor local (abrir puertos en el router), se implementa **Cloudflare Tunnels** (`cloudflared` como servicio de Windows/Linux).

### Enrutamiento de Subdominios (Public Hostnames)
El túnel conecta la red privada hacia la red global de Cloudflare mediante dos reglas:
1. **Frontend:** `reparto.tudominio.com` → `http://localhost:5000`
2. **Backend (API):** `api.tudominio.com` → `http://localhost:5001`

### Resolución Dinámica de API (config.js)
El archivo `apps/pos/config.js` está diseñado para manejar conexiones híbridas. Evalúa `window.location.hostname` al arrancar:
- **Si es Local/LAN (ej. `192.168.1.124` o `localhost`):** Dirige el tráfico de red directamente al puerto `5001`.
- **Si es Público (ej. `reparto.rdericotoluca.com`):** Sustituye el subdominio por `api` (ej. `api.rdericotoluca.com`) y dirige el tráfico usando el puerto por defecto de HTTPS (443), saltándose el puerto local 5001 que no está expuesto a internet.

**Instalación PWA (Progressive Web App)**
Se recomienda que el repartidor abra el enlace (`reparto.rdericotoluca.com/?terminal=DRIVER`) en Google Chrome o Safari y utilice la opción "Agregar a la pantalla principal". Esto oculta la barra de navegación del navegador y permite que el sistema opere a pantalla completa como una aplicación nativa.

---

## 11. Nuevas Funcionalidades y Refinamientos (v7.1.0)

En la versión 7.1.0 se agregaron refinamientos operativos para mejorar la inteligencia y usabilidad del sistema:

### 11.1 Sugerencias Dinámicas (Herramienta Repartidor)
El sistema ahora recalcula la cantidad "Sugerida" de piezas en **tiempo real** mientras el repartidor ingresa los cambios de mercancía.
- **Lógica:** `Sugerido = (Frescas dejadas la visita anterior) - (Cambios recogidos hoy)`
- Esta métrica refleja las piezas que el cliente *efectivamente capitalizó* (vendió), lo cual es más preciso que un simple promedio histórico.
- **Indicador Visual:** Cuando el sistema realiza este cálculo dinámico, la sugerencia cambia de color azul a **cyan con un icono de rayo (⚡)** para indicar al repartidor que el número está siendo ajustado basándose en los cambios que acaba de ingresar.
- **Endpoint:** El endpoint `/suggestions` (`service.py`) ahora devuelve `last_fresh_qty` adicional al `suggested_qty` (promedio histórico) para posibilitar este cálculo reactivo en el frontend.

### 11.2 Modal de Estadísticas por Cliente (Herramienta Administrador)
Se agregó un botón **"📊"** en el directorio de clientes de la suite `GrandezaParamsUI`.
- Abre un modal detallado que muestra el **historial completo de visitas** del cliente.
- Incluye un filtro dropdown para ver el rendimiento por producto específico.
- Muestra tarjetas resumen con promedios de: Visitas, Frescas, Cambios, Capitalizadas y Sugeridas.
- La tabla de historial resalta las últimas 3 visitas, indicando visualmente que estas son las que el sistema utiliza para calcular la sugerencia de inventario por defecto.

### 11.3 UI y Comunicación
- **WhatsApp:** El mensaje fue rediseñado para ser más profesional y ocupar menos espacio en pantalla. Se eliminaron los íconos excesivos y las leyendas de la marca ("R DE RICO", "PAN GRANDEZA"). Se agregó el teléfono de Servicio al Cliente (SAC) al final. El término "cambios" fue reemplazado por "recompras" para mayor claridad del cliente.
- **Sidebar:** El botón flotante de la suite Grandeza en el menú principal (`ExperimentCenterUI`) fue rediseñado de un cuadrado a un medio círculo estilizado, ocupando menos espacio y mejorando la estética.

---

## 12. Mejoras de Robustez y Correcciones (v7.2.0 — 13/Julio/2026)

### 12.1 Persistencia de Borrador de Visita (Anti-Kill de Pestaña Móvil)
**Problema:** Cuando el repartidor cambiaba de app en el celular (WhatsApp, llamada, etc.), el SO de Android/iOS podía matar la pestaña del navegador para liberar RAM. Al regresar, la página se recargaba y **todos los datos capturados** (piezas de cambio, frescas, pago recibido, notas) se perdían.

**Solución:** Se implementó un hook `useVisitDraft` en `GrandezaDriverUI.jsx` que persiste automáticamente los datos de la visita activa en `localStorage` del navegador en cada cambio de campo. Al recargar la página, si existe un borrador, se restaura inmediatamente incluyendo la vista activa.

### 12.2 Fix: Modal de Edición de Cliente en Vista de Visita
**Problema:** El botón ✏️ de editar cliente dentro de la vista de visita no abría el modal. Funcionaba solo si el usuario presionaba "← Ruta" después.

**Causa:** El componente `EditClientModal` estaba renderizado en las vistas de ESPERANDO_FIRMA y Ruta, pero **faltaba en la vista de Visita**. 

**Solución:** Se agregó el renderizado de `EditClientModal` dentro del bloque JSX de la vista de visita. Al guardar cambios del cliente, también se actualiza `activeVisit` para que la UI refleje los datos nuevos inmediatamente.

### 12.3 Protección contra Visitas Duplicadas (Backend)
**Problema:** Podían registrarse múltiples visitas al mismo cliente en la misma jornada.

**Solución:** Se agregó validación en `create_visit()` de `service.py`. Antes de crear la visita, verifica si ya existe una visita `COMPLETADA` para el mismo `client_id` en la misma jornada. Si existe, rechaza con **HTTP 409**.
**Frontend:** `saveVisit()` ahora maneja el 409 específicamente: muestra toast "⚠️ Este cliente ya fue visitado hoy", limpia el borrador y regresa a la vista de ruta.

### 12.4 Corrección de Timezone en Timestamps del Backend
**Problema:** Los timestamps de visitas (`arrived_at`, `completed_at`) y despacho de ruta (`dispatched_at`) se guardaban en UTC en vez de hora de México.

**Solución:** Se creó la función helper `_now_mexico()` a nivel de módulo en `service.py` que fuerza `America/Mexico_City` y devuelve un datetime naive compatible con PostgreSQL. Se reemplazaron los 3 usos de `datetime.now()` en el archivo. (Ver detalles en **Error H**).

> ⚠️ **NOTA:** Esta corrección es exclusiva del módulo Grandeza. Una corrección global a nivel de contenedor Docker queda pendiente como proyecto separado que requiere auditoría completa del ERP.

---

## 13. Rutas Extraordinarias (v7.3.0 — 20/Julio/2026)

### 13.1 Visión General
Se agregó la capacidad de crear **rutas extraordinarias** para fechas específicas que reemplazan automáticamente la ruta regular del día de la semana. La ruta extraordinaria aplica **solo para ese día**, y al día siguiente el sistema vuelve a las rutas regulares sin intervención manual.

**Casos de uso:**
- Días festivos donde la ruta cambia (12 de diciembre, Día de Muertos, Navidad).
- Pedidos especiales para un evento — se agrega un cliente que no está en la ruta regular.
- Vacaciones de un cliente — se saca de la ruta solo ese día sin alterar la plantilla semanal.
- Cobertura de otra zona — un repartidor cubre una zona diferente un día específico.

### 13.2 Arquitectura: Endpoint Inteligente `get_effective_route`
El corazón de esta funcionalidad es un **único endpoint inteligente** que decide qué ruta devolver:

```
GET /api/v1/grandeza/routes/effective/{fecha}
```

**Lógica de decisión:**
1. ¿Existe una ruta extraordinaria para esa fecha exacta? → **SÍ:** Devolver `type: "EXTRAORDINARIA"` con sus slots y etiqueta.
2. ¿No existe? → Calcular el día de la semana de esa fecha y devolver la ruta regular con `type: "REGULAR"`.

```
Driver abre la app → fetch /routes/effective/2026-12-25
                │
    ┌─────────────────────────────────────┐
    │  get_effective_route(2026-12-25)    │
    │  1. ¿Existe extraordinaria? → SÍ   │
    │  2. Retorna type: EXTRAORDINARIA    │
    └─────────────────────────────────────┘
                │
    Driver ve: ⚡ RUTA EXTRAORDINARIA — "Ruta Navidad"
                │
    Al día siguiente (26 Dic)...
    ┌─────────────────────────────────────┐
    │  get_effective_route(2026-12-26)    │
    │  1. ¿Existe extraordinaria? → NO   │
    │  2. weekday() → VIERNES            │
    │  3. Retorna type: REGULAR          │
    └─────────────────────────────────────┘
```

### 13.3 Base de Datos

**Nueva tabla:** `grandeza_extraordinary_route_slots`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | SERIAL PK | Identificador único |
| `route_date` | DATE (indexed) | Fecha exacta de la ruta extraordinaria |
| `client_id` | INTEGER FK → `grandeza_clients.id` | Cliente asignado |
| `visit_order` | INTEGER | Posición en la secuencia del día |
| `label` | VARCHAR (nullable) | Etiqueta opcional (ej: "Ruta Día de Muertos") |
| `created_at` | TIMESTAMP | Fecha de creación |

**Modelo SQLAlchemy:** `GrandezaExtraordinaryRouteSlot` en `apps/api/modules/grandeza/models.py`

**Migración SQL:**
```sql
CREATE TABLE IF NOT EXISTS grandeza_extraordinary_route_slots (
    id SERIAL PRIMARY KEY,
    route_date DATE NOT NULL,
    client_id INTEGER NOT NULL REFERENCES grandeza_clients(id),
    visit_order INTEGER NOT NULL,
    label VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_grandeza_extraordinary_route_slots_route_date 
    ON grandeza_extraordinary_route_slots(route_date);
```

### 13.4 API — Endpoints Nuevos

| Método | Endpoint | Propósito |
|--------|----------|-----------|
| `GET` | `/routes/effective/{fecha}` | **Ruta inteligente:** prioriza extraordinaria sobre regular (usado por el Driver) |
| `GET` | `/routes/extraordinary` | Lista todas las rutas extraordinarias con resumen (Admin) |
| `GET` | `/routes/extraordinary/{fecha}` | Obtener los slots de una ruta extraordinaria específica (Admin) |
| `PUT` | `/routes/extraordinary/{fecha}` | Crear o reemplazar una ruta extraordinaria completa (Admin) |
| `DELETE` | `/routes/extraordinary/{fecha}` | Eliminar una ruta extraordinaria (Admin) |

> ⚠️ **IMPORTANTE (FastAPI):** Los endpoints con rutas literales (`/effective`, `/extraordinary`) se registran **ANTES** que `/routes/{day_of_week}` en `router.py` para evitar que FastAPI capture "effective" o "extraordinary" como un parámetro `day_of_week`.

### 13.5 Backend — Servicio

5 funciones nuevas en `apps/api/modules/grandeza/service.py`:

| Función | Propósito |
|---------|-----------|
| `get_extraordinary_route(db, route_date)` | Obtener slots con eager loading de clientes |
| `set_extraordinary_route(db, route_date, slots, label)` | Reemplazar ruta completa (delete + insert) |
| `delete_extraordinary_route(db, route_date)` | Eliminar ruta por fecha |
| `list_extraordinary_routes(db)` | Agrupar por fecha con conteo de clientes |
| `get_effective_route(db, route_date)` | **Función inteligente** de decisión |

### 13.6 Frontend — Administrador (`GrandezaParamsUI.jsx`)

Se agregó una sección **⚡ Rutas Extraordinarias** en la pestaña "Rutas por Día", debajo de las rutas regulares. Diseño con tema púrpura para diferenciarse visualmente de las rutas regulares (naranja).

**Componentes:**
- **Lista de rutas existentes:** Tarjetas con fecha formateada, día de la semana, etiqueta, conteo de clientes, y botones Editar/Eliminar. Las rutas pasadas se muestran con opacidad reducida.
- **Botón "+ Nueva Ruta":** Abre el modal de edición.
- **Modal Editor:** Date picker nativo (`<input type="date">`), campo de etiqueta opcional, y la misma mecánica de agregar/quitar/reordenar clientes que las rutas regulares.
- **Modal de confirmación de eliminación:** Estilo destructivo con nombre de fecha y día.

**Diseño Responsivo:**
- **Móvil:** Modal se abre desde abajo con bordes redondeados superiores (`items-end`, `rounded-t-[32px]`). Botones full-width. Tarjetas se apilan verticalmente.
- **Desktop:** Modal centrado. Layout de 3 columnas (lista 2/3 + panel agregar 1/3).

### 13.7 Frontend — Herramienta Repartidor (`GrandezaDriverUI.jsx`)

**Cambio mínimo (3 líneas + badge visual):**

El fetch de la ruta cambió de:
```javascript
// ANTES
const routeRes = await fetch(`${API}/grandeza/routes/${todayDay}`);
const rSlots = routeRes.ok ? await routeRes.json() : [];

// DESPUÉS
const routeRes = await fetch(`${API}/grandeza/routes/effective/${todayStr()}`);
const routeData = routeRes.ok ? await routeRes.json() : { type: 'REGULAR', slots: [] };
const rSlots = routeData.slots || [];
```

**Badge visual:** Cuando la ruta es extraordinaria, se muestra un indicador púrpura en el encabezado:
```
⚡ Ruta Extraordinaria — "Ruta Navidad"
```
Esto avisa al repartidor que no es su ruta habitual.

**Caché offline:** Sigue funcionando sin cambios. La estructura de `rSlots` (array de objetos con `client_id`, `visit_order`, `client`) es idéntica.

### 13.8 Archivos Modificados (Resumen)

| Archivo | Tipo de Cambio |
|---------|---------------|
| `apps/api/modules/grandeza/models.py` | Nuevo modelo `GrandezaExtraordinaryRouteSlot` |
| `apps/api/modules/grandeza/schemas.py` | 3 schemas nuevos |
| `apps/api/modules/grandeza/service.py` | Import + 5 funciones nuevas |
| `apps/api/modules/grandeza/router.py` | 5 endpoints nuevos (antes de `{day_of_week}`) |
| `apps/pos/GrandezaParamsUI.jsx` | Sección UI + state + handlers para rutas extraordinarias |
| `apps/pos/GrandezaDriverUI.jsx` | Fetch a `/effective/{fecha}` + badge visual |
| **POS (RetailVisionPOS.jsx)** | **CERO cambios** ✅ |

