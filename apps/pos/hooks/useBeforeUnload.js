import { useEffect } from 'react';

/**
 * Hook: useBeforeUnload
 * Protección ante cierre accidental de pestaña.
 * - Muestra diálogo nativo de confirmación si hay items no guardados.
 * - Intenta un Emergency Save via navigator.sendBeacon como último recurso.
 */
export const useBeforeUnload = (cartRef, accountNumRef, apiBaseUrl) => {
    useEffect(() => {
        const handleBeforeUnload = (e) => {
            if (cartRef.current.length > 0 && accountNumRef.current) {
                e.preventDefault();
                e.returnValue = '⚠️ Tiene productos en el ticket sin guardar. ¿Seguro que desea salir?';

                try {
                    const payload = JSON.stringify({
                        account_num: accountNumRef.current,
                        items: cartRef.current.map(i => ({ product_id: i.id, quantity: i.quantity || 1 })),
                        status: 'OPEN',
                        emergency_save: true
                    });
                    navigator.sendBeacon(
                        `${apiBaseUrl}/pos/tickets/emergency-save`,
                        new Blob([payload], { type: 'application/json' })
                    );
                } catch (err) {
                    console.error('Emergency save falló:', err);
                }
            }
        };

        window.addEventListener('beforeunload', handleBeforeUnload);
        return () => window.removeEventListener('beforeunload', handleBeforeUnload);
    }, []);
};
