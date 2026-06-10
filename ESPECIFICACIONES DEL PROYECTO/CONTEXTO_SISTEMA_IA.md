# ERP R DE RICO — CONTEXTO DEL SISTEMA Y REGLAS DE PROGRAMACIÓN PARA IAs

> **LECTURA OBLIGATORIA.** Este documento es la autoridad máxima para cualquier agente de IA, desarrollador o auditor que trabaje en este proyecto. Define las reglas de calidad, disciplina de programación y arquitectura del sistema ERP de la empresa **R de Rico** (panadería artesanal/industrial con sede en Toluca, México).
>
> Si algún otro documento, prompt o instrucción contradice lo aquí especificado, **este documento prevalece**.
>
> **Última actualización:** 2026-06-10
> **Repositorio principal:** https://github.com/vikutasan/ERP-R-DE-RICO-CON-POS-SIMPLIFICADO

---

## 1. PRINCIPIOS DE INGENIERÍA — LEY SUPREMA

Estas reglas no son sugerencias. Son **obligaciones inquebrantables**. Cualquier IA o desarrollador que las viole está entregando código basura y causando daño directo al negocio.

---

### 1.1 PRINCIPIOS FUNDAMENTALES DE CÓDIGO LIMPIO

#### DRY — Don't Repeat Yourself (No Te Repitas)

Si estás escribiendo la misma lógica en dos lugares, **crea una función reutilizable**. No hay excusa.

- **Ejemplo de violación:** Calcular el IVA con `precio * 1.16` en el módulo de panadería y otra vez con la misma fórmula en el módulo de helados.
- **Corrección:** Crear un Helper o función de utilidad global (`calcularImpuesto(precioBase)`) y llamarla desde ambos módulos.
- **Cómo detectarlo:** Busca patrones repetidos. Si copias y pegas un bloque de código, estás violando DRY.

#### KISS — Keep It Simple, Stupid (Mantenlo Simple)

Si una función se ve muy compleja, **simplifícala**. Divídela en funciones más pequeñas y claras.

- No inventar soluciones complicadas para problemas simples. La solución más directa y legible es siempre la correcta.
- Si necesitas un comentario de 3 líneas para explicar qué hace un bloque de código, ese bloque necesita ser reescrito, no comentado.

#### SRP — Principio de Responsabilidad Única

Un archivo o función debe hacer **una sola cosa**.

- **Ejemplo de violación:** Una función que guarda una venta, envía un correo electrónico y recalcula el inventario al mismo tiempo.
- **Corrección:** Separar en tres funciones: `guardarVenta()`, `notificarVenta()`, `actualizarInventario()`.
- **Cómo detectarlo:** Si al abrir un archivo ves que hace más de una tarea conceptual, está mal diseñado. Instrucción: *"Refactoriza esta función; está haciendo demasiadas cosas. Separa la lógica de cálculo de la lógica de guardado."*

---

### 1.2 CÓDIGO AUTODOCUMENTADO — NOMBRES QUE HABLEN

El buen código se explica solo por los nombres que usa. Los comentarios son para el "por qué", no para el "qué".

**❌ Código basura:**
```javascript
var x = y * 1.16; // calcula el iva
var d = new Date(); // fecha actual
var temp = arr.filter(i => i.a > 0); // filtra activos
```

**✅ Código limpio:**
```javascript
const precioConImpuesto = precioBase * TASA_IVA_MEXICO;
const fechaActual = new Date();
const productosActivos = catalogo.filter(producto => producto.activo);
```

**Reglas de nombres:**
- **No se aceptan** variables genéricas como `data`, `temp`, `x`, `item`, `result`, `info`. Usa nombres descriptivos: `nuevoPedido`, `stockRestante`, `terminalActiva`.
- Los nombres deben describir **qué contienen**, no cómo se usan.
- Si un nombre necesita un comentario al lado para entenderse, el nombre está mal elegido.

---

### 1.3 COMPLEJIDAD CICLOMÁTICA — EL GOBERNADOR

Si una función tiene demasiados `if... else... if... else`, es una **bomba de tiempo**.

**Reglas estrictas:**
- **Máximo 3 niveles de indentación (anidamiento).** Si ves código con "escalones" que se van hacia la derecha, está demasiado complejo.
- **Usar Early Returns (retornos tempranos)** para reducir anidamiento.
- **Funciones de máximo 20 líneas.** Si una función supera 20 líneas, probablemente está haciendo más de una cosa y debe dividirse.

**❌ Código anidado (bomba de tiempo):**
```javascript
function procesarVenta(venta) {
    if (venta) {
        if (venta.items.length > 0) {
            if (venta.metodoPago) {
                if (venta.terminal) {
                    // ... lógica enterrada en 4 niveles
                }
            }
        }
    }
}
```

**✅ Con Early Returns (limpio):**
```javascript
function procesarVenta(venta) {
    if (!venta) return;
    if (venta.items.length === 0) return;
    if (!venta.metodoPago) return;
    if (!venta.terminal) return;

    // lógica principal, plana y legible
}
```

---

### 1.4 CHECKLIST DEL ARQUITECTO

Antes de aceptar cualquier código como terminado, responder estas 3 preguntas:

| Pregunta | Criterio |
|----------|----------|
| **¿Es legible?** | Si no entiendes qué está pasando en 30 segundos, el código no es limpio. Reescríbelo. |
| **¿Es escalable?** | Si mañana R de Rico abre una sucursal en otra ciudad, ¿el código permite cambiar la ubicación fácilmente o está "pegado con pegamento" a Toluca? |
| **¿Tiene manejo de errores?** | ¿Qué pasa si se intenta descontar pan y no hay internet? El código debe decir: *"Si falla, guarda en local y reintenta después"*, no simplemente colapsar. |

**Tip de verificación final:**
> *"Aplica una revisión de principios SOLID al código que acabas de generar. Asegúrate de que no haya funciones de más de 20 líneas y que toda la comunicación entre módulos sea a través de interfaces claras."*

---

### 1.5 NO ENTREGAR CÓDIGO BASURA — REGLAS ESPECÍFICAS

- **No se acepta código "de relleno", incompleto, provisional ni "placeholder".** Si no puedes hacer algo bien, di que no puedes. No entregues algo a medias esperando que "después se arregle".
- **No dejar `console.log()` de depuración** en código de producción. Si los necesitas para diagnosticar, quítalos cuando termines.
- **No crear archivos temporales, scripts sueltos, ni documentos de prueba** en la raíz del proyecto ni en ninguna carpeta del repositorio.
- **No dejar código comentado** que "ya no se usa pero por si acaso". Si se eliminó, se eliminó. Git tiene historial para eso.
- **No dejar imports sin usar.** Si ya no se usa un módulo, elimina el import.

---

### 1.6 NO INTERRUMPIR LA OPERACIÓN DEL NEGOCIO

> **Esta panadería opera en tiempo real.** Hay cajeros cobrando, repartidores cargando rutas, y producción planificando masas. El frontend corre con hot-reload dentro de Docker: **cualquier error de sintaxis en cualquier archivo `.jsx` congela TODAS las tablets de la panadería simultáneamente.** Esto causa pérdidas económicas reales e inmediatas.

**Protocolo obligatorio antes de cualquier cambio:**

1. **Entender antes de tocar.** Lee la documentación del módulo afectado ANTES de escribir una sola línea. No asumas que "es obvio".
2. **Verificar que compila.** Todo cambio debe pasar `npm run build` sin errores antes de considerarse terminado.
3. **Cambios pequeños y verificables.** No hagas refactorizaciones masivas. Un cambio a la vez, verificado, funcionando.
4. **Si rompes algo, arréglalo INMEDIATAMENTE.** No pases a otra cosa dejando el sistema roto.
5. **Nunca experimentes en producción.** Si quieres probar algo, hazlo en un archivo aislado. Nunca directamente sobre archivos que están siendo servidos a las terminales.

---

### 1.7 MÓDULOS CRÍTICOS — ZONAS RESTRINGIDAS

Los siguientes archivos son el **corazón económico** del negocio. Tienen bugs históricos resueltos con soluciones muy específicas que **no deben revertirse bajo ninguna circunstancia**:

**Frontend POS (Punto de Venta):**
- `apps/pos/RetailVisionPOS.jsx`
- `apps/pos/hooks/useCart.js`
- `apps/pos/hooks/useTerminalLocking.js`
- `apps/pos/services/POSService.js`
- `apps/pos/components/CheckoutScreen.jsx`
- `apps/pos/OpenAccountsCorkboard.jsx`

**Backend POS:**
- `apps/api/modules/pos/service.py`
- `apps/api/modules/pos/occupancy.py`
- `apps/api/modules/pos/router.py`
- `apps/api/modules/pos/models.py`

**REGLA:** No se toca NINGUNO de estos archivos sin haber leído completo `DOCUMENTACION_MODULO_POS.md` primero. No hay excepciones.

---

### 1.8 ESTÁNDARES DE CÓDIGO

- **React 18** con hooks funcionales. No usar class components (excepto `ErrorBoundary`).
- **TailwindCSS 3** para estilos. Utility-first. No crear archivos CSS separados por componente.
- **Imports con alias:** `@` apunta a `./apps/`, `@packages` apunta a `./packages/`.
- **No usar `alert()`, `confirm()`, ni `prompt()` del navegador.** Usar Toasts o modales React.
- **Nombres de archivos:** PascalCase para componentes (`.jsx`), camelCase para hooks y servicios (`.js`).
- **API calls:** Siempre usar `window.location.hostname` para construir URLs del backend. **Nunca hardcodear IPs** (ni `localhost`, ni `192.168.x.x`).
- **Timestamps:** El backend almacena en UTC. El frontend convierte a hora local para mostrar. Nunca manipular zonas horarias en el backend.

---

### 1.9 DEFENSA EN PROFUNDIDAD (SEGURIDAD)

Todo mecanismo de seguridad debe implementarse en **múltiples capas**. Nunca confiar en una sola:

1. **Capa UI:** El frontend oculta o deshabilita botones/módulos según permisos del usuario.
2. **Capa de Lógica Frontend:** Validaciones antes de enviar al backend.
3. **Capa Backend:** El servidor valida permisos, roles y reglas de negocio **independientemente** de lo que diga el frontend.
4. **Capa de Base de Datos:** Constraints, foreign keys e integridad referencial como última línea de defensa. Si un `DELETE` viola integridad, el backend debe manejar el error con gracia (por ejemplo, soft-delete).

**Nunca asumir que "el frontend ya lo validó".** El backend debe ser capaz de rechazar cualquier petición inválida por sí mismo.

---

### 1.10 DISCIPLINA DE REPOSITORIO

- **No subir archivos que no sean código fuente al repositorio.** Nada de `.sql`, `.csv`, `.xls`, `.docx`, `.json` de datos, ni respaldos de base de datos.
- **No crear carpetas temporales** (`tmp/`, `test/`, `scratch/`, `old/`).
- **No dejar archivos autogenerados** (como `vite.config.js.timestamp-*.mjs`).
- **Cada commit debe tener un propósito claro.** No commits tipo "asdf", "fix", "test", "WIP".
- **La carpeta `ESPECIFICACIONES DEL PROYECTO/` es exclusiva para documentación maestra oficial.** No meter ahí borradores, notas personales ni documentos obsoletos.

---

### 1.11 PROCESO DE TRABAJO OBLIGATORIO

1. **Leer antes de actuar.** Antes de tocar cualquier módulo, lee este documento y la documentación específica del módulo si existe.
2. **Preguntar antes de asumir.** Si algo no está claro, pregunta. No inventes interpretaciones.
3. **Un cambio a la vez.** Implementar, verificar, confirmar. Luego el siguiente.
4. **Documentar lo importante.** Si resuelves un bug crítico o cambias arquitectura, actualiza la documentación correspondiente.
5. **Limpiar después de ti.** No dejes archivos temporales, código muerto, ni imports sin usar.
6. **Respetar lo que ya funciona.** Si un módulo está en producción y funciona, no lo "mejores" sin razón. *"Si no está roto, no lo arregles."*

---

## 2. VISIÓN DEL PROYECTO

R de Rico es un **ecosistema complejo** que mezcla retail, manufactura, logística y hospitalidad. Bajo el mismo techo opera:

- Producción y venta de **panadería artesanal mexicana**
- Producción, venta y reparto de **pizzas**
- Venta de **helados y paletas** (producidos en otra planta)
- Preparación y venta de **malteadas y aguas frescas**
- Servicio de **cafetería de especialidad** con área de mesas
- Venta de algunos **abarrotes y souvenirs**
- Venta y entrega de **pasteles bajo pedido** (elaborados en otra planta de producción)

El ERP fue concebido como un **Ecosistema Digital Evolutivo**: modular, compatible entre módulos, y capaz de incorporar fácilmente los avances tecnológicos que vayan surgiendo.

### Principios Arquitectónicos

- **Local-First:** Cada sucursal tiene su servidor con planta de luz de emergencia. El sistema funciona aunque se vaya el internet o la electricidad pública. Los datos se sincronizan al servidor corporativo durante las madrugadas.
- **Modular:** Cada módulo es independiente y compatible con los demás. Se construyen y despliegan por separado.
- **Contenedores (Docker):** Cada servicio vive en su propio contenedor, permitiendo actualizaciones sin tirar todo el sistema.

---

## 3. ARQUITECTURA DEL SISTEMA

### 3.1 Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| **Frontend** | React 18 + Vite 4 + TailwindCSS 3 |
| **Backend** | Python FastAPI + Uvicorn |
| **Base de Datos** | PostgreSQL 15 (Alpine) |
| **ORM** | SQLAlchemy (async con asyncpg) |
| **Contenedores** | Docker + Docker Compose |
| **IA (Visión)** | Google Generative AI (`@google/generative-ai`) |
| **Iconografía** | Lucide React |

### 3.2 Infraestructura

- **Servidor:** PC Windows con IP fija `192.168.1.117` en red local.
- **Proyecto instalado en:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO\`
- **Datos persistentes en:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO-DATA\` (imágenes, configuración de terminales, volúmenes PostgreSQL).

### 3.3 Contenedores Docker

| Contenedor | Puerto Externo → Interno | Función |
|------------|--------------------------|---------|
| `rderico-pos-dev` | 5000 → 3000 | Frontend React (Vite dev server) |
| `rderico-api-dev` | 5001 → 3001 | Backend FastAPI (Uvicorn) |
| `rderico-db-dev` | 5433 → 5432 | PostgreSQL |

> **CRÍTICO:** Los archivos `.jsx` están montados como volumen bind en Docker. Esto significa que cualquier cambio se refleja en vivo en TODAS las terminales conectadas. Es una ventaja para desarrollo y un riesgo enorme si se introduce un error.

### 3.4 Acceso desde Terminales

- **Frontend (tablets/PCs):** `http://192.168.1.117:5000`
- **API:** `http://192.168.1.117:5001`
- **Archivos estáticos (imágenes):** `http://192.168.1.117:5001/static/images/`

---

## 4. MÓDULOS DEL SISTEMA

| Módulo | Ubicación Principal | Estado |
|--------|---------------------|--------|
| Punto de Venta IA | `apps/pos/RetailVisionPOS.jsx` | ✅ Producción — **ZONA RESTRINGIDA** |
| TPV Mesas & KDS | `apps/pos/TableServicePOS.jsx` | ✅ Producción |
| Gestión de Productos | `apps/inventory/` | ✅ Producción |
| Gestión de Almacenes | `apps/inventory/` (warehouse) | ✅ Producción |
| Entrenamiento IA (Visión) | `apps/pos/VisionTrainingUI.jsx` | ✅ Producción |
| Gestión de la Producción | `apps/production/` | ✅ Producción |
| Reparto Pan Grandeza | `apps/pos/RepartoPanGrandezaUI.jsx` | ✅ Producción |
| Módulo Financiero | `apps/financials/` | ✅ Producción |
| Estadísticas de Ventas | `apps/analytics/` | ✅ Producción |
| Facturación CFDI | `apps/pos/` (invoicing) | ✅ Producción |
| Gestión de Compras | `apps/b2b/` | ✅ Producción |
| Logística de Rutas | `apps/logistics/` | ✅ Producción |
| App Mesero | `apps/waiter-app/` | ✅ Producción |
| App Repartidor | `apps/driver-app/` | ✅ Producción |
| Seguridad y Acceso | `apps/auth/` | ✅ Producción |
| Auditoría y Control | `apps/AuditoriaControlUI.jsx` | ✅ Producción |
| Ajustes del Sistema | `apps/settings/` | ✅ Producción |
| Monitoreo de Red | `apps/network/` | ✅ Producción |

### Punto de Entrada

`main.jsx` → `<ExperimentCenterUI />` (Hub Central con sidebar y navegación entre módulos).

---

## 5. MODELO DE SEGURIDAD

- **Empleados** (`Employee`) con roles: `ADMIN`, `MANAGER`, `CASHIER`, `BAKER`, `WAITER`, `DRIVER`, `LOGISTICS`.
- **Perfiles de Seguridad** (`SecurityProfile`) con permisos granulares por módulo.
- **Validación siempre dual:** Frontend oculta lo no autorizado, backend rechaza lo no autorizado. Ambas capas son obligatorias.
- **Permisos especiales POS:** `pos_force_unlock` y `pos_force_cash_unlock` para desbloqueo forzado de terminales.

---

## 6. COMANDOS ESENCIALES

```bash
# Levantar el sistema completo
docker-compose up -d

# Ver logs del frontend en tiempo real
docker logs -f rderico-pos-dev

# Ver logs del backend en tiempo real
docker logs -f rderico-api-dev

# Verificar que el código compila (OBLIGATORIO antes de dar por terminado un cambio)
npm run build

# Respaldo de base de datos
docker exec rderico-db-dev pg_dump -U user rderico > db_backup_FECHA.sql

# Reiniciar un servicio específico
docker restart rderico-pos-dev
```

---

## 7. DOCUMENTOS DE REFERENCIA

Todos los documentos maestros viven en la carpeta `ESPECIFICACIONES DEL PROYECTO/`:

| Documento | Propósito |
|-----------|-----------|
| **`CONTEXTO_SISTEMA_IA.md`** (este) | Principios de programación, reglas de calidad, arquitectura y disciplina de trabajo. Lectura obligatoria universal. |
| **`DOCUMENTACION_MODULO_POS.md`** | Especificación completa del Punto de Venta IA. Lógica, bugs históricos resueltos, reglas inquebrantables. **Lectura obligatoria antes de tocar el POS.** |
| **`DOCUMENTACION_MODULO_GESTION_PRODUCTOS.md`** | Especificación del módulo de Gestión de Productos. Lógica de eliminación, capas de seguridad, categorías. |

---

*Este documento es ley. Cualquier agente de IA que trabaje en este proyecto debe leerlo antes de escribir su primera línea de código. La calidad no es opcional.*
