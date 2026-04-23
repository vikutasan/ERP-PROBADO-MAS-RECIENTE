import { useEffect } from 'react';

/**
 * Hook: useBarcodeScanner
 * Escucha el teclado para detectar entrada de lectores de código de barras.
 * Los lectores envían caracteres rápidos (<100ms entre ellos) terminados en Enter.
 */
export const useBarcodeScanner = (products, onProductScanned) => {
    useEffect(() => {
        let buffer = '';
        let lastTime = Date.now();

        const handleKeys = (e) => {
            if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) return;
            const now = Date.now();
            if (now - lastTime > 100) buffer = '';
            lastTime = now;

            if (e.key === 'Enter') {
                if (buffer) {
                    const prod = products.find(p => p.barcode === buffer || p.id.toString() === buffer);
                    if (prod) onProductScanned(prod);
                    buffer = '';
                }
            } else if (e.key.length === 1) buffer += e.key;
        };
        window.addEventListener('keydown', handleKeys);
        return () => window.removeEventListener('keydown', handleKeys);
    }, [products, onProductScanned]);
};
