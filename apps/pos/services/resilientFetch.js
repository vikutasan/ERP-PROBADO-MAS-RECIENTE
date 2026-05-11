/**
 * resilientFetch.js — v5.1 (Offline Resiliency)
 * 
 * Wrapper transparente alrededor de posService.createTicket().
 * 
 * COMPORTAMIENTO:
 * 1. Intenta el fetch normal al servidor
 * 2. Si éxito → retorna la respuesta normalmente (el código existente sigue igual)
 * 3. Si falla por RED (TypeError: Failed to fetch, AbortError, o timeout):
 *    → Encola el payload completo en localStorage via cartPersistence
 *    → Retorna un objeto { queued: true, localId: ... } 
 *    → handleTicketAction detecta queued=true y NO actualiza version
 * 4. Si falla por ERROR DEL SERVIDOR (4xx, 5xx) → re-lanza el error original
 *    (el servidor respondió, la red funciona — el error es de lógica)
 * 
 * REGLAS DEL LIFECYCLE SPEC QUE RESPETA:
 * - NO modifica handleTicketAction (solo envuelve el fetch de salida)
 * - NO toca refs (cartRef, accountNumRef, etc.)
 * - NO interfiere con el mutex (es transparente al flujo existente)
 * - Solo aplica a operaciones de escritura DRAFT (auto-save), NO a PAID/OPEN
 */

import { enqueueOffline } from './cartPersistence';

/**
 * Determina si un error es de red (no del servidor)
 * @param {Error} error 
 * @returns {boolean}
 */
function isNetworkError(error) {
  if (!error) return false;
  const msg = error.message || '';
  
  // TypeError: Failed to fetch — navegador no pudo conectar
  if (error instanceof TypeError && msg.includes('fetch')) return true;
  
  // AbortError — timeout de la señal
  if (error.name === 'AbortError') return true;
  
  // Errores genéricos de red
  if (msg.includes('NetworkError')) return true;
  if (msg.includes('network')) return true;
  if (msg.includes('ERR_CONNECTION_REFUSED')) return true;
  if (msg.includes('ERR_CONNECTION_RESET')) return true;
  if (msg.includes('ERR_INTERNET_DISCONNECTED')) return true;
  
  return false;
}

/**
 * Envuelve una llamada a posService.createTicket con resiliencia offline.
 * 
 * SOLO encola en modo offline si:
 * 1. El error es de RED (no del servidor)
 * 2. El status del payload es 'DRAFT' (auto-saves)
 * 
 * Para operaciones PAID u OPEN, el error se propaga normalmente
 * porque son acciones explícitas del usuario que DEBEN confirmarse con el servidor.
 * 
 * @param {Function} createTicketFn - posService.createTicket bound
 * @param {object} payload - Payload del ticket
 * @returns {Promise<object>} - Respuesta del servidor o { queued: true, localId }
 */
export async function resilientCreateTicket(createTicketFn, payload) {
  try {
    // Intento normal — si funciona, retornamos la respuesta del servidor
    const result = await createTicketFn(payload);
    return result;
  } catch (error) {
    // Si el error es del SERVIDOR (4xx, 5xx), re-lanzar — la lógica existente maneja esto
    // (ej: "ya ha sido pagado", "Conflicto de versión", etc.)
    if (!isNetworkError(error)) {
      throw error;
    }

    // Error de RED confirmado
    console.warn(`🔌 [ResilientFetch] Red caída. Status del payload: ${payload.status}`);

    // Solo encolar auto-saves (DRAFT)
    // PAID y OPEN son acciones explícitas del usuario — deben fallar visible y ruidosamente
    if (payload.status !== 'DRAFT') {
      console.error(`❌ [ResilientFetch] Operación ${payload.status} no se puede encolar offline.`);
      throw new Error(
        `Sin conexión al servidor. La operación "${payload.status}" requiere conexión. ` +
        `Verifica la red e intenta de nuevo.`
      );
    }

    // Encolar el payload para sync posterior
    const localId = enqueueOffline(payload);
    
    if (!localId) {
      // Si ni siquiera pudimos encolar (localStorage lleno/corrupto), fallar
      throw new Error('Sin conexión y error al guardar localmente. Datos en riesgo.');
    }

    console.log(`📥 [ResilientFetch] Auto-save encolado localmente: ${localId}`);
    
    // Retornar un objeto especial que handleTicketAction reconoce
    return {
      queued: true,
      localId: localId,
      account_num: payload.account_num,
      // NO retornamos version — el payload encolado se sincronizará con version fresh
    };
  }
}
