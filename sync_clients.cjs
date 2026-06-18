const fs = require('fs');
const http = require('http');

const API_BASE = 'http://192.168.1.117:5001/api/v1/grandeza/clients';

function normalize(str) {
    if (!str) return '';
    return str.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").trim();
}

function fetchApi(url, options = {}) {
    return new Promise((resolve, reject) => {
        const req = http.request(url, options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        resolve(data ? JSON.parse(data) : null);
                    } else {
                        reject(`HTTP ${res.statusCode}: ${data}`);
                    }
                } catch (e) {
                    reject(e);
                }
            });
        });
        req.on('error', reject);
        if (options.body) {
            req.write(options.body);
        }
        req.end();
    });
}

async function run() {
    const extractedData = JSON.parse(fs.readFileSync('extracted_clients.json', 'utf8').replace(/^\uFEFF/, ''));
    console.log(`Leidos ${extractedData.length} clientes del archivo.`);

    const existingClients = await fetchApi(API_BASE);
    console.log(`Leidos ${existingClients.length} clientes de la base de datos.`);

    for (const client of extractedData) {
        const normName = normalize(client.nombre);
        
        // Find match
        let match = null;
        for (const ec of existingClients) {
            const ecName = normalize(ec.name);
            // Si el primer nombre coincide, o uno contiene al otro
            const firstExt = normName.split(' ')[0];
            const firstDb = ecName.split(' ')[0];
            
            if (normName === ecName || ecName.includes(normName) || normName.includes(ecName) || (firstExt === firstDb && firstExt.length > 2)) {
                match = ec;
                break;
            }
        }

        const payload = {
            name: match ? match.name : client.nombre, // keep existing name if matched, or use new
            business_name: client.negocio || match?.business_name || null,
            phone: client.telefono || match?.phone || null,
            address: client.direccion || match?.address || null,
            google_maps_url: client.google_maps_url || match?.google_maps_url || null
        };

        if (match) {
            console.log(`[UPDATE] ${match.name} (Matched with ${client.nombre})`);
            await fetchApi(`${API_BASE}/${match.id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
        } else {
            console.log(`[CREATE] ${client.nombre}`);
            await fetchApi(API_BASE, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
        }
    }
    console.log('Finalizado.');
}

run().catch(console.error);
