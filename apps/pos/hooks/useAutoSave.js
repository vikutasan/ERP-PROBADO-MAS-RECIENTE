import { useEffect } from 'react';

/**
 * Hook: useAutoSave
 * Guardado automático periódico al Pizarrón con retry y backoff.
 */
export const useAutoSave = ({
    currentAccountNum, 
    cart, 
    showCheckout, 
    refs, 
    setLastSaveStatus, 
    setLastSaveTime, 
    onSave
}) => {
    useEffect(() => {
        if (!currentAccountNum || cart.length === 0 || showCheckout) return;

        let failCount = 0;
        const autoSaveTimer = setInterval(async () => {
            if (refs.isGeneratingFolioRef.current) return;
            if (refs.isRecoveringRef.current) return;
            if (!refs.accountNumRef.current || refs.cartRef.current.length === 0) return;

            setLastSaveStatus('saving');

            for (let attempt = 1; attempt <= 3; attempt++) {
                try {
                    console.log(`⏱️ Auto-guardando en Pizarrón (intento ${attempt}/3)...`);
                    await onSave();
                    setLastSaveStatus('saved');
                    setLastSaveTime(new Date());
                    failCount = 0;
                    return;
                } catch (e) {
                    console.warn(`Auto-save intento ${attempt} falló:`, e);
                    if (attempt < 3) await new Promise(r => setTimeout(r, attempt * 1000));
                }
            }

            failCount++;
            setLastSaveStatus('failed');
            console.error(`🔴 Auto-save falló después de 3 intentos (racha: ${failCount})`);
        }, 15000);

        return () => clearInterval(autoSaveTimer);
    }, [currentAccountNum, cart, showCheckout, refs, setLastSaveStatus, setLastSaveTime, onSave]);
};
