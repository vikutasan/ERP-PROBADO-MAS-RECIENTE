import { useState, useEffect } from 'react';
import { posService } from '../services/POSService';

/**
 * Custom Hook: useTerminalLocking
 * Encapsula toda la lógica de ocupación de terminales:
 * - Polling de estados de terminales (cada 3s en pantalla de selección)
 * - Auto-expulsión si un Admin rompe nuestro bloqueo (cada 10s)
 * - Limpieza automática al desmontar (liberar terminal)
 */
export const useTerminalLocking = (selectedTerminal, currentUser) => {
    const [terminalStatuses, setTerminalStatuses] = useState({});
    const [forceLogoutModal, setForceLogoutModal] = useState(false);

    // Polling en pantalla principal para ver quién ocupa las terminales
    useEffect(() => {
        let interval;
        const fetchStatuses = async () => {
            if (!selectedTerminal) {
                try {
                    const data = await posService.getTerminalsStatus();
                    setTerminalStatuses(data);
                } catch (e) {
                    console.error("Error fetching terminal status", e);
                }
            }
        };
        fetchStatuses();
        interval = setInterval(fetchStatuses, 3000);
        return () => clearInterval(interval);
    }, [selectedTerminal]);

    // Polling de Auto-Expulsión: verifica si un Admin rompió nuestro bloqueo
    useEffect(() => {
        if (!selectedTerminal || forceLogoutModal) return;
        
        const checkMyLock = async () => {
            try {
                const data = await posService.getTerminalsStatus();
                const myStatus = data[selectedTerminal];
                if (!myStatus || myStatus.occupier_id !== currentUser?.id) {
                    setForceLogoutModal(true);
                }
            } catch (e) {
                console.error("Polling lock error", e);
            }
        };
        
        const intervalId = setInterval(checkMyLock, 10000);
        return () => clearInterval(intervalId);
    }, [selectedTerminal, currentUser, forceLogoutModal]);

    // Limpieza al desmontar: liberar terminal si el usuario cierra sesión o cierra la pestaña
    useEffect(() => {
        return () => {
            if (selectedTerminal && currentUser?.id) {
                posService.unlockTerminal(selectedTerminal, currentUser.id).catch(e => console.warn("Auto-unlock en limpieza falló", e));
            }
        };
    }, [selectedTerminal, currentUser]);

    // Heartbeat: renueva el timestamp del candado cada 2 minutos para evitar que expire por TTL
    useEffect(() => {
        if (!selectedTerminal || !currentUser?.id) return;
        
        const sendHeartbeat = () => {
            posService.heartbeatTerminal(selectedTerminal, currentUser.id)
                .catch(e => console.warn("Heartbeat failed", e));
        };

        // Enviar heartbeat inmediatamente al seleccionar terminal
        sendHeartbeat();
        const intervalId = setInterval(sendHeartbeat, 60000); // Cada 60 segundos (1 minuto) para asegurar el candado
        return () => clearInterval(intervalId);
    }, [selectedTerminal, currentUser]);

    return { terminalStatuses, setTerminalStatuses, forceLogoutModal, setForceLogoutModal };
};
