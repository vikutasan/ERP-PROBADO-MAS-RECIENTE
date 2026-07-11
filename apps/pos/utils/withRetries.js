/**
 * MÓDULO: withRetries.js
 * MISIÓN: Patrón DRY de reintento con backoff progresivo para operaciones atómicas del POS.
 *
 * REGLA v7.0.1: Las 3 operaciones atómicas (add/update/remove) DEBEN usar esta función
 * para garantizar retries simétricos. Prohibido implementar loops de retry inline.
 *
 * Patrón: 3 intentos, backoff progresivo (1s, 2s, 3s).
 * Solo marca 'failed' después de agotar todos los intentos.
 */

const DEFAULT_MAX_RETRIES = 3;

/**
 * Ejecutar una función asíncrona con reintentos automáticos.
 *
 * @param {Function} fn          — Función async a ejecutar. Recibe (attempt) como argumento.
 * @param {Object}   options
 * @param {number}   options.maxRetries    — Máximo de intentos (default: 3)
 * @param {Function} options.shouldRetry   — (error) => bool. Si retorna false, no reintenta (default: siempre reintentar)
 * @param {string}   options.label         — Etiqueta para logs (ej: 'addItem', 'checkout')
 * @returns {*} El resultado de fn() si tiene éxito.
 * @throws El último error si todos los intentos fallan.
 */
export async function withRetries(fn, {
    maxRetries = DEFAULT_MAX_RETRIES,
    shouldRetry = () => true,
    label = 'operación',
} = {}) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await fn(attempt);
        } catch (error) {
            const isRetryable = shouldRetry(error);

            if (isRetryable && attempt < maxRetries) {
                console.warn(`⚠️ ${label} falló (intento ${attempt}/${maxRetries}):`, error);
                await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
            } else {
                // Último intento o error no-retriable → propagar
                if (attempt === maxRetries && isRetryable) {
                    console.error(`❌ ${label} falló después de ${maxRetries} intentos:`, error);
                }
                throw error;
            }
        }
    }
}
