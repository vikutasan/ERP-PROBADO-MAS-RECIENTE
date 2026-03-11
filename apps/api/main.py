from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from modules.catalog.router import router as catalog_router
from modules.pos.router import router as pos_router

app = FastAPI(
    title="R de Rico ERP API",
    description="Backend Monolito Modular para ERP",
    version="1.0.0"
)

# Configurar CORS (Permitir requests desde React)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # En producción se debe restringir a los dominios correctos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "ok", "version": "1.0.0"}

app.include_router(catalog_router, prefix="/api/v1/catalog", tags=["Catalog"])
app.include_router(pos_router, prefix="/api/v1/pos", tags=["POS"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=3001, reload=True)
