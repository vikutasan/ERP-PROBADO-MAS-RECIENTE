import { useEffect } from 'react';

/**
 * Hook: useAutoSave
 * Guardado automático periódico al Pizarrón cada 15s (single-try).
 * Se pausa automáticamente durante checkout, colisiones y recuperaciones.
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
    useEffect(() => {
        if (!currentAccountNum || cart.length === 0 || showCheckout || showCollisionModal) return;

        const autoSaveTimer = setInterval(async () => {
            if (refs.isGeneratingFolioRef.current) return;
            if (refs.isRecoveringRef.current) return;
            if (!refs.accountNumRef.current || refs.cartRef.current.length === 0) return;

            setLastSaveStatus('saving');

            try {
                console.log(`⏱️ Auto-guardando en Pizarrón...`);
                await onSave();
                setLastSaveStatus('saved');
                setLastSaveTime(new Date());
            } catch (e) {
                console.warn(`Auto-save falló:`, e);
                setLastSaveStatus('failed');
            }
        }, 15000);

        return () => clearInterval(autoSaveTimer);
    }, [currentAccountNum, cart, showCheckout, showCollisionModal, refs, setLastSaveStatus, setLastSaveTime, onSave]);
};
