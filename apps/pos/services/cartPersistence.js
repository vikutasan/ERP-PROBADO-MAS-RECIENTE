/**
 * cartPersistence.js — v5.1 (Offline Resiliency)
 * 
 * Auto-guardado y recuperación del carrito de compras
 * + Cola de operaciones offline para sincronización posterior
 * 
 * ARQUITECTURA:
 * - localStorage para persistencia inmediata (sobrevive refresh, crash, cierre de pestaña)
 * - Cola FIFO para operaciones que fallaron por red
 * - Cada entrada tiene ID único para trazabilidad
 */

const CART_KEY = 'rdr_cart_snapshot';

// ─── Auto-guardado ────────────────────────────────────────────────────────────

/**
 * Guarda el estado actual del carrito con metadata de la sesión
 * @param {{ cart, total, clienteLealtad, externalId, terminalId, pagos? }} estado
 */
export function guardarCarrito(estado) {
  if (!estado.cart || estado.cart.length === 0) {
    limpiarCarrito();
    return;
  }
  try {
    const snapshot = {
      ...estado,
      savedAt: new Date().toISOString(),
      version: '1.0',
    };
    localStorage.setItem(CART_KEY, JSON.stringify(snapshot));
  } catch (e) {
    console.warn('[CartPersistence] Error al guardar carrito:', e);
  }
}

// ─── Recuperación ─────────────────────────────────────────────────────────────

/**
 * Recupera el carrito guardado si existe y no es demasiado antiguo
 * @param {number} maxAgeMinutes - Máxima antigüedad en minutos (default: 120 min / 2 horas)
 * @returns {object|null} - Estado guardado o null si no hay / expiró
 */
export function recuperarCarrito(maxAgeMinutes = 120) {
  try {
    const raw = localStorage.getItem(CART_KEY);
    if (!raw) return null;

    const snapshot = JSON.parse(raw);
    if (!snapshot?.cart?.length) {
      limpiarCarrito();
      return null;
    }

    // Verificar antigüedad
    const savedAt = new Date(snapshot.savedAt);
    const ahora = new Date();
    const minutosTranscurridos = (ahora - savedAt) / 1000 / 60;

    if (minutosTranscurridos > maxAgeMinutes) {
      limpiarCarrito();
      return null;
    }

    return snapshot;
  } catch {
    return null;
  }
}

/**
 * Verifica si hay un carrito pendiente de recuperar
 */
export function hayCarritoPendiente() {
  return recuperarCarrito() !== null;
}

/**
 * Limpia el carrito guardado (después de una venta completada o cancelada)
 */
export function limpiarCarrito() {
  try {
    localStorage.removeItem(CART_KEY);
  } catch {}
}

// ─── Cola Offline v5.1 ───────────────────────────────────────────────────────

const OFFLINE_QUEUE_KEY = 'rdr_offline_queue';

/**
 * Genera un ID único para cada entrada de la cola
 * Formato: timestamp-random para ordenamiento natural + unicidad
 */
function generateQueueId() {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 6)}`;
}

/**
 * Encola un payload completo de ticket para sincronización cuando regrese internet.
 * El payload incluye TODA la información necesaria para recrear el request:
 * account_num, session_id, items, status, version, payment_details, etc.
 * 
 * @param {object} payload - Payload completo del ticket (idéntico al que se envía al servidor)
 * @returns {string} - ID de la entrada encolada
 */
export function enqueueOffline(payload) {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const entry = {
      id: generateQueueId(),
      payload: { ...payload },
      enqueuedAt: new Date().toISOString(),
      attempts: 0,
      lastAttempt: null,
      synced: false,
      error: null
    };
    queue.push(entry);
    localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    console.log(`📥 [OfflineQueue] Encolado: ${entry.id} (cuenta: ${payload.account_num})`);
    return entry.id;
  } catch (e) {
    console.error('[OfflineQueue] Error al encolar:', e);
    return null;
  }
}

/**
 * Obtiene la próxima entrada pendiente de la cola (FIFO).
 * Solo retorna entradas no sincronizadas y no expiradas (< 10 minutos).
 * 
 * @returns {object|null} - Próxima entrada o null si la cola está vacía
 */
export function dequeueNext() {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const maxAgeMs = 10 * 60 * 1000; // 10 minutos
    const now = Date.now();
    
    const next = queue.find(entry => {
      if (entry.synced) return false;
      const age = now - new Date(entry.enqueuedAt).getTime();
      if (age > maxAgeMs) {
        // Marcar como expirado para auditoría
        entry.synced = true;
        entry.error = 'EXPIRED';
        return false;
      }
      return true;
    });

    // Persistir cambios de expiración
    localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    return next || null;
  } catch {
    return null;
  }
}

/**
 * Marca una entrada como sincronizada exitosamente
 * @param {string} entryId - ID de la entrada
 */
export function markSynced(entryId) {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const entry = queue.find(e => e.id === entryId);
    if (entry) {
      entry.synced = true;
      entry.syncedAt = new Date().toISOString();
      localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
      console.log(`✅ [OfflineQueue] Sincronizado: ${entryId}`);
    }
  } catch {}
}

/**
 * Incrementa el contador de intentos de una entrada
 * @param {string} entryId - ID de la entrada
 * @param {string} errorMsg - Mensaje de error del último intento
 */
export function markAttempt(entryId, errorMsg) {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const entry = queue.find(e => e.id === entryId);
    if (entry) {
      entry.attempts++;
      entry.lastAttempt = new Date().toISOString();
      entry.error = errorMsg;
      localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    }
  } catch {}
}

/**
 * Retorna el número de entradas pendientes (no sincronizadas, no expiradas)
 * @returns {number}
 */
export function getQueueSize() {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const maxAgeMs = 10 * 60 * 1000;
    const now = Date.now();
    return queue.filter(e => {
      if (e.synced) return false;
      const age = now - new Date(e.enqueuedAt).getTime();
      return age <= maxAgeMs;
    }).length;
  } catch {
    return 0;
  }
}

/**
 * Limpia entradas ya sincronizadas o expiradas de la cola.
 * Mantiene solo las pendientes de sync para no acumular basura en localStorage.
 */
export function cleanupQueue() {
  try {
    const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || '[]');
    const pending = queue.filter(e => !e.synced);
    localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(pending));
  } catch {}
}
