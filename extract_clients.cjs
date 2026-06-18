const XLSX = require('xlsx');
const path = require('path');

const filePath = path.join('C:\\Users\\servidor1\\Downloads', 'ENERO 2026.xlsx');
const wb = XLSX.readFile(filePath);

const clients = {};

for (const sheetName of ['MARTES ', 'MIERCOLES', 'JUEVES', 'SABADO']) {
    if (!wb.Sheets[sheetName]) continue;
    const ws = wb.Sheets[sheetName];
    const range = XLSX.utils.decode_range(ws['!ref'] || 'A1');
    
    const getCell = (r, c) => {
        const addr = XLSX.utils.encode_cell({r, c});
        const cell = ws[addr];
        return cell ? String(cell.v || '').trim() : '';
    };
    
    const getHyperlink = (r, c) => {
        const addr = XLSX.utils.encode_cell({r, c});
        const cell = ws[addr];
        if (cell && cell.l && cell.l.Target) return cell.l.Target;
        return null;
    };
    
    for (let row = 0; row <= range.e.r; row++) {
        const cellA = getCell(row, 0).toUpperCase();
        
        if (cellA.includes('CLIENTE') && /\d/.test(cellA)) {
            const data = { sheet: sheetName };
            
            // Collect values from the next ~20 rows
            let currentField = null;
            
            for (let offset = 1; offset <= 20 && (row + offset) <= range.e.r; offset++) {
                const r = row + offset;
                let valA = getCell(r, 0);
                const label = valA.toLowerCase();
                
                if (label.includes('cliente') && /\d/.test(label)) {
                    break; // Next client
                }
                
                if (label.includes('clave')) {
                    currentField = 'clave';
                } else if (label.includes('nombre')) {
                    currentField = 'nombre';
                } else if (label.includes('negocio')) {
                    currentField = 'negocio';
                } else if (label.includes('telefono') || label.includes('teléfono')) {
                    currentField = 'telefono';
                } else if (label.includes('direccion') || label.includes('dirección')) {
                    currentField = 'direccion';
                } else if (label.includes('ubicacion') || label.includes('ubicación')) {
                    currentField = 'ubicacion';
                    const link = getHyperlink(r, 0) || getHyperlink(r + 1, 0) || getHyperlink(r + 2, 0);
                    if (link) data.google_maps_url = link;
                } else if (valA) {
                    // This is a value for the current field
                    if (currentField === 'nombre') {
                        data.nombre = data.nombre ? data.nombre + ' ' + valA : valA;
                    } else if (currentField === 'negocio') {
                        data.negocio = data.negocio ? data.negocio + ' ' + valA : valA;
                    } else if (currentField === 'telefono') {
                        data.telefono = data.telefono ? data.telefono + ' ' + valA : valA;
                    } else if (currentField === 'direccion') {
                        data.direccion = data.direccion ? data.direccion + ' ' + valA : valA;
                    }
                }
            }
            
            if (data.nombre) {
                // cleanup
                data.nombre = data.nombre.replace(/\s+/g, ' ').trim();
                if (data.negocio) data.negocio = data.negocio.replace(/\s+/g, ' ').trim();
                if (data.direccion) data.direccion = data.direccion.replace(/\s+/g, ' ').trim();
                
                const key = data.nombre.toUpperCase();
                const existing = clients[key];
                const newScore = [data.negocio, data.telefono, data.direccion, data.google_maps_url].filter(Boolean).length;
                const oldScore = existing ? [existing.negocio, existing.telefono, existing.direccion, existing.google_maps_url].filter(Boolean).length : -1;
                
                if (newScore > oldScore) {
                    clients[key] = data;
                }
            }
        }
    }
}

const sorted = Object.values(clients);
console.log(JSON.stringify(sorted, null, 2));
