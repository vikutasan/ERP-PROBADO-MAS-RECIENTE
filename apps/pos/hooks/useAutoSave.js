import { useEffect, useRef } from 'react';

/**
 * Hook: useAutoSave
 * Guardado automático periódico al Pizarrón cada 15s (INTERVALO REAL).
 * 
 * v4.5: Se eliminó `cart` de las dependencias del useEffect para evitar
 * el efecto "debounce" (cada addToCart reiniciaba el timer de 15s).
 * Ahora el callback se lee desde un ref para siempre tener datos frescos
 * sin reiniciar el intervalo.
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
    // v4.5: Ref para el callback de guardado — siempre apunta a la versión más reciente
    // sin necesidad de incluir `onSave` o `cart` en las dependencias del useEffect.
    const onSaveRef = useRef(onSave);
    useEffect(() => { onSaveRef.current = onSave; }, [onSave]);

    const setStatusRef = useRef(setLastSaveStatus);
    useEffect(() => { setStatusRef.current = setLastSaveStatus; }, [setLastSaveStatus]);

    const setTimeRef = useRef(setLastSaveTime);
    useEffect(() => { setTimeRef.current = setLastSaveTime; }, [setLastSaveTime]);

    useEffect(() => {
        // Solo crear timer si hay cuenta activa y no estamos en checkout/colisión
        if (!currentAccountNum || showCheckout || showCollisionModal) return;

        const autoSaveTimer = setInterval(async () => {
            if (refs.isGeneratingFolioRef.current) return;
            if (refs.isRecoveringRef.current) return;
            if (!refs.accountNumRef.current || refs.cartRef.current.length === 0) return;

            setStatusRef.current('saving');

            try {
                console.log(`⏱️ Auto-guardando en Pizarrón...`);
                await onSaveRef.current();
                setStatusRef.current('saved');
                setTimeRef.current(new Date());
            } catch (e) {
                console.warn(`Auto-save falló:`, e);
                setStatusRef.current('failed');
            }
        }, 60000); // FASE 2: Reducido de 15s a 60s — ahora es respaldo de emergencia

        return () => clearInterval(autoSaveTimer);
    }, [currentAccountNum, showCheckout, showCollisionModal, refs]);
    // ⚡ v4.5: `cart` y `onSave` ELIMINADOS de las dependencias.
    // El timer ya NO se reinicia al agregar productos — es un INTERVALO REAL de 15s.
    // Los datos frescos se leen desde refs (cartRef, onSaveRef).
};
