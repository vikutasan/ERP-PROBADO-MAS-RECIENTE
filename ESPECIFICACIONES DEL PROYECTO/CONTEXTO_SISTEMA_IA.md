# 🏗️ ERP R DE RICO — CONTEXTO GLOBAL DEL SISTEMA PARA IAs

> **LECTURA OBLIGATORIA.** Este documento es la fuente de verdad para cualquier IA, desarrollador o auditor que trabaje en este proyecto. Contiene la arquitectura, las reglas de desarrollo, las directrices de calidad y la configuración de infraestructura del sistema ERP de la empresa **R de Rico** (panadería artesanal/industrial con sede en Toluca, México).
>
> **Última actualización:** 2026-06-09
> **Versión del sistema:** 1.2.1
> **Repositorio:** https://github.com/vikutasan/ERP-R-DE-RICO-CON-POS-SIMPLIFICADO

---

## 1. ¿QUÉ ES ESTE PROYECTO?

Un **sistema ERP integral** diseñado para una panadería que opera con múltiples puntos de venta (tablets), producción industrial, repartos mayoristas, logística de rutas y facturación. Fue construido iterativamente usando desarrollo asistido por IA (Antigravity / Claude / Gemini), lo cual le dio velocidad pero también exigió disciplina estricta para mantener la estabilidad.

### Módulos Activos

| Módulo | Archivo Principal | Estado |
|--------|------------------|--------|
| **Punto de Venta IA** | `apps/pos/RetailVisionPOS.jsx` | ✅ PRODUCCIÓN — **NO TOCAR** (ver `DOCUMENTACION_MODULO_POS.md`) |
| **TPV Mesas & KDS** | `apps/pos/TableServicePOS.jsx` | ✅ Producción |
| **Gestión de Productos** | `apps/inventory/` | ✅ Producción |
| **Gestión de Almacenes** | `apps/inventory/` (warehouse) | ✅ Producción |
| **Entrenamiento IA (Visión)** | `apps/pos/VisionTrainingUI.jsx` | ✅ Producción |
| **Gestión de la Producción** | `apps/production/` | ✅ Producción |
| **Gestión de Pickup** | `apps/production/` (pickup) | ✅ Producción |
| **Reparto Pan Grandeza** | `apps/pos/RepartoPanGrandezaUI.jsx` | ✅ Producción |
| **Módulo Financiero** | `apps/financials/` | ✅ Producción |
| **Estadísticas de Ventas** | `apps/analytics/` | ✅ Producción |
| **Facturación CFDI** | `apps/pos/` (invoicing) | ✅ Producción |
| **Gestión de Compras** | `apps/b2b/` | ✅ Producción |
| **Logística de Rutas** | `apps/logistics/` | ✅ Producción |
| **App Mesero** | `apps/waiter-app/` | ✅ Producción |
| **App Repartidor** | `apps/driver-app/` | ✅ Producción |
| **Seguridad y Acceso** | `apps/auth/` | ✅ Producción |
| **Auditoría y Control** | `apps/AuditoriaControlUI.jsx` | ✅ Producción |
| **Ajustes del Sistema** | `apps/settings/` | ✅ Producción |
| **Monitoreo de Red** | `apps/network/` | ✅ Producción |

---

## 2. ARQUITECTURA E INFRAESTRUCTURA

### Stack Tecnológico Real (Actual)

| Capa | Tecnología | Versión |
|------|-----------|---------|
| **Frontend** | React + Vite + TailwindCSS | React 18.2, Vite 4.4, Tailwind 3.3 |
| **Backend** | Python FastAPI + Uvicorn | Dentro de Docker |
| **Base de Datos** | PostgreSQL 15 (Alpine) | En Docker |
| **ORM** | SQLAlchemy (async con asyncpg) | — |
| **Contenedores** | Docker + Docker Compose | — |
| **IA** | Google Generative AI (@google/generative-ai) | ^0.24.1 |
| **Iconografía** | Lucide React | ^0.263.1 |

### Servidor Físico

- **Máquina:** PC Windows actuando como **servidor central**.
- **IP de red local:** `192.168.1.117`
- **Ruta de instalación del proyecto:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO\`
- **Ruta de datos persistentes:** `C:\Users\servidor1\.gemini\antigravity\scratch\ERP-R-DE-RICO-DATA\` (imágenes, catálogos, configuración de terminales, volúmenes de PostgreSQL).

### Contenedores Docker (docker-compose.yml)

| Contenedor | Imagen | Puerto Externo → Interno | Propósito |
|------------|--------|--------------------------|-----------|
| `rderico-pos-dev` | `erp-r-de-rico-pos` | **5000 → 3000** | Frontend React (Vite dev server) |
| `rderico-api-dev` | `erp-r-de-rico-api` | **5001 → 3001** | Backend FastAPI (Uvicorn) |
| `rderico-db-dev` | `postgres:15-alpine` | **5433 → 5432** | PostgreSQL |

> **IMPORTANTE:** El frontend corre con hot-reload dentro de Docker. Los archivos `.jsx` se montan como volumen bind (`- .:/app`), lo que significa que **cualquier cambio en el código fuente se refleja inmediatamente en TODAS las terminales conectadas**. Esto es una ventaja para desarrollo rápido, pero también un riesgo: **un error de sintaxis en cualquier archivo `.jsx` congela TODAS las tablets de la panadería en tiempo real.**

### Acceso desde Terminales

- Las tablets y PCs de punto de venta acceden al sistema vía navegador web: `http://192.168.1.117:5000`
- La API se consume desde: `http://192.168.1.117:5001`
- **Archivos estáticos** (imágenes de productos, logos): `http://192.168.1.117:5001/static/images/`

### Respaldo

- **Repositorio Git:** https://github.com/vikutasan/ERP-R-DE-RICO-CON-POS-SIMPLIFICADO
- **Backups de BD:** Carpeta `database_backups/` y archivos `db_backup_*.sql` en la raíz.

---

## 3. ESTRUCTURA DEL PROYECTO (MONOREPO)

```
ERP-R-DE-RICO/
├── main.jsx                    # Entry point de React
├── index.html                  # Shell HTML
├── index.css                   # Estilos globales
├── vite.config.js              # Configuración de Vite
├── docker-compose.yml          # Orquestación de servicios
├── Dockerfile.dev              # Imagen del frontend
├── .env                        # Variables de entorno
├── package.json                # Dependencias (v1.2.1)
│
├── apps/
│   ├── ExperimentCenterUI.jsx  # HUB PRINCIPAL — Dashboard con sidebar y módulos
│   ├── AuditoriaControlUI.jsx  # Módulo de auditoría
│   ├── api/                    # Backend FastAPI (Python)
│   │   └── modules/
│   │       ├── pos/            # Lógica de POS (service.py, router.py, models.py, occupancy.py)
│   │       ├── cash/           # Sesiones de caja
│   │       ├── inventory/      # Inventario
│   │       └── ...
│   ├── pos/                    # Frontend del POS
│   │   ├── RetailVisionPOS.jsx # ⚠️ MÓDULO CRÍTICO — Punto de Venta IA
│   │   ├── hooks/              # useCart.js, useTerminalLocking.js (hooks críticos)
│   │   ├── services/           # POSService.js (HTTP client)
│   │   ├── components/         # CheckoutScreen.jsx, etc.
│   │   ├── OpenAccountsCorkboard.jsx  # Pizarrón de cuentas abiertas
│   │   ├── VisionScanner.jsx   # Escáner de visión IA
│   │   ├── TableServicePOS.jsx # POS de mesas
│   │   ├── RepartoPanGrandezaUI.jsx   # Landing del módulo Grandeza
│   │   ├── GrandezaParamsUI.jsx       # Parámetros de Grandeza
│   │   ├── GrandezaDailyUI.jsx        # Gestión diaria de Grandeza
│   │   └── GrandezaDriverUI.jsx       # App del repartidor de Grandeza
│   ├── analytics/              # Estadísticas
│   ├── auth/                   # Login y perfiles de seguridad
│   ├── b2b/                    # Compras B2B
│   ├── driver-app/             # App del repartidor general
│   ├── financials/             # Módulo financiero
│   ├── inventory/              # Gestión de productos y almacenes
│   ├── kds/                    # Kitchen Display System
│   ├── logistics/              # Logística de rutas
│   ├── network/                # Monitoreo de red
│   ├── production/             # Producción y pickup
│   ├── settings/               # Ajustes del sistema
│   ├── voice-agent/            # Agente de voz IA
│   └── waiter-app/             # App del mesero
│
├── packages/                   # Paquetes compartidos
├── public/                     # Assets estáticos (logo, favicon)
├── dist/                       # Build de producción (generado por `vite build`)
├── docs/                       # Documentación técnica
└── database_backups/           # Respaldos de BD
```

### Punto de Entrada

`main.jsx` → renderiza `<ExperimentCenterUI />` dentro de un `ErrorBoundary`. Este componente es el **Hub Central** que muestra la sidebar con todos los módulos y gestiona la navegación entre ellos.

---

## 4. REGLAS DE DESARROLLO — DIRECTRICES PARA IAs

### 🔴 REGLA SUPREMA: NO INTERRUMPIR LA OPERACIÓN

> **Esta panadería opera en tiempo real.** Hay cajeros usando el POS, repartidores cargando rutas, y producción planificando masas. Cualquier cambio que rompa la compilación de Vite congela TODAS las pantallas de TODAS las terminales simultáneamente. **Esto causa pérdidas económicas reales.**

**Protocolo obligatorio antes de cualquier cambio:**
1. Asegúrate de que el cambio compila (`npm run build` sin errores).
2. Si tocas un archivo `.jsx`, verifica la sintaxis JSX (etiquetas cerradas, llaves balanceadas).
3. **Nunca** hagas cambios experimentales directamente en archivos de producción sin plan.
4. Si cometes un error, corrígelo **inmediatamente** y verifica con `npm run build`.

### 🔴 MÓDULO POS: ZONA RESTRINGIDA

El módulo "Punto de Venta IA" (`RetailVisionPOS.jsx` y sus hooks/services asociados) es el corazón del negocio. **Está documentado exhaustivamente en `DOCUMENTACION_MODULO_POS.md`.** Reglas:

- **NO modificar** `RetailVisionPOS.jsx`, `useCart.js`, `useTerminalLocking.js`, `POSService.js`, `CheckoutScreen.jsx`, ni `OpenAccountsCorkboard.jsx` sin leer primero `DOCUMENTACION_MODULO_POS.md` completo.
- **NO modificar** `apps/api/modules/pos/service.py`, `occupancy.py`, `router.py`, ni `models.py` sin leer primero `DOCUMENTACION_MODULO_POS.md`.
- Cada uno de estos archivos tiene bugs históricos resueltos con soluciones específicas que **no deben revertirse**.

### 🟡 ESTÁNDARES DE CALIDAD VISUAL

El sistema emplea una estética **premium y oscura**. No se aceptan diseños genéricos ni minimalistas:

- **Paleta base:** Negro profundo (`#050505`, `#0a0a0a`), acentos en naranja (`orange-500/600`) para R de Rico, dorado/ámbar (`amber-400/500`) para Grandeza.
- **Tipografía:** `font-black`, `uppercase`, `tracking-tighter` o `tracking-widest` según contexto.
- **Bordes:** Redondeados agresivamente (`rounded-2xl`, `rounded-[24px]`, `rounded-[30px]`).
- **Efectos:** Glassmorphism (`backdrop-blur`), sombras profundas (`shadow-2xl`), gradientes sutiles.
- **Animaciones:** Transiciones suaves (`transition-all`), hovers interactivos.
- **Módulo Grandeza:** Tiene su propia estética con fondo de textura de madera (`backgroundColor: '#3a2e1e'` + imagen de madera) y logo propio.

### 🟡 ESTÁNDARES DE CÓDIGO

- **React 18** con hooks. No usar class components (excepto `ErrorBoundary`).
- **TailwindCSS 3** para estilos. Utility-first. No crear archivos CSS separados por componente.
- **Imports con alias:** `@` apunta a `./apps/`, `@packages` apunta a `./packages/`.
- **No usar `alert()`, `confirm()`, ni `prompt()`** — usar Toasts o modales React.
- **Nombres de archivos:** PascalCase para componentes (`RetailVisionPOS.jsx`), camelCase para hooks (`useCart.js`), camelCase para servicios (`POSService.js`).
- **API calls:** Usar la IP dinámica `window.location.hostname` para URLs del backend, nunca hardcodear IPs.

### 🟡 PROCESO DE TRABAJO RECOMENDADO

1. **Antes de tocar código:** Entender el módulo afectado. Leer este documento y, si aplica, `DOCUMENTACION_MODULO_POS.md`.
2. **Hacer cambios incrementales:** Cambios pequeños y verificables. No refactorizaciones masivas.
3. **Verificar compilación:** `npm run build` después de cada cambio significativo.
4. **No crear archivos basura:** No dejar scripts temporales, archivos de test sueltos, ni documentos de prompts en la raíz.
5. **Documentar cambios significativos:** Si se resuelve un bug importante o se cambia arquitectura, actualizar el documento maestro correspondiente.

---

## 5. MÓDULO DE SEGURIDAD Y ACCESO

El sistema usa un esquema de autenticación propio con:

- **Empleados** (`Employee`) con roles: `ADMIN`, `MANAGER`, `CASHIER`, `BAKER`, `WAITER`, `DRIVER`, `LOGISTICS`.
- **Perfiles de Seguridad** (`SecurityProfile`) con permisos granulares por módulo.
- **Validación dual:** El frontend oculta módulos no autorizados, pero el backend **también valida permisos** en cada endpoint crítico.
- **Permisos especiales del POS:** `pos_force_unlock` y `pos_force_cash_unlock` para desbloqueo forzado de terminales.

---

## 6. MÓDULO REPARTO PAN GRANDEZA

Es un sub-sistema dentro del ERP diseñado para la distribución mayorista del producto "Pan Grandeza". Tiene su propia estética visual (madera, logo propio, colores ámbar/dorado) y se compone de:

- **Landing:** `RepartoPanGrandezaUI.jsx` — Página principal con 3 sub-módulos.
- **Parámetros Generales:** `GrandezaParamsUI.jsx` — Catálogo de productos, clientes y rutas.
- **Gestión Diaria:** `GrandezaDailyUI.jsx` — Jornadas diarias, carga de pedidos, cierre.
- **Herramienta del Repartidor:** `GrandezaDriverUI.jsx` — App móvil para el chofer.

Todos usan encabezado compacto negro con el logo real de Grandeza, consistente con la landing.

---

## 7. AGENTE DE IA (COACH DE PRODUCCIÓN)

El módulo de producción incluye un agente de voz IA que guía a los operarios:

- **Parámetros globales** almacenados en `SystemSetting` (palabras clave: "VOY", "LISTO", "PAUSA").
- **Nunca hardcodear** estas palabras en el código; siempre leerlas del backend.
- **Protocolo de voz:** Detección → Validación → Doble confirmación → Bucle de pausa.

---

## 8. COMANDOS ESENCIALES

```bash
# Levantar todos los servicios
docker-compose up -d

# Ver logs del frontend
docker logs -f rderico-pos-dev

# Ver logs del API
docker logs -f rderico-api-dev

# Compilar para verificar errores
npm run build

# Desarrollo local (fuera de Docker)
npm run dev

# Respaldo de base de datos
docker exec rderico-db-dev pg_dump -U user rderico > db_backup_$(date +%F).sql

# Reiniciar un contenedor específico
docker restart rderico-pos-dev
```

---

## 9. DOCUMENTOS DE REFERENCIA

| Documento | Propósito |
|-----------|-----------|
| **`CONTEXTO_SISTEMA_IA.md`** (este archivo) | Prompt global para cualquier IA. Arquitectura, reglas, infraestructura. |
| **`DOCUMENTACION_MODULO_POS.md`** | Biblia del Punto de Venta IA. Lógica, bugs resueltos, reglas inquebrantables. **LECTURA OBLIGATORIA** antes de tocar el POS. |

---

*Este documento es la fuente de verdad definitiva para el proyecto ERP R de Rico. Si algún otro documento o prompt contradice lo aquí especificado, este documento prevalece.*
