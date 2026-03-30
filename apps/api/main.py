from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from modules.catalog.router import router as catalog_router
from modules.pos.router import router as pos_router
from modules.security.router import router as security_router
from modules.cash.router import router as cash_router
from modules.settings.router import router as settings_router
from modules.production.router import router as production_router
from core.database import AsyncSessionLocal, engine, Base
from modules.catalog.models import Category
from modules.security.models import SecurityProfile, Employee
from sqlalchemy import select

# Importar TODOS los modelos para que Base.metadata los conozca
from modules.pos.models import Ticket, TerminalSession
from modules.cash.models import CashSession, CashMovement
from modules.settings.models import SystemSetting
from modules.production.models import Dough, DoughBatchConfig, DoughIngredient, DoughProcedureStep, DoughProductRelation

app = FastAPI(
    title="R de Rico ERP API",
    description="Backend Monolito Modular para ERP",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# AUTO-SEED: Crear tablas + usuario admin en primera ejecución
# ---------------------------------------------------------------------------
@app.on_event("startup")
async def auto_seed_on_first_boot():
    """
    Detecta si la base de datos está vacía (instalación nueva) y:
    1. Crea todas las tablas (idempotente - no toca las existentes).
    2. Siembra los 3 perfiles de seguridad base.
    3. Crea el usuario ADMINISTRADOR de emergencia (código 1111).
    Seguro para ejecutarse en cada reinicio - no duplica ni sobreescribe datos.
    """
    try:
        # Paso 1: Crear tablas que no existan (idempotente)
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("✅ Tablas verificadas/creadas.")

        async with AsyncSessionLocal() as session:
            # Paso 2: Sembrar perfiles de seguridad base
            perfiles_base = [
                {
                    "name": "ADMIN",
                    "description": "Acceso total al sistema",
                    "permissions": {
                        "overview": "full", "pos_retail": "full", "inventory": "full",
                        "warehouse": "full", "vision_train": "full", "production": "full",
                        "financials": "full", "invoicing": "full", "purchasing": "full",
                        "procurement": "full", "logistics": "full", "pos_tables": "full",
                        "waiter": "full", "driver": "full", "seguridad_acceso": "full",
                        "auditoria": "full"
                    },
                    "is_system": True
                },
                {
                    "name": "MANAGER",
                    "description": "Gestión operativa",
                    "permissions": {
                        "overview": "full", "pos_retail": "full", "inventory": "full",
                        "warehouse": "full", "vision_train": "full", "production": "full",
                        "financials": "read", "invoicing": "full", "purchasing": "full",
                        "logistics": "full", "seguridad_acceso": "read"
                    },
                    "is_system": True
                },
                {
                    "name": "CAJERO",
                    "description": "Operación de ventas",
                    "permissions": {
                        "overview": "full", "pos_retail": "full", "invoicing": "limited"
                    },
                    "is_system": True
                },
            ]

            admin_profile_id = None
            for p_data in perfiles_base:
                res = await session.execute(
                    select(SecurityProfile).where(SecurityProfile.name == p_data["name"])
                )
                perfil = res.scalar_one_or_none()
                if not perfil:
                    perfil = SecurityProfile(**p_data)
                    session.add(perfil)
                    await session.flush()
                    print(f"   Perfil '{p_data['name']}' creado.")
                if p_data["name"] == "ADMIN":
                    admin_profile_id = perfil.id

            # Paso 3: Crear usuario administrador de emergencia (1111)
            res = await session.execute(
                select(Employee).where(Employee.employee_code == "1111")
            )
            admin_user = res.scalar_one_or_none()

            if not admin_user:
                admin_user = Employee(
                    name="ADMINISTRADOR",
                    employee_code="1111",
                    role="ADMIN",
                    profile_id=admin_profile_id,
                    is_active=True
                )
                session.add(admin_user)
                print("⚡ Primera ejecución detectada. Usuario ADMIN '1111' creado.")

            await session.commit()
            print("✅ Seed de seguridad verificado.")

    except Exception as e:
        print(f"❌ Error en auto-seed: {e}")

# ---------------------------------------------------------------------------
# Asegurar categorías de sistema
# ---------------------------------------------------------------------------
@app.on_event("startup")
async def ensure_system_categories():
    """Asegura que la categoría 'DESCONTINUADOS' exista como categoría de sistema."""
    async with AsyncSessionLocal() as db:
        try:
            stmt = select(Category).where(Category.name == "DESCONTINUADOS")
            result = await db.execute(stmt)
            category = result.scalar_one_or_none()

            if not category:
                new_cat = Category(
                    name="DESCONTINUADOS",
                    icon="🗑️",
                    position=999,
                    vision_enabled=False,
                    is_system=True
                )
                db.add(new_cat)
                await db.commit()
                print("Categoría 'DESCONTINUADOS' creada como sistema.")
            else:
                if not category.is_system:
                    category.is_system = True
                    category.vision_enabled = False
                    await db.commit()
                    print("Categoría 'DESCONTINUADOS' actualizada como sistema.")
        except Exception as e:
            print(f"Error asegurando categorías de sistema: {e}")
            await db.rollback()

@app.get("/health")
async def health_check():
    return {"status": "ok", "version": "1.0.0"}

app.include_router(catalog_router, prefix="/api/v1/catalog", tags=["Catalog"])
app.include_router(pos_router, prefix="/api/v1/pos", tags=["POS"])
app.include_router(security_router, prefix="/api/v1/security", tags=["Security"])
app.include_router(cash_router, prefix="/api/v1/cash", tags=["Cash"])
app.include_router(settings_router, prefix="/api/v1/settings", tags=["Settings"])
app.include_router(production_router, prefix="/api/v1/production", tags=["Production"])

# Montar carpetas de archivos estáticos
app.mount("/static/catalog", StaticFiles(directory="static/catalog"), name="catalog")
app.mount("/static/images", StaticFiles(directory="static/images"), name="images")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=3001, reload=True)
