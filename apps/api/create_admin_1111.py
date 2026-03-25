import asyncio
from core.database import AsyncSessionLocal, engine
from modules.security.models import SecurityProfile, Employee
from sqlalchemy import select

async def create_admin():
    print("Inyectando Administrador de Emergencia (1111)...")
    async with AsyncSessionLocal() as session:
        # 1. Asegurar perfil ADMIN
        res = await session.execute(select(SecurityProfile).where(SecurityProfile.name == "ADMIN"))
        admin_profile = res.scalar_one_or_none()
        
        if not admin_profile:
            admin_profile = SecurityProfile(
                name="ADMIN",
                description="Acceso total",
                permissions={"overview": "full", "inventory": "full", "pos_retail": "full", "seguridad_acceso": "full"},
                is_system=True
            )
            session.add(admin_profile)
            await session.flush()
        
        # 2. Asegurar empleado 1111
        res = await session.execute(select(Employee).where(Employee.employee_code == "1111"))
        admin_user = res.scalar_one_or_none()
        
        if not admin_user:
            admin_user = Employee(
                name="ADMINISTRADOR",
                employee_code="1111",
                role="ADMIN",
                profile_id=admin_profile.id,
                is_active=True
            )
            session.add(admin_user)
            print("Usuario 1111 creado exitosamente.")
        else:
            admin_user.profile_id = admin_profile.id
            admin_user.role = "ADMIN"
            print("Usuario 1111 actualizado con perfil ADMIN.")
            
        await session.commit()
    print("Proceso finalizado.")

if __name__ == "__main__":
    asyncio.run(create_admin())
