# Solución Integral: Reparación de Base de Datos y Actualización a POS v6.1

Este plan detalla los pasos para resolver el problema de la tabla faltante (que causaba un bucle de reinicios y sobrecalentamiento) y aprovechar el reinicio del sistema para aplicar oficialmente las mejoras de resiliencia del POS descargadas de la nube.

## 1. Reparación de la Falla Raíz (Tabla Faltante)
1. **El Problema:** El modelo `ProductTechnicalSheet` nunca se importaba en el archivo principal (`main.py`). El script secundario de migración fallaba al no encontrar la tabla, tirando el contenedor y causando un bucle infinito de reinicios que saturaba el CPU.
2. **La Solución:** 
   - Modificar `apps/api/main.py` para importar los modelos faltantes, permitiendo que la base de datos auto-cree la tabla correctamente en el arranque.
   - Modificar `apps/api/migrate_technical_sheets.py` para que valide la existencia de la tabla antes de intentar alterarla, asegurando que si falla, lo haga silenciosamente sin tirar el servidor.

## 2. Aplicación de Actualizaciones POS v6.1 (Pendientes en el Servidor)
El servidor físico estaba operando con código desactualizado. Acabamos de descargar (pull) el código validado en mayo que incluye:
- **Persistencia atómica inmediata de tickets** (modelo SISYTEC, elimina el viejo guardado en lotes).
- Migración de columnas financieras de FLOAT a DECIMAL(12,2) para máxima precisión contable.
- Corrección de bugs de concurrencia en la base de datos (MissingGreenlet).
- Scripts para forzar IPs estáticas y prevenir nuevos choques de red.

**Acción a tomar:** Al reiniciar los contenedores para el Paso 1, el servidor de Docker automáticamente adoptará este nuevo código fuente, implementando la arquitectura v6.1 en tiempo real.

## Proposed Changes

### Componente: Backend API

#### [MODIFY] `apps/api/main.py`
- Agregar la importación de `Product` y `ProductTechnicalSheet` desde `modules.catalog.models` en la sección de "Importar TODOS los modelos". 

#### [MODIFY] `apps/api/migrate_technical_sheets.py`
- Incorporar un `SELECT` a `information_schema.tables` previo al `ALTER TABLE` para evitar excepciones fatales y abortar limpiamente si la tabla no está lista.

### Componente: Infraestructura (Docker)
- No hay código nuevo que escribir aquí, pero el plan asume el reinicio obligatorio de los contenedores (`rderico-api-dev` y `rderico-pos-dev`) para que tanto la tabla como el POS v6.1 entren en vigor.

## Verification Plan

### Manual Verification
1. Aplicar las modificaciones a los scripts de Python.
2. Ejecutar el reinicio del backend y el POS (`docker restart rderico-api-dev rderico-pos-dev`).
3. Verificar los registros (`docker logs rderico-api-dev`) para confirmar que el sistema de *auto-seed* detectó y creó la tabla `product_technical_sheets` sin errores en el arranque.
4. En las terminales físicas, verificar que desaparezca el mensaje de error de conexión tras el reinicio de 5 segundos, y confirmar que las ventas proceden normalmente con persistencia inmediata.
