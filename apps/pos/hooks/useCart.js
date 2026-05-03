import { useState, useMemo, useEffect, useRef } from 'react';

/**
 * Hook: useCart
 * Estado del carrito con persistencia en localStorage por terminal.
 *
 * v4.6 ANTI-WIPE: Implementa una máquina de estados interna (cartState)
 * que almacena explícitamente el storageKey junto con los artículos.
 * Un candado lógico (cartState.key === storageKey) en el useEffect de
 * guardado PROHÍBE las operaciones de escritura en disco a menos que
 * el estado ya haya sido sincronizado con la llave activa del terminal.
 *
 * INCIDENTE RESUELTO (02/Mayo/2026): Cuando la red fallaba y el usuario
 * presionaba F5, el carrito se inicializaba vacío [] y el useEffect de
 * guardado sobrescribía el localStorage ANTES de cargar los datos reales,
 * borrando la captura del cajero.
 */
export const useCart = (PRODUCTS, terminalId = 'DEFAULT') => {
    // Llave única por terminal para evitar conflictos
    const storageKey = `pos_cart_${terminalId}`;

    // v4.6 ANTI-WIPE: Máquina de estados que vincula la llave con los items.
    // Esto evita que un cambio de terminal cause una escritura prematura
    // de un carrito vacío al localStorage de la terminal nueva.
    const [cartState, setCartState] = useState(() => {
        try {
            const saved = localStorage.getItem(storageKey);
            return {
                key: storageKey,
                items: saved ? JSON.parse(saved) : []
            };
        } catch (error) {
            console.error("Error loading cart from LocalStorage:", error);
            return { key: storageKey, items: [] };
        }
    });

    // v4.6: Cuando cambia la terminal (storageKey), CARGAR los datos
    // de la nueva llave ANTES de permitir cualquier operación de guardado.
    useEffect(() => {
        if (cartState.key === storageKey) return; // Ya sincronizado

        console.log(`🔑 useCart: Cambio de terminal detectado (${cartState.key} → ${storageKey}). Cargando datos...`);
        try {
            const saved = localStorage.getItem(storageKey);
            setCartState({
                key: storageKey,
                items: saved ? JSON.parse(saved) : []
            });
        } catch (error) {
            console.error("Error loading cart for new terminal:", error);
            setCartState({ key: storageKey, items: [] });
        }
    }, [storageKey, cartState.key]);

    // v4.6 ANTI-WIPE: Persistencia PROTEGIDA — solo escribe si la llave
    // del estado interno coincide con la llave activa de la terminal.
    // Si no coinciden, significa que aún no se cargaron los datos de la
    // nueva terminal, y escribir ahora borraría la captura guardada.
    useEffect(() => {
        if (cartState.key !== storageKey) {
            console.warn(`🛡️ useCart: BLOQUEADO — escritura a "${storageKey}" rechazada (estado sincronizado con "${cartState.key}")`);
            return;
        }
        try {
            localStorage.setItem(storageKey, JSON.stringify(cartState.items));
        } catch (error) {
            console.error("Error saving cart to LocalStorage:", error);
        }
    }, [cartState, storageKey]);

    // Exponer `cart` como alias legible del estado interno
    const cart = cartState.items;

    const total = useMemo(() =>
        cart.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 1), 0)
    , [cart]);

    // v4.6: setCart actualiza el estado interno manteniendo la llave sincronizada
    const setCart = (newItems) => {
        setCartState(prev => ({
            key: prev.key,
            items: typeof newItems === 'function' ? newItems(prev.items) : newItems
        }));
    };

    const addToCart = (product) => {
        setCartState(prev => {
            let targetProduct = product;

            if (product.isAI) {
                const searchName = product.name.toUpperCase();
                const found = PRODUCTS.find(p =>
                    p.name.toUpperCase().includes(searchName) ||
                    searchName.includes(p.name.toUpperCase())
                );

                if (found) {
                    targetProduct = { ...found, quantity: product.quantity || 1 };
                } else {
                    return prev; // Salir si no se encuentra el producto de la IA
                }
            }

            const existing = prev.items.find(item => item.id === targetProduct.id);
            if (existing) {
                return {
                    ...prev,
                    items: prev.items.map(item =>
                        item.id === targetProduct.id
                            ? { ...item, quantity: (item.quantity || 1) + (targetProduct.quantity || 1) }
                            : item
                    )
                };
            }
            return {
                ...prev,
                items: [...prev.items, { ...targetProduct, quantity: targetProduct.quantity || 1, id: targetProduct.id || Date.now() }]
            };
        });
    };

    const updateQuantity = (productId, newQuantity) => {
        setCartState(prev => ({
            ...prev,
            items: prev.items.map(item =>
                item.id === productId ? { ...item, quantity: newQuantity } : item
            )
        }));
    };

    const removeFromCart = (productId) => {
        setCartState(prev => ({
            ...prev,
            items: prev.items.filter(item => item.id !== productId)
        }));
    };

    const clearCart = () => {
        setCartState(prev => ({ ...prev, items: [] }));
        localStorage.removeItem(storageKey);
    };

    return {
        cart,
        setCart,
        total,
        addToCart,
        updateQuantity,
        removeFromCart,
        clearCart
    };
};
