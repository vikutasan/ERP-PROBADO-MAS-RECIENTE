# 🏰 Protocolo de Despliegue: ERP R de Rico v4.7 (Imperial Edition)

Esta guía ha sido redactada para asistir a la IA de **Antigravity** en el proceso de instalación profesional del ecosistema ERP "R de Rico". El sistema es un ecosistema digital evolutivo basado en **React (Frontend)**, **FastAPI (Backend)** y **PostgreSQL**, orquestado mediante **Docker Compose**.

---

## 🛠️ Especificaciones Técnicas del Proyecto
- **Frontend**: Vite + React (Puerto 3000 por defecto).
- **Backend/API**: FastAPI + Uvicorn (Puerto 3001 por defecto).
- **Base de Datos**: PostgreSQL 15 (Puerto 5432).
- **Orquestación**: Docker Compose (Indispensable).

---

## 📋 Requisitos de la Estación (Servidor Maestro)
El Servidor Central actuará simultáneamente como **Host de API/DB** y como la **Terminal 6 (T6)**.

### 1. Limpieza de Versiones Previas
Antes de clonar desde GitHub, es **crítico** eliminar rastros de la versión antigua para evitar colisiones de contenedores y volúmenes:
- Detener contenedores: `docker-compose down`
- Eliminar volúmenes de datos antiguos (si no se desea migrar): `docker volume rm $(docker volume ls -q -f name=rderico)`
- Eliminar imágenes huérfanas: `docker image prune -a`

### 2. Coexistencia con ERP SaaS
El servidor ya hospeda un ERP SaaS. Para evitar conflictos:
- **Verificar Puertos**: Asegurarse de que los puertos `3000`, `3001` y `5432` no estén en uso por el SaaS. Si hay conflicto, modificar el archivo `docker-compose.yml` mapeando puertos libres (ej. `4000:80` para POS).

---

## 🚀 Pasos de Instalación (Para Antigravity AI)

### Paso 1: Clonación y Herencia
Clonar el repositorio público de GitHub.
```bash
git clone [URL_DEL_REPOSITORIO]
cd ERP-R-DE-RICO
```

### Paso 2: Configuración de Red Local (LAN) - CRÍTICO
Para que las otras 5 terminales (T2-T5 y CAJA) puedan conectarse, el frontend **no puede** apuntar a `localhost`.
1. Identificar la IP fija del servidor en la LAN (ej. `192.168.1.100`).
2. Modificar `apps/pos/config.js` (o variables de entorno):
   `API_BASE_URL: "http://192.168.1.100:3001/api/v1"`
3. Asegurarse de que el Firewall de Windows en el servidor permita tráfico entrante en los puertos `3000` y `3001`.

### Paso 3: Despliegue de Contenedores
Ejecutar la construcción imperial:
```bash
docker-compose up -d --build
```

---

## 🖥️ Configuración de Terminales (Estaciones Satélites)

### Distribución de Roles:
- **Terminal 6 (Servidor)**: Acceso vía `http://localhost:3000`
- **Terminales 2, 3, 4, 5 & CAJA**: Acceso desde sus respectivos navegadores vía `http://[IP_DEL_SERVIDOR]:3000`

### Configuración de la Estación "CAJA" (Impresora de 80mm):
1. **Hardware**: Instalar driver térmico en la PC física de la Caja.
2. **Terminal ID**: Al abrir el sistema, seleccionar específicamente el rol de **CAJA** en la pantalla de inicio.
3. **Optimización de Impresión**: 
   - Establecer la impresora térmica como **Predeterminada** en Windows.
   - Desactivar "Gestión automática de impresoras" por Windows.
   - Configurar el navegador (Chrome/Edge) con el flag `--kiosk-printing` para impresión directa sin diálogos.

### Plantillas de Ticket:
El sistema ya está configurado con la plantilla **Eco-Slim (v4.7)** para maximizar el ahorro de papel térmico de 80mm y mostrar la trazabilidad de captura/cobro.

---

## 🛡️ Verificación Final
Solicitar a Antigravity verificar:
1. Conectividad `ping` desde T2 hacia la IP del servidor.
2. Persistencia de datos en el volumen `pgdata`.
3. Carga correcta del **Catálogo de Imágenes** (mapeado en el volumen de `api`).

---
*R de Rico - Evolutive Digital Ecosystem | Master Installation Protocol v1.0*
