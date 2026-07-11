/**
 * MÓDULO: offlineStore.js
 * MISIÓN: Capa de persistencia local para el repartidor usando IndexedDB nativo.
 * 
 * Tres Object Stores:
 *   - cached_data: Snapshot de jornada, productos, clientes, inventario, ruta
 *   - sync_queue: Cola de operaciones HTTP pendientes (POST/PATCH que fallaron)
 *   - gps_buffer: Coordenadas GPS capturadas sin internet
 * 
 * REGLA: Este módulo NO importa React ni dependencias externas.
 */

const DB_NAME = 'grandeza_offline';
const DB_VERSION = 1;

// ─── Abrir / Crear la Base de Datos ──────────────────────────────────────────

function openDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        request.onerror = () => reject(request.error);
        request.onsuccess = () => resolve(request.result);
        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            if (!db.objectStoreNames.contains('cached_data')) {
                db.createObjectStore('cached_data', { keyPath: 'key' });
            }
            if (!db.objectStoreNames.contains('sync_queue')) {
                db.createObjectStore('sync_queue', { keyPath: 'id', autoIncrement: true });
            }
            if (!db.objectStoreNames.contains('gps_buffer')) {
                db.createObjectStore('gps_buffer', { keyPath: 'id', autoIncrement: true });
            }
        };
    });
}

// ─── Helpers genéricos ───────────────────────────────────────────────────────

async function putRecord(storeName, record) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readwrite');
        tx.objectStore(storeName).put(record);
        tx.oncomplete = () => { db.close(); resolve(); };
        tx.onerror = () => { db.close(); reject(tx.error); };
    });
}

async function getRecord(storeName, key) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readonly');
        const req = tx.objectStore(storeName).get(key);
        req.onsuccess = () => { db.close(); resolve(req.result || null); };
        req.onerror = () => { db.close(); reject(req.error); };
    });
}

async function getAllRecords(storeName) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readonly');
        const req = tx.objectStore(storeName).getAll();
        req.onsuccess = () => { db.close(); resolve(req.result || []); };
        req.onerror = () => { db.close(); reject(req.error); };
    });
}

async function deleteRecord(storeName, key) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readwrite');
        tx.objectStore(storeName).delete(key);
        tx.oncomplete = () => { db.close(); resolve(); };
        tx.onerror = () => { db.close(); reject(tx.error); };
    });
}

async function clearStore(storeName) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readwrite');
        tx.objectStore(storeName).clear();
        tx.oncomplete = () => { db.close(); resolve(); };
        tx.onerror = () => { db.close(); reject(tx.error); };
    });
}

// ─── Cache de Datos de Ruta ──────────────────────────────────────────────────

/**
 * Guardar snapshot completo de la jornada al cargar con internet.
 * Se llama una sola vez al inicio exitoso de loadAll().
 */
export async function cacheRouteData({ journey, products, clients, inventory, routeSlots, visits }) {
    await putRecord('cached_data', {
        key: 'full_route',
        journey,
        products,
        clients,
        inventory,
        routeSlots,
        visits: visits || [],
        cachedAt: Date.now(),
    });
}

/**
 * Leer el snapshot cacheado cuando no hay red.
 * Devuelve null si nunca se cacheó.
 */
export async function getCachedRouteData() {
    return await getRecord('cached_data', 'full_route');
}

/**
 * Actualizar solo las visitas en el caché local (tras guardar una visita offline).
 */
export async function updateCachedVisits(newVisit) {
    const cached = await getRecord('cached_data', 'full_route');
    if (!cached) return;
    cached.visits = [...(cached.visits || []), newVisit];
    await putRecord('cached_data', cached);
}

// ─── Cola de Sincronización ──────────────────────────────────────────────────

/**
 * Encolar una operación HTTP que falló por falta de red.
 * Se procesará automáticamente cuando vuelva la conexión.
 */
export async function enqueueOperation({ method, url, body, label }) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction('sync_queue', 'readwrite');
        const store = tx.objectStore('sync_queue');
        const req = store.add({
            method,
            url,
            body,
            label: label || 'Operación pendiente',
            timestamp: Date.now(),
            retries: 0,
        });
        req.onsuccess = () => { db.close(); resolve(req.result); };
        tx.onerror = () => { db.close(); reject(tx.error); };
    });
}

/**
 * Obtener el número de operaciones pendientes en la cola.
 */
export async function getPendingCount() {
    const items = await getAllRecords('sync_queue');
    return items.length;
}

/**
 * Procesar toda la cola: enviar cada operación al servidor.
 * Devuelve { synced, failed, conflicts }.
 */
export async function processQueue() {
    const items = await getAllRecords('sync_queue');
    const result = { synced: 0, failed: 0, conflicts: [] };

    for (const item of items) {
        try {
            const res = await fetch(item.url, {
                method: item.method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(item.body),
            });

            if (res.ok) {
                await deleteRecord('sync_queue', item.id);
                result.synced++;
            } else if (res.status === 409 || res.status === 422 || res.status === 404) {
                // Conflicto: jornada cerrada, datos duplicados, o eliminados
                await deleteRecord('sync_queue', item.id);
                result.conflicts.push({
                    label: item.label,
                    status: res.status,
                    detail: await res.text().catch(() => 'Sin detalle'),
                });
            } else {
                // Error del servidor (500, etc.) — reintentar después
                result.failed++;
            }
        } catch (e) {
            // Red aún no disponible — dejar en cola
            result.failed++;
        }
    }

    return result;
}

// ─── Buffer de GPS ───────────────────────────────────────────────────────────

/**
 * Guardar una coordenada GPS cuando no hay internet.
 */
export async function bufferGPSPoint({ journey_id, lat, lng, accuracy }) {
    const db = await openDB();
    return new Promise((resolve, reject) => {
        const tx = db.transaction('gps_buffer', 'readwrite');
        tx.objectStore('gps_buffer').add({
            journey_id,
            lat,
            lng,
            accuracy,
            recorded_at: new Date().toISOString(),
        });
        tx.oncomplete = () => { db.close(); resolve(); };
        tx.onerror = () => { db.close(); reject(tx.error); };
    });
}

/**
 * Enviar todas las coordenadas GPS buffereadas al servidor.
 * Devuelve el número de puntos enviados.
 */
export async function flushGPSBuffer(apiBase) {
    const points = await getAllRecords('gps_buffer');
    if (points.length === 0) return 0;

    let sent = 0;
    for (const pt of points) {
        try {
            const res = await fetch(`${apiBase}/grandeza/journeys/${pt.journey_id}/location`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ lat: pt.lat, lng: pt.lng, accuracy: pt.accuracy }),
            });
            if (res.ok) {
                await deleteRecord('gps_buffer', pt.id);
                sent++;
            }
        } catch (e) {
            // Si falla, dejar en buffer para el siguiente intento
            break;
        }
    }
    return sent;
}
