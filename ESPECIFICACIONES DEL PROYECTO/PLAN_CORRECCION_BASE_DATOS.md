# Solución a Falla de Base de Datos (Tabla Faltante)

Este plan detalla los pasos para resolver el problema que causa que el servidor colapse (crash loop) intentando acceder a una tabla inexistente.

## El Problema Raíz
1. El modelo `ProductTechnicalSheet` sí existe en el código (`models.py`), pero **nunca se importa en el archivo principal (`main.py`)**. Debido a esto, cuando el sistema arranca y verifica qué tablas faltan en la base de datos para crearlas automáticamente, ignora esta tabla.
2. Un script de migración secundario (`migrate_technical_sheets.py`) intenta forzosamente agregar columnas a esa tabla. Al no encontrar la tabla, el script arroja una excepción fatal, apagando el servidor backend.
3. Docker reinicia el servidor backend porque detecta el apagado, generando un bucle infinito que satura el CPU.

## Proposed Changes

### Componente: Backend API

#### [MODIFY] `apps/api/main.py`
- Agregar la importación de los modelos `Product` y `ProductTechnicalSheet` desde `modules.catalog.models` en la sección de "Importar TODOS los modelos". 
- Esto garantizará que la función `auto_seed_on_first_boot()` detecte la tabla y la cree limpiamente si no existe, evitando errores futuros.

#### [MODIFY] `apps/api/migrate_technical_sheets.py`
- Modificar la lógica para que, antes de intentar hacer el `ALTER TABLE` o cualquier modificación, ejecute un `SELECT` a `information_schema.tables` para validar si la tabla `product_technical_sheets` realmente existe.
- Si la tabla no existe, el script terminará de forma segura imprimiendo una advertencia, en lugar de lanzar una excepción fatal (`UndefinedTableError`). Esto rompe por completo la posibilidad de un ciclo infinito de reinicios (crash loop).

## Verification Plan

### Manual Verification
1. Reiniciar el contenedor de Docker de la API.
2. Verificar los registros (`docker logs rderico-api-dev`) para confirmar que la función de *auto-seed* ha detectado e inicializado la tabla correctamente sin errores.
3. Ejecutar el script `migrate_technical_sheets.py` manualmente y observar que corre de manera segura sin colapsar, confirmando que las restricciones de clave foránea y las columnas de gramos se aplican (o ya están creadas).
4. El servidor ya no deberá mostrar el error `asyncpg.exceptions.UndefinedTableError`.
