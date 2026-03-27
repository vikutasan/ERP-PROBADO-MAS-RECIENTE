import pandas as pd
import json
import os

def extract_excel():
    path = r"C:\Users\Pollo\Downloads\MASAS PARA ANTIGRAVITY.xlsx"
    if not os.path.exists(path):
        print(f"ERROR: Archivo no encontrado en {path}")
        return
        
    try:
        xls = pd.ExcelFile(path)
        data = {}
        for sheet_name in xls.sheet_names:
            df = pd.read_excel(path, sheet_name=sheet_name)
            # Resumen legible para la IA
            data[sheet_name] = {
                "columnas": list(df.columns),
                "filas": df.head(10).to_dict(orient='records')
            }
        
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    extract_excel()
