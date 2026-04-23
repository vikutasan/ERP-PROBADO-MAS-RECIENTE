import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { OpenAccountsCorkboard } from './OpenAccountsCorkboard';
import { posService } from './services/POSService';
import { useCart } from './hooks/useCart';
import { useVision } from './hooks/useVision';
import { useTerminalLocking } from './hooks/useTerminalLocking';
import { useBeforeUnload } from './hooks/useBeforeUnload';
import { useBarcodeScanner } from './hooks/useBarcodeScanner';
import { useAutoSave } from './hooks/useAutoSave';
import { CONFIG } from './config';

// Sub-componentes
import { ProductCard } from './components/ProductCard';
import { ProductGrid } from './components/ProductGrid';
import { CategoryBar } from './components/CategoryBar';
import { SalesReceipt } from './components/SalesReceipt';
import { VisionVisor } from './components/VisionVisor';
import { CheckoutScreen } from './components/CheckoutScreen';
import { TicketTemplate } from './components/TicketTemplate';
import { GestorDeCaja } from './components/GestorDeCaja';
import { TerminalSelector } from './components/TerminalSelector';
import { ProgramacionPedidoModal } from './components/ProgramacionPedidoModal';
import { CollisionModal } from './components/CollisionModal';
import { cashService } from './services/cashService';

import { INITIAL_CATEGORIES, getProductEmoji, terminals } from './utils/posConstants';
import { generateTicketHTML } from './utils/ticketGenerator';

export const RetailVisionPOS = ({ currentUser, onForceLogout }) => {
    // --- Estado ---
    const [selectedTerminal, setSelectedTerminal] = useState(null);
    const [showCorkboard, setShowCorkboard] = useState(false);
    const [categories, setCategories] = useState([]);
    const [initialProducts, setInitialProducts] = useState([]);
    const [activeCategory, setActiveCategory] = useState(null);
    const [currentAccountNum, setCurrentAccountNum] = useState('');
    const [viewMode, setViewMode] = useState('CAMERA');
    const [currentPage, setCurrentPage] = useState(1);
    const [allOpenAccounts, setAllOpenAccounts] = useState([]);
    const [showCheckout, setShowCheckout] = useState(false);
    const [paymentsHistory, setPaymentsHistory] = useState([]);
    const [printTicketData, setPrintTicketData] = useState(null);
    const [originalCapturer, setOriginalCapturer] = useState(null);
    const [toastMessage, setToastMessage] = useState(null);
    // v4.0 ZERO-LOSS: Estado de guardado y loading
    const [lastSaveStatus, setLastSaveStatus] = useState('idle'); // 'idle' | 'saving' | 'saved' | 'failed'
    const [lastSaveTime, setLastSaveTime] = useState(null);
    const [isSendingToPizarron, setIsSendingToPizarron] = useState(false);
    const [ticketVersion, setTicketVersion] = useState(null); // Versión optimista del ticket activo
    const [showCollisionModal, setShowCollisionModal] = useState(false);
    const printRef = React.useRef();
    const savedTicketRef = React.useRef(null); // Ref inmediata para datos de impresión (no depende de re-render)
    const cartRef = React.useRef([]);           // Ref para auto-save anti-stale-closure
    const accountNumRef = React.useRef('');      // Ref para auto-save anti-stale-closure
    const originalCapturerRef = React.useRef(null); // Ref anti-stale para capturista original (v3.0)
    const isGeneratingFolioRef = React.useRef(false); // Flag para bloquear auto-save durante generación
    const isRecoveringRef = React.useRef(false);      // Flag para bloquear auto-save durante recuperación del pizarrón (v3.0)
    const ticketVersionRef = React.useRef(null); // Ref anti-stale para versión optimista
    const actionMutexRef = React.useRef(Promise.resolve()); // v4.1: Mutex para serializar llamadas concurrentes a handleTicketAction

    // --- Estado de Ocupación de Terminales (Custom Hook) ---
    const { terminalStatuses, setTerminalStatuses, forceLogoutModal, setForceLogoutModal } = useTerminalLocking(selectedTerminal, currentUser);

    // --- Estado del Gestor de Caja ---
    const [isCashEnabled, setIsCashEnabled] = useState(false);
    const [showGestorCaja, setShowGestorCaja] = useState(false);
    const [cashSessionId, setCashSessionId] = useState(null);

    // --- Estado de Tipo de Venta (Venta Directa vs Pedido) ---
    const [orderType, setOrderType] = useState('VENTA_DIRECTA'); // 'VENTA_DIRECTA' | 'PEDIDO'
    const [showProgramacion, setShowProgramacion] = useState(false);
    const [orderData, setOrderData] = useState(null); // datos del pedido una vez guardado

    // --- Hooks Personalizados ---
    const PRODUCTS = useMemo(() => initialProducts.map(p => ({
        ...p,
        id: p.id, 
        image: p.image_url,
        emoji: getProductEmoji(p),
        hasRealImage: !!p.image_url,
        category: p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : 'OTROS'
    })), [initialProducts]);

    const { cart, setCart, total, addToCart, updateQuantity, removeFromCart, clearCart } = useCart(PRODUCTS, selectedTerminal);
    const { isScanning, setIsScanning } = useVision();

    // --- Mantener refs sincronizadas con state (anti-stale-closure) ---
    // REGLA 1 de POS_TICKET_LIFECYCLE_SPEC v3.0: TODA variable leída en timers/callbacks DEBE tener ref
    React.useEffect(() => { cartRef.current = cart; }, [cart]);
    React.useEffect(() => { accountNumRef.current = currentAccountNum; }, [currentAccountNum]);
    React.useEffect(() => { originalCapturerRef.current = originalCapturer; }, [originalCapturer]);
    React.useEffect(() => { ticketVersionRef.current = ticketVersion; }, [ticketVersion]);

    // --- Persistencia de Metadatos de Sesión ---
    useEffect(() => {
        if (!selectedTerminal) return;
        const sessionKey = `pos_session_${selectedTerminal}`;
        try {
            const saved = localStorage.getItem(sessionKey);
            if (saved) {
                const data = JSON.parse(saved);
                
                // VALIDACIÓN POST-RESTORE: Solo confiar si el número de cuenta parece válido
                if (data.currentAccountNum && data.currentAccountNum.startsWith('V')) {
                    // PROTECCIÓN ANTI-ZOMBIE: 
                    // Si restauramos un numero pero el carrito está vacío, 
                    // es mejor descartarlo para evitar sobreescribir tickets viejos accidentalmente.
                    if (cart.length === 0) {
                        console.log("Descartando folio zombie recuperado (carrito vacío)");
                        setCurrentAccountNum('');
                        setOriginalCapturer(null);
                    } else {
                        setCurrentAccountNum(data.currentAccountNum);
                        if (data.originalCapturer && typeof data.originalCapturer === 'object') {
                            setOriginalCapturer(data.originalCapturer);
                        }
                    }
                }
                
                if (data.orderType) setOrderType(data.orderType);
                if (data.orderData) setOrderData(data.orderData);
                
                console.log("Sesión recuperada para terminal:", selectedTerminal);
            }
        } catch (e) { console.warn("Error al restaurar metadatos de sesión", e); }
    }, [selectedTerminal]); // EJECUTAR SOLO AL CAMBIAR DE TERMINAL para evitar colisión con el Pizarrón

    useEffect(() => {
        if (!selectedTerminal) return;
        const sessionKey = `pos_session_${selectedTerminal}`;
        try {
            // Sanitización extrema para evitar el "Cuadro Rojo" por objetos no-serializables
            const sessionData = { 
                currentAccountNum, 
                orderType, 
                orderData: (orderData && typeof orderData === 'object') ? orderData : null, 
                originalCapturer: (originalCapturer && typeof originalCapturer === 'object') 
                    ? { id: originalCapturer.id, name: originalCapturer.name } 
                    : null 
            };
            localStorage.setItem(sessionKey, JSON.stringify(sessionData));
        } catch (e) { 
            console.warn("No se pudo guardar la persistencia de sesión:", e); 
        }
    }, [selectedTerminal, currentAccountNum, orderType, orderData, originalCapturer]);


    // --- Efectos de Carga ---
    useEffect(() => {
        const loadInitialData = async () => {
            try {
                const catData = await posService.getCategories();
                const normalized = catData
                    .filter(c => c.name.trim().toUpperCase() !== 'TODOS' && c.name.trim().toUpperCase() !== 'DESCONTINUADOS')
                    .map(c => {
                        const original = INITIAL_CATEGORIES.find(ic => ic.name === c.name);
                        return { ...c, icon: c.icon || (original ? original.icon : '📦') };
                    });
                setCategories(normalized);
                if (normalized.length > 0 && !activeCategory) setActiveCategory(normalized[0].name);

                const prodData = await posService.getProducts();
                // Ocultar productos que estén en el Limbo (DESCONTINUADOS)
                const activeProducts = prodData.filter(p => {
                    const catName = p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : '';
                    return catName !== 'DESCONTINUADOS';
                });
                setInitialProducts(activeProducts);
            } catch (error) {
                console.error("Fetch error:", error);
                setToastMessage("❌ Error conectando con el ERP. Verifique el servidor.");
                setTimeout(() => setToastMessage(null), 5000);
            }
        };
        loadInitialData();
    }, []);

    const accountGenPromise = React.useRef(null);
    const generateNewAccountNum = useCallback(async () => {
        if (accountGenPromise.current) return accountGenPromise.current;
        
        isGeneratingFolioRef.current = true; // Bloquear auto-save durante generación
        const promise = (async () => {
            const terminalId = selectedTerminal || 'T1';
            
            for (let attempt = 1; attempt <= 3; attempt++) {
                try {
                    const ticket = await posService.reserveTicket(terminalId, currentUser?.id || null);
                    // v4.3 ANTI-RACE: Sync refs ANTES del setState para que handleTicketAction
                    // nunca lea un accountNum vacío y genere un folio duplicado.
                    accountNumRef.current = ticket.account_num;
                    setCurrentAccountNum(ticket.account_num);
                    
                    // v4.4 Bugfix: Sincronizar versión del ticket reciclado para evitar 
                    // que el primer auto-save envíe version=null y rompa el tracking
                    const v = ticket.version || 1;
                    ticketVersionRef.current = v;
                    setTicketVersion(v);

                    const cap = ticket.captured_by
                        ? { id: ticket.captured_by.id, name: ticket.captured_by.name }
                        : currentUser;
                    originalCapturerRef.current = cap;
                    setOriginalCapturer(cap);
                    return ticket.account_num;
                } catch (error) {
                    console.error(`Error reservando cuenta (intento ${attempt}/3):`, error);
                    if (attempt < 3) {
                        await new Promise(r => setTimeout(r, 1000));
                    }
                }
            }
            
            setToastMessage("⚠️ Error de conexión. No se pudo reservar folio.");
            setTimeout(() => setToastMessage(null), 5000);
            throw new Error("No se pudo reservar cuenta después de 3 intentos");
        })();

        accountGenPromise.current = promise;
        try {
            return await promise;
        } finally {
            accountGenPromise.current = null;
            isGeneratingFolioRef.current = false; // Desbloquear auto-save
        }
    }, [selectedTerminal, currentUser]);

    // v4.0 ZERO-LOSS: Save inmediato al primer producto
    const handleAddToCart = (product) => {
        addToCart(product); // UI reacts instantly
        if (!currentAccountNum) {
            // Generar folio Y guardar inmediatamente al servidor
            generateNewAccountNum().then(accountNum => {
                if (accountNum) {
                    // Delay mínimo para que React procese el addToCart
                    setTimeout(() => {
                        console.log('📡 ZERO-LOSS: Guardado inmediato del primer producto');
                        handleTicketAction('OPEN', null, false)
                            .then(() => {
                                setLastSaveStatus('saved');
                                setLastSaveTime(new Date());
                            })
                            .catch(e => {
                                console.error('⚠️ ZERO-LOSS: Fallo en guardado inmediato:', e);
                                setLastSaveStatus('failed');
                            });
                    }, 100);
                }
            }).catch(e => console.error(e));
        }
    };

    useEffect(() => {
        if (selectedTerminal) {
            // ELIMINADA: La auto-reserva al cargar (Lazy Mode ON)
            
            // Verificar si hay sesión de caja activa para habilitar el cobro inmediatamente
            const syncCashState = async () => {
                try {
                    const session = await cashService.obtenerSesionActiva(selectedTerminal);
                    if (session) {
                        setIsCashEnabled(true);
                        setCashSessionId(session.id);
                    } else {
                        setIsCashEnabled(false);
                        setCashSessionId(null);
                    }
                } catch (e) {
                    console.error("Error sincronizando estado de caja:", e);
                }
            };
            syncCashState();
        }
    }, [selectedTerminal, currentAccountNum, generateNewAccountNum]);

    useAutoSave({
        currentAccountNum, 
        cart, 
        showCheckout, 
        showCollisionModal,
        refs: { isGeneratingFolioRef, isRecoveringRef, accountNumRef, cartRef },
        setLastSaveStatus, 
        setLastSaveTime, 
        onSave: () => handleTicketAction('OPEN', null, false)
    });

    useBeforeUnload(cartRef, accountNumRef, CONFIG.API_BASE_URL);

    useBarcodeScanner(PRODUCTS, handleAddToCart);

    // --- Lógica de Negocio (Tickets) ---

    const handlePrintTicket = (ticketData = null) => {
        // PRIORIDAD DE DATOS:
        // 1. Datos pasados por argumento (ticket oficial del servidor)
        // 2. Datos guardados en el último ticket impreso (printTicketData)
        // 3. Fallback a estado local (solo si no hay nada más)
        const activeTicket = ticketData || printTicketData || { 
            account_num: currentAccountNum,
            items: cart.map(i => ({ product: { name: i.name }, quantity: i.quantity, unit_price: i.price })),
            total: total,
            payment_details: paymentsHistory,
            captured_by: originalCapturer || { id: currentUser?.id, name: currentUser?.name || 'SISTEMA' },
            cashed_by: { id: currentUser?.id, name: currentUser?.name || 'SISTEMA' },
            terminal_id: selectedTerminal,
            created_at: new Date().toISOString()
        };
        
        console.log("Printing ticket with data:", activeTicket);
        
        const html = generateTicketHTML(activeTicket);

        const iframe = document.createElement('iframe');
        iframe.style.position = 'fixed';
        iframe.style.right = '0';
        iframe.style.bottom = '0';
        iframe.style.width = '0';
        iframe.style.height = '0';
        iframe.style.border = '0';
        document.body.appendChild(iframe);

        const doc = iframe.contentWindow.document;
        doc.open();
        doc.write(html);
        doc.close();

        setTimeout(() => {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
            setTimeout(() => {
                document.body.removeChild(iframe);
            }, 1000);
        }, 500); 
    };

    const handleTicketAction = async (status, paymentData = null, finalizeUI = true) => {
        // v4.1: Adquirir Lock Mutex para evitar self-collisions (ej. auto-save + pagar al mismo tiempo)
        const previousPromise = actionMutexRef.current;
        let releaseMutex;
        actionMutexRef.current = new Promise(resolve => releaseMutex = resolve);
        
        await previousPromise;

        try {
            // REGLA 1: Leer SIEMPRE de refs DESPUÉS de adquirir el lock (la versión pudo cambiar)
            const liveCart = cartRef.current;
            const liveAccountNum = accountNumRef.current;
            const liveCapturer = originalCapturerRef.current;
            const liveVersion = ticketVersionRef.current;

            if (liveCart.length === 0) {
                setToastMessage("⚠️ El ticket está vacío.");
                setTimeout(() => setToastMessage(null), 3000);
                return;
            }
            
            // Si no hay datos de pago y se intenta cobrar, abrir pantalla de pago
            if (status === 'PAID' && (!paymentData || paymentData.length === 0)) {
                setShowCheckout(true);
                return;
            }

            // v4.0: Loading visual para envío al Pizarrón
            if (finalizeUI && status === 'OPEN') setIsSendingToPizarron(true);

            try {
                let targetAccountNum = liveAccountNum;
                if (!targetAccountNum) {
                    targetAccountNum = await generateNewAccountNum();
                }

                if (paymentData) setPaymentsHistory(paymentData);
                const terminalId = selectedTerminal || 'T1';
                let session = await posService.getActiveSession(terminalId);
                if (!session) session = await posService.createSession(terminalId);

                let payload = {
                    account_num: targetAccountNum,
                    session_id: session.id,
                    items: liveCart.map(i => ({ product_id: i.id, quantity: i.quantity || 1 })),
                    status: status,
                    payment_details: paymentData,
                    cash_session_id: cashSessionId,
                    captured_by_id: liveCapturer?.id || currentUser?.id || null,
                    cashed_by_id: status === 'PAID' ? (currentUser?.id || null) : null,
                    order_type: orderType,
                    // v4.3: SIEMPRE enviar version. El mutex serializa las llamadas y
                    // el sync directo de ticketVersionRef (L424) elimina stale-closures.
                    // Enviar null permitía que el auto-save sobreescribiera tickets de otros usuarios.
                    version: liveVersion
                };

                // Inyectar data del OMS si es pedido
                if (orderType === 'PEDIDO' && orderData) {
                    payload = { ...payload, ...orderData };
                }

                let savedTicket = null;
                try {
                    savedTicket = await posService.createTicket(payload);
                } catch (err) {
                    const errorMessage = err.message || "";
                    if (errorMessage.includes("ya ha sido pagado")) {
                        console.warn("⚠️ Colisión de folio detectada en servidor. Autogenerando nuevo folio y reintentando...");
                        const newAccountNum = await generateNewAccountNum();
                        targetAccountNum = newAccountNum;
                        // generateNewAccountNum ya sincroniza accountNumRef (v4.3)
                        payload.account_num = newAccountNum;
                        payload.version = null; // Ticket nuevo, sin versión
                        savedTicket = await posService.createTicket(payload);
                    } else if (errorMessage.includes("Conflicto de versión")) {
                        // v4.3: SIEMPRE mostrar modal de colisión. El usuario DEBE saber
                        // que otro operador modificó la cuenta para ir al Pizarrón a re-sincronizar.
                        // El guard de showCollisionModal en useAutoSave pausará futuros auto-saves.
                        setShowCollisionModal(true);
                        throw err;
                    } else {
                        throw err;
                    }
                }
                
                // v4.2: Actualizar versión SINCRÓNICAMENTE en la ref para que
                // el próximo ciclo del mutex lea la versión fresca.
                // Antes se hacía solo con setState, y el useEffect que sincroniza
                // la ref llegaba tarde → siguiente auto-save leía versión stale → 409.
                if (savedTicket?.version) {
                    ticketVersionRef.current = savedTicket.version; // SYNC: anti-stale
                    setTicketVersion(savedTicket.version);          // ASYNC: para UI
                }
                
                setPrintTicketData(savedTicket);
                savedTicketRef.current = savedTicket;
                
                // v4.0 ZERO-LOSS: El carrito solo se limpia DESPUÉS de confirmar el guardado
                if (finalizeUI) {
                    if (status === 'PAID') {
                        console.log("Auto-printing PAID ticket. Response from server:", savedTicket);
                        handlePrintTicket(savedTicket);
                    }
                    if (savedTicket) {
                        clearCart();
                        setOriginalCapturer(null);
                        setCurrentAccountNum('');
                        setTicketVersion(null);
                        setOrderData(null);
                        setOrderType('VENTA_DIRECTA');
                        setLastSaveStatus('idle');
                        setLastSaveTime(null);
                        try {
                            if (selectedTerminal) localStorage.removeItem(`pos_session_${selectedTerminal}`);
                        } catch (e) { console.warn("Error al limpiar persistencia:", e); }
                        setShowCheckout(false);
                        setPaymentsHistory([]);
                        if (status === 'PAID') {
                            setToastMessage('✅ Venta finalizada exitosamente. Ticket impreso.');
                            setTimeout(() => setToastMessage(null), 4000);
                        }
                        if (status === 'OPEN') {
                            setToastMessage('📌 Cuenta guardada en el Pizarrón exitosamente.');
                            setTimeout(() => setToastMessage(null), 3000);
                        }
                    }
                }
            } catch (error) {
                console.error("Ticket action error:", error);
                if (finalizeUI) {
                    const errMsg = error.detail || error.message || "";
                    if (!errMsg.includes("Conflicto de versión")) {
                        setToastMessage(`❌ ${errMsg || "Error al procesar el ticket."}`);
                        setTimeout(() => setToastMessage(null), 5000);
                    }
                }
                throw error;
            } finally {
                setIsSendingToPizarron(false);
            }
        } finally {
            releaseMutex(); // Liberar el candado
        }
    };

    const handleRecoverAccount = async (account) => {
        // v3.0 FIX — REGLA 3: Bloquear auto-save ANTES de cualquier mutación de estado o fetch asíncrono
        isRecoveringRef.current = true;

        // ⚡ FIX: Eliminar delay de polling obteniendo siempre la versión más fresca directamente
        let freshItems = account.rawItems;
        let freshVersion = account.version;
        let freshCapturer = account.capturedById ? { id: account.capturedById, name: account.capturedByName } : null;
        
        try {
            const liveTicket = await posService.getTicketByAccountNum(account.accountNum);
            if (liveTicket && liveTicket.items) {
                console.log("⚡ Cuenta recuperada (Live Data):", liveTicket);
                freshItems = liveTicket.items;
                freshVersion = liveTicket.version;
                freshCapturer = liveTicket.captured_by_id ? { id: liveTicket.captured_by_id, name: liveTicket.captured_by_name || liveTicket.captured_by?.name } : freshCapturer;
            }
        } catch (e) {
            console.warn("⚠️ No se pudo obtener la versión fresca del ticket, usando datos del Pizarrón", e);
        }

        if (!freshItems?.length) {
            setToastMessage("⚠️ Cuenta vacía.");
            setTimeout(() => setToastMessage(null), 3000);
            isRecoveringRef.current = false;
            return;
        }

        const recovered = freshItems.map(i => {
            const originalProd = initialProducts.find(p => p.id === i.product.id) || {};
            return {
                id: i.product.id,
                name: i.product.name,
                price: i.product.price,
                quantity: i.quantity,
                category: i.product.category?.name || 'OTROS',
                nature: i.product.nature || originalProd.nature || 'PRODUCTO'
            };
        });
        setCart(recovered);
        // v4.3 ANTI-RACE: Sync TODAS las refs ANTES de los setState.
        // requestAnimationFrame (L535) puede dispararse antes que los useEffect de sync,
        // permitiendo que el auto-save lea refs stale si no sincronizamos aquí.
        accountNumRef.current = account.accountNum;
        setCurrentAccountNum(account.accountNum);
        
        console.log("Recovering account. Original capturer:", freshCapturer);
        originalCapturerRef.current = freshCapturer || currentUser;
        setOriginalCapturer(freshCapturer || currentUser);
        // v4.3: Restaurar versión del ticket con SYNC inmediato para evitar 409 falsos
        ticketVersionRef.current = freshVersion || null;
        setTicketVersion(freshVersion || null);
        
        // --- Restaurar Order Data si la cuenta es un PEDIDO ---
        if (account.orderType === 'PEDIDO') {
            setOrderType('PEDIDO');
            setOrderData({
                order_type: account.orderType,
                delivery_type: account.deliveryType,
                customer_name: account.clientName,
                customer_phone: account.customerPhone,
                committed_at: account.committedAt,
                packaging_type: account.packagingType,
                delivery_address: account.deliveryAddress,
                notes: account.orderNotes
            });
        } else {
            setOrderType('VENTA_DIRECTA');
            setOrderData(null);
        }

        setShowCorkboard(false);

        // v3.0: Desbloquear auto-save DESPUÉS de que React procese todos los setState batched
        requestAnimationFrame(() => {
            isRecoveringRef.current = false;
        });
    };

    useEffect(() => {
        if (!showCorkboard) return;

        const fetchOpenAccounts = () => {
            posService.getOpenTickets().then(data => {
                console.log("Open tickets from server:", data);
                setAllOpenAccounts(data.map(t => ({
                    id: t.account_num,
                    accountNum: t.account_num,
                    terminal: t.terminal_id || 'T1',
                    total: t.total,
                    items: t.items.length,
                    rawItems: t.items,
                    timestamp: t.created_at,
                    capturedById: t.captured_by_id,
                    capturedByName: t.captured_by_name || t.captured_by?.name || 'Desconocido',
                    cashierName: t.cashed_by_name || t.cashed_by?.name || '---',
                    clientName: t.customer_name || 'Público General',
                    version: t.version || 1, // v4.0: Incluir versión para bloqueo optimista
                    // --- Mapeo OMS ---
                    orderType: t.order_type,
                    orderStatus: t.order_status,
                    deliveryType: t.delivery_type,
                    customerPhone: t.customer_phone,
                    committedAt: t.committed_at,
                    packagingType: t.packaging_type,
                    deliveryAddress: t.delivery_address,
                    orderNotes: t.order_notes
                })));
            }).catch(console.error);
        };

        fetchOpenAccounts();
        const interval = setInterval(fetchOpenAccounts, 5000);
        return () => clearInterval(interval);
    }, [showCorkboard]);

    const visibleAccounts = allOpenAccounts;

    // --- Renderizado de Pantalla Inicial ---
    if (!selectedTerminal) {
        return (
            <TerminalSelector 
                currentUser={currentUser}
                terminalStatuses={terminalStatuses}
                setTerminalStatuses={setTerminalStatuses}
                onTerminalSelected={setSelectedTerminal}
            />
        );
    }

    // --- Componentes Locales (Mantenidos para preservar Grid estable) ---
    // ProductCard y ProductGrid han sido extraídos a sus propios archivos.

    return (
        <div className="flex flex-col h-full bg-transparent text-white overflow-hidden">
            {/* Header: 3 zonas - Terminal | Cuenta+Tipo | Caja+Pizarron */}
            <div className="p-4 pb-2 z-20">
                <div className="flex justify-between items-center mb-3">
                    {/* IZQUIERDA: Terminal */}
                    <div className="flex-shrink-0">
                        <button onClick={async () => {
                            try {
                                await posService.unlockTerminal(selectedTerminal, currentUser?.id);
                            } catch(e) { console.error("Could not unlock terminal", e); }
                            setSelectedTerminal(null);
                        }} className="bg-zinc-900/90 border border-white/5 px-6 py-2 rounded-xl flex items-center hover:bg-zinc-800 transition-all group shadow-2xl">
                            <div className="text-left">
                                <p className="text-[18px] font-black uppercase text-white tracking-widest leading-none mb-1">
                                    {selectedTerminal === 'CAJA' ? 'Caja Central' : `Terminal ${selectedTerminal}`}
                                </p>
                                <p className="text-[14px] font-black text-orange-500 uppercase tracking-tighter leading-none">
                                    Cambiar Estación
                                </p>
                            </div>
                        </button>
                    </div>

                    {/* CENTRO: Cuenta + Toggle Tipo + Botón Programación */}
                    <div className="flex items-center gap-3 flex-1 justify-center">
                        {/* Número de cuenta */}
                        <div className="bg-black border border-white/10 px-8 py-2 rounded-3xl shadow-2xl flex flex-col items-center">
                            <span className="text-[7px] font-black uppercase text-white tracking-[0.5em] mb-0.5">ESTADO DE TRANSACCION</span>
                            <span className={`text-4xl font-black uppercase tracking-tighter italic drop-shadow-[0_0_12px_rgba(193,215,46,0.4)] ${
                                currentAccountNum
                                    ? orderData ? 'text-orange-400' : 'text-[#c1d72e]'
                                    : 'text-orange-500 animate-pulse'
                            }`}>
                                {currentAccountNum
                                    ? `CUENTA #${currentAccountNum.slice(-3)}`
                                    : 'NUEVA VENTA'}
                            </span>
                            {orderData && (
                                <span className="text-[8px] font-black text-orange-400 uppercase tracking-widest animate-pulse mt-0.5">📦 PEDIDO TENTATIVO</span>
                            )}
                        </div>

                        {/* Toggle: Venta Directa / Pedido */}
                        <div className="flex bg-black/60 border border-white/10 rounded-2xl p-1 gap-1">
                            <button
                                id="btn-venta-directa"
                                onClick={() => { setOrderType('VENTA_DIRECTA'); setOrderData(null); }}
                                className={`px-4 py-2 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                                    orderType === 'VENTA_DIRECTA'
                                        ? 'bg-[#c1d72e] text-black shadow-lg'
                                        : 'text-white/50 hover:text-white'
                                }`}
                            >
                                Venta Directa
                            </button>
                            <button
                                id="btn-pedido"
                                onClick={() => setOrderType('PEDIDO')}
                                className={`px-4 py-2 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                                    orderType === 'PEDIDO'
                                        ? 'bg-orange-500 text-white shadow-lg'
                                        : 'text-white/50 hover:text-white'
                                }`}
                            >
                                📦 Pedido
                            </button>
                        </div>

                        {/* Botón Programación del Pedido — solo visible en modo PEDIDO */}
                        {orderType === 'PEDIDO' && (
                            <button
                                id="btn-programacion-pedido"
                                onClick={() => setShowProgramacion(true)}
                                className="bg-orange-500/20 border border-orange-500/60 px-5 py-2 rounded-xl flex items-center gap-2 hover:bg-orange-500/30 hover:border-orange-400 transition-all shadow-xl animate-in fade-in duration-300"
                            >
                                <div className="text-left">
                                    <p className="text-[13px] font-black uppercase text-white tracking-widest leading-none mb-0.5">Programación</p>
                                    <p className="text-[11px] font-black text-orange-400 uppercase tracking-tighter leading-none">del Pedido</p>
                                </div>
                                <span className="text-xl">🗓️</span>
                            </button>
                        )}
                    </div>

                    {/* DERECHA: Caja + Pizarron */}
                    <div className="flex-shrink-0 flex gap-2">
                        <button
                            onClick={() => setShowGestorCaja(true)}
                            className="bg-black/60 border border-[#c1d72e]/40 px-6 py-2 rounded-xl flex items-center hover:bg-[#c1d72e]/20 hover:border-[#c1d72e] transition-all shadow-xl"
                            title={isCashEnabled ? 'Gestionar Caja (Activa)' : 'Habilitar como Caja'}
                        >
                            <div className="text-left">
                                <p className="text-[18px] font-black uppercase text-white tracking-widest leading-none mb-1">Caja</p>
                                <p className={`text-[14px] font-black uppercase tracking-tighter leading-none ${isCashEnabled ? 'text-[#c1d72e]' : 'text-[#c1d72e]/60'}`}>
                                    {isCashEnabled ? '● Activa' : '○ Habilitar'}
                                </p>
                            </div>
                        </button>

                        <button
                            onClick={() => setShowCorkboard(true)}
                            className="bg-[#2d1e13] border border-orange-900/40 px-6 py-2 rounded-xl flex items-center hover:bg-[#3d2b1f] hover:border-orange-500/50 transition-all group shadow-xl"
                        >
                            <div className="text-left">
                                <p className="text-[18px] font-black uppercase text-white tracking-widest leading-none mb-1">Pizarron</p>
                                <p className="text-[14px] font-black text-orange-500 uppercase tracking-tighter leading-none">
                                    {visibleAccounts.length} {selectedTerminal === 'CAJA' ? 'TOTALES' : 'MIAS'}
                                </p>
                                {/* v4.0 ZERO-LOSS: Badge de estado de guardado */}
                                {lastSaveStatus === 'failed' && cart.length > 0 && (
                                    <p className="text-[10px] font-black text-red-500 uppercase tracking-tighter leading-none animate-pulse mt-0.5">
                                        ⚠️ SIN GUARDAR
                                    </p>
                                )}
                                {lastSaveStatus === 'saving' && (
                                    <p className="text-[10px] font-black text-yellow-400 uppercase tracking-tighter leading-none mt-0.5">
                                        ⏳ Guardando...
                                    </p>
                                )}
                                {lastSaveStatus === 'saved' && lastSaveTime && (
                                    <p className="text-[10px] font-black text-green-400 uppercase tracking-tighter leading-none mt-0.5">
                                        ✅ {lastSaveTime.toLocaleTimeString('es-MX', {hour:'2-digit', minute:'2-digit'})}
                                    </p>
                                )}
                            </div>
                        </button>
                    </div>
                </div>

                <CategoryBar 
                    categories={categories} 
                    activeCategory={activeCategory} 
                    setActiveCategory={setActiveCategory} 
                    viewMode={viewMode} 
                    setViewMode={setViewMode} 
                    setCurrentPage={setCurrentPage} 
                />
            </div>

            {/* Main Content */}
            <div className="flex-1 flex overflow-hidden">
                <div className="flex-1 flex flex-col p-4 pt-0 pb-24 bg-transparent overflow-hidden">
                    {viewMode === 'CAMERA' ? (
                        <VisionVisor 
                            isScanning={isScanning} 
                            setIsScanning={setIsScanning} 
                            addToCart={handleAddToCart} 
                            products={PRODUCTS} 
                            categories={categories} 
                        />
                    ) : (
                        <div className="flex-1 flex flex-col animate-in fade-in slide-in-from-left-4 duration-500">

                            <ProductGrid 
                                products={PRODUCTS} 
                                category={activeCategory} 
                                currentPage={currentPage} 
                                setCurrentPage={setCurrentPage} 
                                onAddToCart={handleAddToCart} 
                            />
                        </div>
                    )}
                </div>

                <SalesReceipt 
                    cart={cart} 
                    removeFromCart={removeFromCart} 
                    updateQuantity={updateQuantity}
                    total={total} 
                    currentAccountNum={currentAccountNum} 
                    selectedTerminal={selectedTerminal} 
                    handleCheckout={(method) => handleTicketAction('PAID', method)} 
                    handleHoldAccount={() => handleTicketAction('OPEN')}
                    cashEnabled={isCashEnabled}
                    isSendingToPizarron={isSendingToPizarron}
                />
            </div>

            {showCheckout && (
                <CheckoutScreen 
                    cart={cart}
                    total={total}
                    orderData={orderData}
                    onConfirm={async (method) => {
                        await handleTicketAction('PAID', method, true); // finalizeUI=true maneja impresión y limpieza
                    }}
                    onClose={() => {
                        setShowCheckout(false);
                    }}
                />
            )}

            {showCorkboard && (
                <OpenAccountsCorkboard
                    openAccounts={visibleAccounts}
                    onSelectAccount={handleRecoverAccount}
                    onClose={() => setShowCorkboard(false)}
                />
            )}

            {showGestorCaja && (
                <GestorDeCaja
                    terminalId={selectedTerminal}
                    currentUser={currentUser}
                    onCajaHabilitada={(sessionId) => {
                        setIsCashEnabled(true);
                        setCashSessionId(sessionId);
                    }}
                    onCajaDeshabilitada={() => {
                        setIsCashEnabled(false);
                        setCashSessionId(null);
                    }}
                    onClose={() => setShowGestorCaja(false)}
                />
            )}


            {/* Modal: Programación del Pedido */}
            {showProgramacion && (
                <ProgramacionPedidoModal
                    cart={cart}
                    allProducts={initialProducts}
                    currentAccountNum={currentAccountNum}
                    initialData={orderData}
                    onClose={() => setShowProgramacion(false)}
                    onAddToCart={addToCart}
                    onSave={(data) => {
                        setOrderData(data);
                        setShowProgramacion(false);
                    }}
                />
            )}

            {/* Contenedor Principal (Fin) */}
            {/* Modal de Auto-Expulsión (Polling Remoto) */}
            {forceLogoutModal && (
                <div className="fixed inset-0 bg-black/95 backdrop-blur-xl flex items-center justify-center z-[200] animate-in fade-in zoom-in duration-500">
                    <div className="bg-gray-950 border border-red-500/30 p-12 rounded-[50px] shadow-[0_0_100px_rgba(255,0,0,0.3)] max-w-md w-full text-center relative overflow-hidden">
                        <div className="absolute -top-40 -left-40 w-80 h-80 bg-red-600/20 blur-[100px] rounded-full"></div>
                        <div className="text-8xl mb-6 relative z-10 animate-pulse">🚨</div>
                        <h2 className="text-3xl font-black uppercase text-red-500 mb-4 relative z-10 tracking-tighter">SESIÓN TERMINADA</h2>
                        <p className="text-sm font-bold text-gray-300 mb-10 relative z-10 leading-relaxed">
                            Un Administrador ha forzado la liberación total de tu terminal.<br/><br/>
                            <span className="text-red-400">Has sido desconectado por seguridad.</span>
                        </p>
                        <div className="flex justify-center relative z-10">
                            <button 
                                onClick={() => {
                                    if (onForceLogout) onForceLogout();
                                    else window.location.reload();
                                }}
                                className="w-full py-5 rounded-3xl bg-red-600 hover:bg-red-500 border border-red-500/50 font-black uppercase text-xs tracking-[0.2em] text-white transition-all shadow-[0_10px_40px_rgba(220,38,38,0.4)]"
                            >
                                SALIR AL LOGIN
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Toast de confirmación no-bloqueante */}
            {toastMessage && (
                <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-[300] animate-in slide-in-from-bottom-4 fade-in duration-500">
                    <div className="bg-[#c1d72e] text-black px-10 py-4 rounded-2xl shadow-[0_20px_60px_rgba(193,215,46,0.4)] font-black text-sm uppercase tracking-wider flex items-center gap-3">
                        {toastMessage}
                    </div>
                </div>
            )}

            {/* Modal de Conflicto de Versión */}
            {showCollisionModal && (
                <CollisionModal onClose={() => setShowCollisionModal(false)} />
            )}
        </div>
    );
};
