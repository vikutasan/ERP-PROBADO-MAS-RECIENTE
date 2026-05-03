import { useState, useEffect, useRef } from 'react';
import { CONFIG } from '../config';

/**
 * Hook: useNetworkHealth
 * Mide la latencia de red contra el servidor API cada N segundos.
 * Retorna un estado semáforo: 'good' | 'slow' | 'down'.
 * 
 * NO modifica ningún estado existente del POS.
 * Es completamente pasivo y auto-contenido.
 */
export const useNetworkHealth = (intervalMs = 15000) => {
    const [status, setStatus] = useState('good'); // 'good' | 'slow' | 'down'
    const [latency, setLatency] = useState(0);
    const failCountRef = useRef(0);

    useEffect(() => {
        const checkHealth = async () => {
            const start = performance.now();
            try {
                const res = await fetch(`${CONFIG.API_BASE_URL}/settings`, {
                    cache: 'no-store',
                    signal: AbortSignal.timeout(5000) // Timeout 5s
                });
                const elapsed = Math.round(performance.now() - start);
                setLatency(elapsed);

                if (!res.ok) {
                    failCountRef.current++;
                } else {
                    failCountRef.current = 0;
                    setStatus(elapsed > 500 ? 'slow' : 'good');
                }
            } catch (e) {
                failCountRef.current++;
                setLatency(-1);
            }

            // Solo marcar 'down' después de 2 fallos consecutivos
            // para evitar falsos positivos por un solo paquete perdido
            if (failCountRef.current >= 2) {
                setStatus('down');
            } else if (failCountRef.current === 1) {
                setStatus('slow');
            }
        };

        checkHealth();
        const id = setInterval(checkHealth, intervalMs);
        return () => clearInterval(id);
    }, [intervalMs]);

    return { status, latency };
};
