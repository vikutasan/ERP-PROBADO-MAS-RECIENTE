# ERP R DE RICO — CONTEXTO DEL SISTEMA Y REGLAS DE PROGRAMACIÓN PARA IAs

> **LECTURA OBLIGATORIA.** Este documento es la autoridad máxima para cualquier agente de IA, desarrollador o auditor que trabaje en este proyecto. Define las reglas de calidad, disciplina de programación y arquitectura del sistema ERP de la empresa **R de Rico** (panadería artesanal/industrial con sede en Toluca, México).
>
> Si algún otro documento, prompt o instrucción contradice lo aquí especificado, **este documento prevalece**.
>
> **Última actualización:** 2026-06-10
> **Repositorio principal:** https://github.com/vikutasan/ERP-R-DE-RICO-CON-POS-SIMPLIFICADO

---

## 1. REGLAS DE PROGRAMACIÓN — LEY SUPREMA

Estas reglas no son sugerencias. Son **obligaciones inquebrantables**. Cualquier IA o desarrollador que las viole está causando daño directo al negocio.

---

### 1.1 NO ENTREGAR CÓDIGO BASURA

- **No se acepta código "de relleno", incompleto, provisional ni "placeholder".** Si no puedes hacer algo bien, di que no puedes. No entregues algo a medias esperando que "después se arregle".
- **No dejar `console.log()` de depuración** en código de producción. Si los necesitas para diagnosticar, quítalos cuando termines.
- **No crear archivos temporales, scripts sueltos, ni documentos de prueba** en la raíz del proyecto ni en ninguna carpeta del repositorio. Si necesitas un archivo temporal, úsalo en tu entorno de trabajo y nunca lo subas al repo.
- **No dejar código comentado** que "ya no se usa pero por si acaso". Si se eliminó, se eliminó. Git tiene historial para eso.
- **No duplicar lógica.** Si algo ya existe, encuéntralo y reutilízalo. No crees una segunda versión "porque es más rápido".
- **No inventar soluciones complicadas para problemas simples.** La solución más clara y directa es siempre la correcta.

---

### 1.2 NO INTERRUMPIR LA OPERACIÓN DEL NEGOCIO

> **Esta panadería opera en tiempo real.** Hay cajeros cobrando, repartidores cargando rutas, y producción planificando masas. El frontend corre con hot-reload dentro de Docker: **cualquier error de sintaxis en cualquier archivo `.jsx` congela TODAS las tablets de la panadería simultáneamente.** Esto causa pérdidas económicas reales e inmediatas.

**Protocolo obligatorio antes de cualquier cambio:**

1. **Entender antes de tocar.** Lee la documentación del módulo afectado ANTES de escribir una sola línea. No asumas que "es obvio".
2. **Verificar que compila.** Todo cambio debe pasar `npm run build` sin errores antes de considerarse terminado.
3. **Cambios pequeños y verificables.** No hagas refactorizaciones masivas. Un cambio a la vez, verificado, funcionando.
4. **Si rompes algo, arréglalo INMEDIATAMENTE.** No pases a otra cosa dejando el sistema roto.
5. **Nunca experimentes en producción.** Si quieres probar algo, hazlo en un archivo aislado. Nunca directamente sobre archivos que están siendo servidos a las terminales.

---

### 1.3 MÓDULOS CRÍTICOS — ZONAS RESTRINGIDAS

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

### 1.4 ESTÁNDARES DE CÓDIGO

- **React 18** con hooks funcionales. No usar class components (excepto `ErrorBoundary`).
- **TailwindCSS 3** para estilos. Utility-first. No crear archivos CSS separados por componente.
- **Imports con alias:** `@` apunta a `./apps/`, `@packages` apunta a `./packages/`.
- **No usar `alert()`, `confirm()`, ni `prompt()` del navegador.** Usar Toasts o modales React.
- **Nombres de archivos:** PascalCase para componentes (`.jsx`), camelCase para hooks y servicios (`.js`).
- **API calls:** Siempre usar `window.location.hostname` para construir URLs del backend. **Nunca hardcodear IPs** (ni `localhost`, ni `192.168.x.x`).
- **Timestamps:** El backend almacena en UTC. El frontend convierte a hora local para mostrar. Nunca manipular zonas horarias en el backend.

---

### 1.5 DISCIPLINA DE REPOSITORIO

- **No subir archivos que no sean código fuente al repositorio.** Nada de `.sql`, `.csv`, `.xls`, `.docx`, `.json` de datos, ni respaldos de base de datos.
- **No crear carpetas temporales** (`tmp/`, `test/`, `scratch/`, `old/`).
- **No dejar archivos autogenerados** (como `vite.config.js.timestamp-*.mjs`).
- **Cada commit debe tener un propósito claro.** No commits tipo "asdf", "fix", "test", "WIP".
- **La carpeta `ESPECIFICACIONES DEL PROYECTO/` es exclusiva para documentación maestra oficial.** No meter ahí borradores, notas personales ni documentos obsoletos.

---

### 1.6 DEFENSA EN PROFUNDIDAD (SEGURIDAD)

Todo mecanismo de seguridad debe implementarse en **múltiples capas**. Nunca confiar en una sola:

1. **Capa UI:** El frontend oculta o deshabilita botones/módulos según permisos del usuario.
2. **Capa de Lógica Frontend:** Validaciones antes de enviar al backend.
3. **Capa Backend:** El servidor valida permisos, roles y reglas de negocio **independientemente** de lo que diga el frontend.
4. **Capa de Base de Datos:** Constraints, foreign keys e integridad referencial como última línea de defensa. Si un `DELETE` viola integridad, el backend debe manejar el error con gracia (por ejemplo, soft-delete).

**Nunca asumir que "el frontend ya lo validó".** El backend debe ser capaz de rechazar cualquier petición inválida por sí mismo.

---

### 1.7 PROCESO DE TRABAJO OBLIGATORIO

1. **Leer antes de actuar.** Antes de tocar cualquier módulo, lee este documento y la documentación específica del módulo si existe.
2. **Preguntar antes de asumir.** Si algo no está claro, pregunta. No inventes interpretaciones.
3. **Un cambio a la vez.** Implementar, verificar, confirmar. Luego el siguiente.
4. **Documentar lo importante.** Si resuelves un bug crítico o cambias arquitectura, actualiza la documentación correspondiente.
5. **Limpiar después de ti.** No dejes archivos temporales, código muerto, ni imports sin usar.
6. **Respetar lo que ya funciona.** Si un módulo está en producción y funciona, no lo "mejores" sin razón. "Si no está roto, no lo arregles."

---

## 2. ARQUITECTURA DEL SISTEMA

### 2.1 Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| **Frontend** | React 18 + Vite 4 + TailwindCSS 3 |
| **Backend** | Python FastAPI + Uvicorn |
| **Base de Datos** | PostgreSQL 15 (Alpine) |
| **ORM** | SQLAlchemy (async con asyncpg) |
| **Contenedores** | Docker + Docker Compose |
| **IA (Visión)** | Google Generative AI (`@google/generative-ai`) |
| **Iconografía** | Lucide React |

### 2.2 Infraestructura

- **Servidor:** PC Windows con IP fija `192.168.1.117` en red local.
- **Proyecto instalado en:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO\`
- **Datos persistentes en:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO-DATA\` (imágenes, configuración de terminales, volúmenes PostgreSQL).

### 2.3 Contenedores Docker

| Contenedor | Puerto Externo → Interno | Función |
|------------|--------------------------|---------|
| `rderico-pos-dev` | 5000 → 3000 | Frontend React (Vite dev server) |
| `rderico-api-dev` | 5001 → 3001 | Backend FastAPI (Uvicorn) |
| `rderico-db-dev` | 5433 → 5432 | PostgreSQL |

> **CRÍTICO:** Los archivos `.jsx` están montados como volumen bind en Docker. Esto significa que cualquier cambio se refleja en vivo en TODAS las terminales conectadas. Es una ventaja para desarrollo y un riesgo enorme si se introduce un error.

### 2.4 Acceso desde Terminales

- **Frontend (tablets/PCs):** `http://192.168.1.117:5000`
- **API:** `http://192.168.1.117:5001`
- **Archivos estáticos (imágenes):** `http://192.168.1.117:5001/static/images/`

---

## 3. MÓDULOS DEL SISTEMA

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

## 4. MODELO DE SEGURIDAD

- **Empleados** (`Employee`) con roles: `ADMIN`, `MANAGER`, `CASHIER`, `BAKER`, `WAITER`, `DRIVER`, `LOGISTICS`.
- **Perfiles de Seguridad** (`SecurityProfile`) con permisos granulares por módulo.
- **Validación siempre dual:** Frontend oculta lo no autorizado, backend rechaza lo no autorizado. Ambas capas son obligatorias.
- **Permisos especiales POS:** `pos_force_unlock` y `pos_force_cash_unlock` para desbloqueo forzado de terminales.

---

## 5. COMANDOS ESENCIALES

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

## 6. DOCUMENTOS DE REFERENCIA

Todos los documentos maestros viven en la carpeta `ESPECIFICACIONES DEL PROYECTO/`:

| Documento | Propósito |
|-----------|-----------|
| **`CONTEXTO_SISTEMA_IA.md`** (este) | Reglas de programación, arquitectura, disciplina de trabajo. Lectura obligatoria universal. |
| **`DOCUMENTACION_MODULO_POS.md`** | Especificación completa del Punto de Venta IA. Lógica, bugs históricos resueltos, reglas inquebrantables. **Lectura obligatoria antes de tocar el POS.** |
| **`DOCUMENTACION_MODULO_GESTION_PRODUCTOS.md`** | Especificación del módulo de Gestión de Productos. Lógica de eliminación, capas de seguridad, categorías. |

---

*Este documento es ley. Cualquier agente de IA que trabaje en este proyecto debe leerlo antes de escribir su primera línea de código. La calidad no es opcional.*
