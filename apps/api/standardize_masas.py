import asyncio
import sys
import os
import json

# Añadir el directorio actual al path para importar módulos locales
sys.path.append(os.getcwd())

from core.database import AsyncSessionLocal
from modules.production.models import Dough
from modules.catalog.models import Product, Category, ProductTechnicalSheet
from sqlalchemy import select

async def standardize_dough_processes():
    async with AsyncSessionLocal() as db:
        # 1. Obtener la Masa 15 como modelo (ID 1 según inspección previa)
        res_model = await db.execute(select(Dough).where(Dough.id == 1))
        model_dough = res_model.scalar_one_or_none()
        
        if not model_dough:
            print("Error: No se encontró la Masa 15 (ID 1) para usar como modelo.")
            return

        model_process = model_dough.production_process
        if not model_process or len(model_process) == 0:
            print("Error: El proceso de la Masa 15 está vacío.")
            return
            
        model_substep = model_process[0]['subpasos'][0]
        
        # 2. Obtener todas las masas
        res_all = await db.execute(select(Dough))
        all_doughs = res_all.scalars().all()
        
        print(f"Iniciando estandarización de {len(all_doughs)} masas...")

        for dough in all_doughs:
            # Si no tiene proceso, inicializamos uno
            if not dough.production_process:
                dough.production_process = []
            
            # Asegurar que existe al menos el primer paso
            if len(dough.production_process) == 0:
                dough.production_process.append({
                    "id": "1",
                    "nombre": "",
                    "idBloque": "",
                    "subpasos": []
                })
            
            # 1. Estandarizar nombre del Paso 1
            dough.production_process[0]['nombre'] = f"IDENTIFICAR EL MEP DE {dough.name.upper()}"
            
            # Asegurar que existe el primer subpaso
            if len(dough.production_process[0]['subpasos']) == 0:
                dough.production_process[0]['subpasos'].append({})
            
            # 2. Estandarizar Subpaso 1
            # Copiamos la configuración del modelo
            new_substep = model_substep.copy()
            
            # Personalizamos el nombre de la masa en la instrucción de voz
            new_substep['instruccionVoz'] = f"Revisa la orden. ¿Cuántas preparaciones de {dough.name.upper()} harás hoy?"
            
            # 3. Trigger de inicio (A consideración de la IA para todas excepto Masa 15)
            if dough.id != 1:
                new_substep['triggerInicio'] = "ia_coach_decision"
            else:
                new_substep['triggerInicio'] = "inicio_turno"
            
            # 4. Dependencia (NINGUNO para todas)
            new_substep['dependenciaPasoPrevio'] = ""

            # Actualizamos el subpaso en el proceso
            dough.production_process[0]['subpasos'][0] = new_substep
            
            # Forzar detección de cambio en el campo JSON (opcional en algunas versiones pero seguro)
            # dough.production_process = list(dough.production_process) 
            
            print(f" - Actualizada: {dough.name}")

        # 3. Guardar cambios
        try:
            # Marcamos el atributo como modificado explícitamente para SQLAlchemy
            from sqlalchemy.orm.attributes import flag_modified
            for dough in all_doughs:
                flag_modified(dough, "production_process")
                
            await db.commit()
            print("\n¡Estandarización completada con éxito!")
        except Exception as e:
            await db.rollback()
            print(f"\nError al guardar cambios: {e}")

if __name__ == "__main__":
    asyncio.run(standardize_dough_processes())
