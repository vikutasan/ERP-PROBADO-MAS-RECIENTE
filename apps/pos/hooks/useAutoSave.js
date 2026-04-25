import { useEffect, useRef } from 'react';

/**
 * Hook: useAutoSave
 * Guardado automático periódico al Pizarrón cada 15s (single-try).
 * Se pausa automáticamente durante checkout, colisiones y recuperaciones.
 * IMPORTANTE: El intervalo es verdadero y no un "debounce" porque usa onSaveRef 
 * en lugar de depender directamente de la función onSave y el estado del cart.
 */
export const useAutoSave = ({
    currentAccountNum, 
    cart, 
    showCheckout, 
    showCollisionModal,
    refs, 
    setLastSaveStatus, 
    setLastSaveTime, 
    onSave
}) => {
    // Usar una referencia para onSave para evitar closures obsoletos y 
    // reinicios constantes del timer cuando onSave o cart cambian en cada render.
    const onSaveRef = useRef(onSave);
    useEffect(() => {
        onSaveRef.current = onSave;
    }, [onSave]);

    useEffect(() => {
        // v4.8 FIX: Solo verificamos cuenta inicial vacía al montar el intervalo.
        // Si no hay cuenta, no montamos el intervalo. Si se limpia la cuenta en el futuro,
        // currentAccountNum cambiará a '', causando que el useEffect se desmonte, 
        // lo cual es correcto.
        if (!currentAccountNum || cart.length === 0 || showCheckout || showCollisionModal) return;

        const autoSaveTimer = setInterval(async () => {
            if (refs.isGeneratingFolioRef.current) return;
            if (refs.isRecoveringRef.current) return;
            // Evaluamos la longitud de cartRef en vivo dentro del timer
            if (!refs.accountNumRef.current || refs.cartRef.current.length === 0) return;

            setLastSaveStatus('saving');

            try {
                console.log(`⏱️ Auto-guardando en Pizarrón...`);
                await onSaveRef.current();
                setLastSaveStatus('saved');
                setLastSaveTime(new Date());
            } catch (e) {
                console.warn(`Auto-save falló:`, e);
                setLastSaveStatus('failed');
            }
        }, 15000);

        // Se quitan 'cart' y 'onSave' de las dependencias para evitar
        // que el temporizador se reinicie (debounce effect) con cada nuevo escaneo.
        return () => clearInterval(autoSaveTimer);
    }, [currentAccountNum, showCheckout, showCollisionModal, refs, setLastSaveStatus, setLastSaveTime]);
};
