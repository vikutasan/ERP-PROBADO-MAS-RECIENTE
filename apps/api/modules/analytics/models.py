from sqlalchemy import Column, Integer, String, Boolean, Date, Float, Text
from datetime import date
from core.database import Base

class DailyContext(Base):
    __tablename__ = "daily_contexts"

    id = Column(Integer, primary_key=True, index=True)
    target_date = Column(Date, unique=True, index=True, nullable=False, default=date.today)
    is_atypical = Column(Boolean, default=False)
    weather_condition = Column(String, nullable=True) # EJ: SOLEADO, LLUVIA_FUERTE, TORMENTA, MUCHO_CALOR
    holiday_name = Column(String, nullable=True)
    notes = Column(Text, nullable=True)
    
    # Podríamos guardar también la temperatura en C si es relevante
    temperature_c = Column(Float, nullable=True)
