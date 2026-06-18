import asyncio
import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'apps/api'))

from core.database import AsyncSessionLocal
from sqlalchemy import select
from modules.pos.models import Ticket
from modules.orders.models import Order
from modules.pos.service import POSService

async def test():
    async with AsyncSessionLocal() as db:
        # Check if there are any PAID PEDIDOs
        result = await db.execute(
            select(Ticket).where(Ticket.order_type == "PEDIDO", Ticket.status == "PAID")
        )
        tickets = result.scalars().all()
        print(f"Found {len(tickets)} paid pedidos.")
        
        for t in tickets:
            print(f"Ticket {t.id} - {t.account_num}: order_type={t.order_type}, status={t.status}")
            
        # Check if there are any Orders
        result_orders = await db.execute(select(Order))
        orders = result_orders.scalars().all()
        print(f"Found {len(orders)} orders.")
        
        for o in orders:
            print(f"Order {o.id} - ticket_id={o.ticket_id}")

if __name__ == "__main__":
    asyncio.run(test())
