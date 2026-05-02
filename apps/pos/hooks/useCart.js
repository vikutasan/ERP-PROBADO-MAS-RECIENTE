import { useState, useMemo, useEffect } from 'react';

export const useCart = (PRODUCTS, terminalId = 'DEFAULT') => {
    // LLave única por terminal para evitar conflictos
    const storageKey = `pos_cart_${terminalId}`;

    const [cartState, setCartState] = useState(() => {
        try {
            const saved = localStorage.getItem(storageKey);
            return { key: storageKey, items: saved ? JSON.parse(saved) : [] };
        } catch (error) {
            console.error("Error loading cart from LocalStorage:", error);
            return { key: storageKey, items: [] };
        }
    });

    // 1.5 Sincronización al cambiar de terminal (Bugfix Anti-Borrado)
    useEffect(() => {
        if (cartState.key !== storageKey) {
            try {
                const saved = localStorage.getItem(storageKey);
                setCartState({ key: storageKey, items: saved ? JSON.parse(saved) : [] });
            } catch (error) {
                setCartState({ key: storageKey, items: [] });
            }
        }
    }, [storageKey, cartState.key]);

    // 2. Persistencia: Guardar en LocalStorage cada vez que cambie el carrito
    useEffect(() => {
        // SOLO guardar si el estado interno ya se sincronizó con la llave actual.
        // Esto evita que React sobrescriba los datos guardados con un array vacío
        // durante la transición de cambio de terminal.
        if (cartState.key === storageKey) {
            try {
                localStorage.setItem(storageKey, JSON.stringify(cartState.items));
            } catch (error) {
                console.error("Error saving cart to LocalStorage:", error);
            }
        }
    }, [cartState, storageKey]);

    const cart = cartState.key === storageKey ? cartState.items : [];

    const setCart = (setter) => {
        setCartState(prev => {
            const newItems = typeof setter === 'function' ? setter(prev.items) : setter;
            return { ...prev, items: newItems };
        });
    };

    const total = useMemo(() => 
        cart.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 1), 0)
    , [cart]);

    const addToCart = (product) => {
        setCart(prev => {
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

            const existing = prev.find(item => item.id === targetProduct.id);
            if (existing) {
                return prev.map(item =>
                    item.id === targetProduct.id ? { ...item, quantity: (item.quantity || 1) + (targetProduct.quantity || 1) } : item
                );
            }
            return [...prev, { ...targetProduct, quantity: targetProduct.quantity || 1, id: targetProduct.id || Date.now() }];
        });
    };

    const updateQuantity = (productId, newQuantity) => {
        setCart(prev => prev.map(item => 
            item.id === productId ? { ...item, quantity: newQuantity } : item
        ));
    };

    const removeFromCart = (productId) => {
        setCart(prev => prev.filter(item => item.id !== productId));
    };

    const clearCart = () => {
        setCart([]);
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
