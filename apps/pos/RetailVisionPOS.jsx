import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { OpenAccountsCorkboard } from './OpenAccountsCorkboard';
import { posService } from './services/POSService';
import { useCart } from './hooks/useCart';
import { useVision } from './hooks/useVision';
import { useTerminalLocking } from './hooks/useTerminalLocking';
import { useBeforeUnload } from './hooks/useBeforeUnload';
import { useBarcodeScanner } from './hooks/useBarcodeScanner';
import { useAutoSave } from './hooks/useAutoSave';
import { useNetworkHealth } from './hooks/useNetworkHealth';
import { useOfflineSync } from './hooks/useOfflineSync';
import { resilientCreateTicket } from './services/resilientFetch';
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
import { DraftsCorkboard } from './components/DraftsCorkboard';
import { ForceLogoutModal, OfflineBanner, ToastNotification } from './components/POSOverlays';
import { POSHeader } from './components/POSHeader';
import { cashService } from './services/cashService';

import { INITIAL_CATEGORIES, getProductEmoji, terminals } from './utils/posConstants';
import { generateTicketHTML } from './utils/ticketGenerator';

export const RetailVisionPOS = ({ currentUser, onForceLogout, assignedTerminal }) => {
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
    // v5.2 DRAFT: Pizarrón Alterno de Borradores
    const [showDraftCorkboard, setShowDraftCorkboard] = useState(false);
    const [terminalDrafts, setTerminalDrafts] = useState([]);
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
    const { status: netStatus, latency: netLatency } = useNetworkHealth(15000);

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
        
        // REGLA DE NEGOCIO (Zero-Auto-Restore): 
        // A petición del usuario, la terminal SIEMPRE inicia en blanco.
        // Si hubo un corte de luz, un F5, o el usuario salió de golpe, 
        // NO se recupera la cuenta automáticamente en la pantalla principal.
        // Todo trabajo interrumpido queda como DRAFT en el servidor gracias
        // al auto-save, y DEBE ser recuperado manualmente desde el 
        // Pizarrón de Borradores.
        
        console.log(`🧹 Inicializando Terminal ${selectedTerminal}. Descartando caché local para iniciar en blanco...`);
        
        localStorage.removeItem(`pos_session_${selectedTerminal}`);
        localStorage.removeItem(`pos_cart_${selectedTerminal}`);
        
        clearCart();
        setCurrentAccountNum('');
        setOriginalCapturer(null);
        setOrderType('VENTA_DIRECTA');
        setOrderData(null);
        
    }, [selectedTerminal]); // EJECUTAR SOLO AL INICIAR LA TERMINAL

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
                        handleTicketAction('DRAFT', null, false)
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

            // v5.0 DRAFT: Eliminada verificación intrusiva (Reemplazado por Pizarrón Alterno)
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
        onSave: () => handleTicketAction('DRAFT', null, false)
    });

    useBeforeUnload(cartRef, accountNumRef, CONFIG.API_BASE_URL);

    // v5.1 OFFLINE RESILIENCY: Sincronizador de cola offline
    const { pendingCount: offlinePending, isSyncing: isOfflineSyncing } = useOfflineSync({
        netStatus,
        createTicketFn: (payload) => posService.createTicket(payload),
        ticketVersionRef,
        setTicketVersion,
        accountNumRef
    });

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
                    // v5.1 OFFLINE RESILIENCY: Envolver con wrapper resiliente
                    // Si la red falla y es DRAFT → se encola localmente
                    // Si la red falla y es PAID/OPEN → falla ruidosamente (requiere confirmación)
                    savedTicket = await resilientCreateTicket(
                        (p) => posService.createTicket(p),
                        payload
                    );
                    
                    // v5.1: Si fue encolado offline, no tenemos respuesta del servidor
                    if (savedTicket?.queued) {
                        console.log(`📥 Auto-save encolado offline: ${savedTicket.localId}`);
                        setLastSaveStatus('queued');
                        // NO actualizar version — no tenemos confirmación del servidor
                        // NO limpiar carrito — seguimos en modo captura
                        return;
                    }
                } catch (err) {
                    const errorMessage = err.message || "";
                    if (errorMessage.includes("ya ha sido pagado")) {
                        const oldFolio = targetAccountNum;
                        console.warn(`⚠️ Colisión de folio detectada: ${oldFolio} ya pagado. Autogenerando nuevo...`);
                        const newAccountNum = await generateNewAccountNum();
                        targetAccountNum = newAccountNum;
                        // generateNewAccountNum ya sincroniza accountNumRef (v4.3)
                        payload.account_num = newAccountNum;
                        payload.version = null; // Ticket nuevo, sin versión
                        savedTicket = await posService.createTicket(payload);
                        // v4.8: ALERTA PROMINENTE al cajero para evitar confusión de folios
                        setToastMessage(`⚠️ ATENCIÓN: El folio ${oldFolio} ya no estaba disponible. Se reasignó a ${newAccountNum}. Verifique antes de cobrar.`);
                        setTimeout(() => setToastMessage(null), 12000); // 12 segundos — muy visible
                    } else if (errorMessage.includes("Conflicto de versión")) {
                        // v4.7: AUTO-HEALING UI
                        // Si la terminal detecta conflicto (ej. cajero carga ticket incompleto y vendedor lo termina),
                        // en lugar de bloquear con el modal, auto-descargamos la versión más reciente
                        // y actualizamos la pantalla del cajero instantáneamente.
                        if (targetAccountNum) {
                            try {
                                console.log(`🔄 Auto-Healing: Descargando versión fresca de ${targetAccountNum}...`);
                                const liveTicket = await posService.getTicketByAccountNum(targetAccountNum);
                                if (liveTicket && liveTicket.items) {
                                    // Setear isRecoveringRef para evitar auto-saves accidentales
                                    isRecoveringRef.current = true;
                                    
                                    const recovered = liveTicket.items.map(i => {
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
                                    cartRef.current = recovered;  // ⚡ SYNC inmediato
                                    setCart(recovered);
                                    ticketVersionRef.current = liveTicket.version;
                                    setTicketVersion(liveTicket.version);
                                    
                                    setToastMessage("⚠️ ¡Atención! El vendedor modificó esta cuenta. Totales actualizados.");
                                    setTimeout(() => setToastMessage(null), 5000);
                                    setShowCheckout(false);
                                    setIsSendingToPizarron(false);  // ⚡ Limpiar UI (el finally interno no se ejecuta con return)
                                    
                                    requestAnimationFrame(() => {
                                        isRecoveringRef.current = false;
                                    });
                                    return; // Abortar este guardado fallido pacíficamente
                                }
                            } catch (e) {
                                console.error("Error auto-recovering ticket", e);
                            }
                        }

                        // Si el auto-heal falla por desconexión, caemos al modal original como fallback
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
        // ⚡ v4.5 FLUSH DE SEGURIDAD: Si hay una cuenta activa con artículos,
        // guardarla al servidor ANTES de sobreescribir el carrito.
        // Esto previene la pérdida de datos cuando el auto-save no alcanzó a disparar
        // (efecto debounce: el timer se reiniciaba con cada producto escaneado).
        if (accountNumRef.current && cartRef.current.length > 0) {
            try {
                console.log(`🔒 FLUSH: Guardando cuenta activa ${accountNumRef.current} (${cartRef.current.length} items) antes de cambiar...`);
                await handleTicketAction('DRAFT', null, false);
                console.log(`✅ FLUSH exitoso.`);
            } catch (e) {
                console.error(`⚠️ FLUSH falló para ${accountNumRef.current}:`, e);
                // No abortar la recuperación — los items ya están en cartRef y se pueden reintentar
            }
        }

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
        cartRef.current = recovered;  // ⚡ SYNC inmediato: el auto-save NUNCA debe leer el carrito viejo
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
        setShowDraftCorkboard(false); // Cerrar pizarrón alterno si estaba abierto

        // v3.0: Desbloquear auto-save DESPUÉS de que React procese todos los setState batched
        requestAnimationFrame(() => {
            isRecoveringRef.current = false;
        });
    };

    // v5.2 DRAFT: Handlers para el Pizarrón Alterno de Borradores
    const handleLoadDraft = (draft) => {
        const account = {
            accountNum: draft.account_num,
            rawItems: draft.items,
            version: draft.version,
            capturedById: draft.captured_by_id,
            capturedByName: draft.captured_by_name || draft.captured_by?.name,
            orderType: draft.order_type,
            deliveryType: draft.delivery_type,
            clientName: draft.customer_name,
            customerPhone: draft.customer_phone,
            committedAt: draft.committed_at,
            packagingType: draft.packaging_type,
            deliveryAddress: draft.delivery_address,
            orderNotes: draft.order_notes
        };
        handleRecoverAccount(account);
    };

    const handleDiscardDraft = async (draft) => {
        try {
            const terminalId = selectedTerminal || 'T1';
            let session = await posService.getActiveSession(terminalId);
            if (!session) session = await posService.createSession(terminalId);
            await posService.createTicket({
                account_num: draft.account_num,
                session_id: session.id,
                items: draft.items.map(i => ({ product_id: i.product.id, quantity: i.quantity })),
                status: 'CANCELLED',
                captured_by_id: draft.captured_by_id,
                version: draft.version
            });
            setToastMessage('🗑️ Borrador descartado.');
            setTimeout(() => setToastMessage(null), 3000);
            
            // Actualizar lista para UI fluida
            setTerminalDrafts(prev => prev.filter(d => d.account_num !== draft.account_num));
        } catch (e) {
            console.error("Error cancelando borrador:", e);
        }
    };

    useEffect(() => {
        if (!showDraftCorkboard) return;

        const fetchDrafts = async () => {
            try {
                const targetTerminal = selectedTerminal === 'CAJA' ? 'ALL' : selectedTerminal;
                const drafts = await posService.getTerminalDrafts(targetTerminal);
                setTerminalDrafts(drafts || []);
            } catch (e) {
                console.error("Error fetching drafts", e);
            }
        };

        fetchDrafts();
        const interval = setInterval(fetchDrafts, 5000);
        return () => clearInterval(interval);
    }, [showDraftCorkboard, selectedTerminal]);

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
                assignedTerminal={assignedTerminal}
            />
        );
    }

    // --- Handler para cambio de terminal (extraído del header inline) ---
    const handleTerminalSwitch = async () => {
        const canSwitch = !assignedTerminal || currentUser?.role === 'ADMIN' || currentUser?.permissions?.access_any_terminal === 'full';
        if (!canSwitch) return;
        try {
            await posService.unlockTerminal(selectedTerminal, currentUser?.id);
        } catch(e) { console.error("Could not unlock terminal", e); }
        
        // v5.2 DRAFT: Limpieza explícita del estado local para no dejar la terminal "sucia"
        try {
            localStorage.removeItem(`pos_session_${selectedTerminal}`);
            localStorage.removeItem(`pos_cart_${selectedTerminal}`);
            clearCart();
            setCurrentAccountNum('');
            setOriginalCapturer(null);
        } catch(e) {}

        setSelectedTerminal(null);
    };

    // --- Componentes Locales (Mantenidos para preservar Grid estable) ---
    // ProductCard y ProductGrid han sido extraídos a sus propios archivos.

    return (
        <div className="flex flex-col h-full bg-transparent text-white overflow-hidden">
            <POSHeader
                selectedTerminal={selectedTerminal}
                currentUser={currentUser}
                assignedTerminal={assignedTerminal}
                netStatus={netStatus}
                netLatency={netLatency}
                currentAccountNum={currentAccountNum}
                cartLength={cart.length}
                orderType={orderType}
                orderData={orderData}
                isCashEnabled={isCashEnabled}
                visibleAccountsCount={visibleAccounts.length}
                lastSaveStatus={lastSaveStatus}
                lastSaveTime={lastSaveTime}
                categories={categories}
                activeCategory={activeCategory}
                viewMode={viewMode}
                onTerminalSwitch={handleTerminalSwitch}
                onOrderTypeChange={setOrderType}
                onOrderDataClear={() => setOrderData(null)}
                onOpenProgramacion={() => setShowProgramacion(true)}
                onOpenGestorCaja={() => setShowGestorCaja(true)}
                onOpenCorkboard={() => setShowCorkboard(true)}
                onCategoryChange={setActiveCategory}
                onViewModeChange={setViewMode}
                onPageChange={setCurrentPage}
            />

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
                    onOpenDrafts={() => setShowDraftCorkboard(true)}
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

            {/* Overlays globales (extraídos a POSOverlays.jsx) */}
            <ForceLogoutModal visible={forceLogoutModal} onForceLogout={onForceLogout} />
            <OfflineBanner pendingCount={offlinePending} isSyncing={isOfflineSyncing} />
            <ToastNotification message={toastMessage} />

            {/* Modal de Conflicto de Versión */}
            {showCollisionModal && (
                <CollisionModal onClose={() => setShowCollisionModal(false)} />
            )}

            {/* v5.2 DRAFT: Pizarrón Alterno de Borradores */}
            {showDraftCorkboard && (
                <DraftsCorkboard
                    drafts={terminalDrafts}
                    onLoadDraft={handleLoadDraft}
                    onDiscardDraft={handleDiscardDraft}
                    onClose={() => setShowDraftCorkboard(false)}
                    onBackToMain={() => {
                        setShowDraftCorkboard(false);
                        setShowCorkboard(true);
                    }}
                />
            )}
        </div>
    );
};
