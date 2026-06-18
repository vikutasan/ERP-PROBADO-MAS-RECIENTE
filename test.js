const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'apps/api/data.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error(err.message);
    return;
  }
  
  db.all(`SELECT * FROM tickets WHERE order_type = 'PEDIDO' AND status = 'PAID'`, [], (err, rows) => {
    if (err) throw err;
    console.log(`Found ${rows.length} paid pedidos.`);
    rows.forEach(r => console.log(`Ticket ${r.id} - ${r.account_num}`));
    
    db.all(`SELECT * FROM orders`, [], (err, orderRows) => {
      if (err) {
        console.log("No orders table?", err.message);
        return;
      }
      console.log(`Found ${orderRows.length} orders.`);
      orderRows.forEach(o => console.log(`Order ${o.id} - status: ${o.status}`));
    });
  });
});
