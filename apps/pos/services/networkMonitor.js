/**
 * MÓDULO: networkMonitor.js
 * MISIÓN: Detección confiable de conectividad real (no solo "conectado a WiFi").
 * 
 * Estrategia de doble verificación:
 *   1. Eventos nativos online/offline del navegador (detección instantánea)
 *   2. Heartbeat cada 30s al endpoint /api/v1/health (verificación real)
 * 
 * REGLA: Este módulo NO importa React ni dependencias externas.
 */

const HEARTBEAT_INTERVAL_MS = 30000; // 30 segundos
const HEARTBEAT_TIMEOUT_MS = 5000;   // Si no responde en 5s, está offline

/**
 * Crear un monitor de red.
 * Uso:
 *   const monitor = createNetworkMonitor('http://192.168.1.117:5001');
 *   monitor.onStatusChange((isOnline) => { ... });
 *   // Al desmontar:
 *   monitor.destroy();
 */
export function createNetworkMonitor(apiBase) {
    let currentStatus = navigator.onLine;
    let listeners = [];
    let heartbeatTimer = null;

    const notify = (newStatus) => {
        if (newStatus !== currentStatus) {
            currentStatus = newStatus;
            listeners.forEach(fn => fn(currentStatus));
        }
    };

    // ─── Eventos nativos ─────────────────────────────────────────────────

    const handleOnline = () => {
        // El navegador dice que hay red — verificar con heartbeat inmediato
        doHeartbeat();
    };

    const handleOffline = () => {
        notify(false);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // ─── Heartbeat periódico ─────────────────────────────────────────────

    const doHeartbeat = async () => {
        if (!apiBase) return;
        try {
            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), HEARTBEAT_TIMEOUT_MS);

            const res = await fetch(`${apiBase}/health`, {
                method: 'GET',
                signal: controller.signal,
                cache: 'no-store',
            });
            clearTimeout(timeout);
            notify(res.ok);
        } catch (e) {
            notify(false);
        }
    };

    // Iniciar heartbeat periódico
    doHeartbeat();
    heartbeatTimer = setInterval(doHeartbeat, HEARTBEAT_INTERVAL_MS);

    // ─── API Pública ─────────────────────────────────────────────────────

    return {
        /** Estado actual de conectividad */
        isOnline: () => currentStatus,

        /** Suscribirse a cambios de estado. Callback: (isOnline: boolean) => void */
        onStatusChange: (callback) => {
            listeners.push(callback);
        },

        /** Forzar un heartbeat inmediato (útil tras una operación importante) */
        checkNow: () => doHeartbeat(),

        /** Limpiar listeners y timers (llamar al desmontar el componente) */
        destroy: () => {
            window.removeEventListener('online', handleOnline);
            window.removeEventListener('offline', handleOffline);
            if (heartbeatTimer) clearInterval(heartbeatTimer);
            listeners = [];
        },
    };
}
