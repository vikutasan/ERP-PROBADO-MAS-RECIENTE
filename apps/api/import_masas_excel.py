import asyncio
import pandas as pd
import json
from core.database import AsyncSessionLocal, engine
from modules.production.models import Dough, DoughIngredient, DoughProcedureStep, DoughProductRelation, DoughRelation, DoughBatchConfig
from modules.catalog.models import Product

async def import_masas():
    print("Iniciando importación desde Excel...")
    
    # 1. Cargar hojas
    file_path = 'temp_gestor.xlsx'
    xl = pd.ExcelFile(file_path)
    
    # RESUMEN tiene headers en row 1
    df_resumen = xl.parse('RESUMEN POR MASA', header=1)
    # PASOS tiene headers en row 2
    df_pasos = xl.parse('PASOS Y SUBPASOS', header=2)
    
    # Limpiar nombres de columnas
    df_resumen.columns = [str(c).strip() for c in df_resumen.columns]
    df_pasos.columns = [str(c).strip() for c in df_pasos.columns]

    # CORRECCIÓN 1: Ignorar filas de metadatos de tipo de dato (VARCHAR, etc)
    df_resumen = df_resumen[~df_resumen['ID_Masa'].astype(str).str.contains('VARCHAR', na=False)]
    df_pasos = df_pasos[~df_pasos['ID_Masa'].astype(str).str.contains('VARCHAR', na=False)]

    # CORRECCIÓN 2: Forward fill para celdas combinadas (NaNs)
    cols_to_ffill = ['ID_Masa', 'ID_Paso', 'Paso_Nombre', 'ID_Bloque']
    df_pasos[cols_to_ffill] = df_pasos[cols_to_ffill].ffill()

    async with AsyncSessionLocal() as db:
        try:
            codes_procesados = set()
            # Iterar sobre las masas del resumen
            for _, row_masa in df_resumen.iterrows():
                id_masa = str(row_masa['ID_Masa']).strip()
                if not id_masa or id_masa == 'nan' or id_masa in codes_procesados: continue
                
                codes_procesados.add(id_masa)
                
                nombre_masa = str(row_masa['Nombre completo']).strip()
                print(f"Procesando: {id_masa} - {nombre_masa}")
                
                # Filtrar pasos de esta masa
                pasos_raw = df_pasos[df_pasos['ID_Masa'] == id_masa]
                
                # Agrupar por ID_Paso
                pasos_dict = {}
                for _, row_p in pasos_raw.iterrows():
                    id_paso = str(row_p['ID_Paso']).strip()
                    if id_paso == 'nan': continue
                    
                    if id_paso not in pasos_dict:
                        pasos_dict[id_paso] = {
                            "id": len(pasos_dict) + 1,
                            "nombre": str(row_p['Paso_Nombre']).strip().upper(),
                            "idBloque": str(row_p['ID_Bloque']).strip().upper(),
                            "subpasos": []
                        }
                    
                    # Crear subpaso
                    t_humano = row_p['T_Humano']
                    t_autonomo = row_p['T_Autonomo']
                    
                    subpaso = {
                        "id": len(pasos_dict[id_paso]["subpasos"]) + 1,
                        "nombre": str(row_p['Subpaso_Nombre']).strip(),
                        "instruccionVoz": str(row_p['Instruccion_Voz']).strip(),
                        "tHumano": float(t_humano) if pd.notnull(t_humano) else 0.0,
                        "tAutonomo": float(t_autonomo) if pd.notnull(t_autonomo) else 0.0,
                        "recurso": str(row_p['ID_Recurso']).strip(),
                        "nivelCritico": str(row_p['Nivel_Critico']).strip().lower(),
                        "operarioLibre": str(row_p['Es_Atomico']).strip().upper() == 'FALSE',
                        "confirmacionVoz": str(row_p['Validacion_Voz']).strip().upper() == 'TRUE'
                    }
                    pasos_dict[id_paso]["subpasos"].append(subpaso)

                # Convertir a lista ordenada
                production_process = list(pasos_dict.values())
                
                # Crear objeto Dough
                new_dough = Dough(
                    code=id_masa,
                    name=nombre_masa,
                    dough_type="ESTÁNDAR",
                    theoretical_yield=0.0,
                    production_process=production_process
                )
                
                db.add(new_dough)
                
            await db.commit()
            print("Importación finalizada con éxito.")
            
        except Exception as e:
            print(f"Error durante la importación: {e}")
            import traceback
            traceback.print_exc()
            await db.rollback()

if __name__ == "__main__":
    asyncio.run(import_masas())
