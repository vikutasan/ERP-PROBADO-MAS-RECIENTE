import { useState, useEffect, useCallback, useRef } from 'react';
import { posService } from '../services/POSService';
import { resilientCreateTicket } from '../services/resilientFetch';
import { generateTicketHTML } from '../utils/ticketGenerator';

/**
 * Hook: useTicketActions
 * 
 * Maneja TODA la lógica de negocio de tickets del POS:
 * - handleTicketAction: crear/guardar/pagar tickets con mutex, collision handling, auto-healing
 * - handlePrintTicket: impresión via iframe oculto
 * - handleAddToCart: agregar producto + ZERO-LOSS save inmediato
 * - handleRecoverAccount: recuperación de cuentas del Pizarrón
 * - handleLoadDraft / handleDiscardDraft: gestión de borradores
 * - Polling de cuentas abiertas y borradores
 * 
 * Extraído de RetailVisionPOS.jsx (v5.3 Modularización)
 */
export const useTicketActions = ({
    // Estado compartido
    selectedTerminal,
    currentUser,
    currentAccountNum,
    orderType,
    orderData,
    cashSessionId,
    // Refs compartidas
    cartRef,
    accountNumRef,
    originalCapturerRef,
    ticketVersionRef,
    isGeneratingFolioRef,
    isRecoveringRef,
    actionMutexRef,
    savedTicketRef,
    // Funciones del carrito
    addToCart: cartAddToCart,
    setCart,
    clearCart,
    cart,
    total,
    // initialProducts para mapeo de recovery
    initialProducts,
    // Funciones de sesión
    generateNewAccountNum,
    // Setters de estado UI
    setCurrentAccountNum,
    setOriginalCapturer,
    setTicketVersion,
    setToastMessage,
    setLastSaveStatus,
    setLastSaveTime,
    setShowCheckout,
    setIsSendingToPizarron,
    setShowCollisionModal,
    setPaymentsHistory,
    setOrderType,
    setOrderData,
    setShowCorkboard,
    setShowDraftCorkboard,
    setTerminalDrafts,
    setAllOpenAccounts,
    // Estado de pagos
    paymentsHistory,
}) => {
    const [printTicketData, setPrintTicketData] = useState(null);

    // --- Impresión de Ticket ---
    const handlePrintTicket = useCallback((ticketData = null) => {
        // PRIORIDAD DE DATOS:
        // 1. Datos pasados por argumento (ticket oficial del servidor)
        // 2. Datos guardados en el último ticket impreso (printTicketData)
        // 3. Fallback a estado local (solo si no hay nada más)
        const activeTicket = ticketData || printTicketData || { 
            account_num: currentAccountNum,
            items: cart.map(i => ({ product: { name: i.name }, quantity: i.quantity, unit_price: i.price })),
            total: total,
            payment_details: paymentsHistory,
            captured_by: originalCapturerRef.current || { id: currentUser?.id, name: currentUser?.name || 'SISTEMA' },
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
    }, [printTicketData, currentAccountNum, cart, total, currentUser, selectedTerminal]);

    // --- Acción principal de Tickets (mutex + collision handling + auto-healing) ---
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
                    // el sync directo de ticketVersionRef elimina stale-closures.
                    version: liveVersion
                };

                // Inyectar data del OMS si es pedido
                if (orderType === 'PEDIDO' && orderData) {
                    payload = { ...payload, ...orderData };
                }

                let savedTicket = null;
                try {
                    // v5.1 OFFLINE RESILIENCY: Envolver con wrapper resiliente
                    savedTicket = await resilientCreateTicket(
                        (p) => posService.createTicket(p),
                        payload
                    );
                    
                    // v5.1: Si fue encolado offline, no tenemos respuesta del servidor
                    if (savedTicket?.queued) {
                        console.log(`📥 Auto-save encolado offline: ${savedTicket.localId}`);
                        setLastSaveStatus('queued');
                        return;
                    }
                } catch (err) {
                    const errorMessage = err.message || "";
                    if (errorMessage.includes("ya ha sido pagado")) {
                        const oldFolio = targetAccountNum;
                        console.warn(`⚠️ Colisión de folio detectada: ${oldFolio} ya pagado. Autogenerando nuevo...`);
                        const newAccountNum = await generateNewAccountNum();
                        targetAccountNum = newAccountNum;
                        payload.account_num = newAccountNum;
                        payload.version = null; // Ticket nuevo, sin versión
                        savedTicket = await posService.createTicket(payload);
                        // v4.8: ALERTA PROMINENTE al cajero para evitar confusión de folios
                        setToastMessage(`⚠️ ATENCIÓN: El folio ${oldFolio} ya no estaba disponible. Se reasignó a ${newAccountNum}. Verifique antes de cobrar.`);
                        setTimeout(() => setToastMessage(null), 12000);
                    } else if (errorMessage.includes("Conflicto de versión")) {
                        // v4.7: AUTO-HEALING UI
                        if (targetAccountNum) {
                            try {
                                console.log(`🔄 Auto-Healing: Descargando versión fresca de ${targetAccountNum}...`);
                                const liveTicket = await posService.getTicketByAccountNum(targetAccountNum);
                                if (liveTicket && liveTicket.items) {
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
                                    setIsSendingToPizarron(false);
                                    
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
                
                // v4.2: Actualizar versión SINCRÓNICAMENTE en la ref
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

    // --- Agregar al carrito con ZERO-LOSS save inmediato ---
    const handleAddToCart = (product) => {
        cartAddToCart(product); // UI reacts instantly
        if (!currentAccountNum) {
            // Generar folio Y guardar inmediatamente al servidor
            generateNewAccountNum().then(accountNum => {
                if (accountNum) {
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

    // --- Recuperación de Cuenta del Pizarrón ---
    const handleRecoverAccount = async (account) => {
        // ⚡ v4.5 FLUSH DE SEGURIDAD
        if (accountNumRef.current && cartRef.current.length > 0) {
            try {
                console.log(`🔒 FLUSH: Guardando cuenta activa ${accountNumRef.current} (${cartRef.current.length} items) antes de cambiar...`);
                await handleTicketAction('DRAFT', null, false);
                console.log(`✅ FLUSH exitoso.`);
            } catch (e) {
                console.error(`⚠️ FLUSH falló para ${accountNumRef.current}:`, e);
            }
        }

        // v3.0 FIX — REGLA 3: Bloquear auto-save ANTES de cualquier mutación
        isRecoveringRef.current = true;

        // ⚡ FIX: Obtener siempre la versión más fresca directamente
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
        cartRef.current = recovered;  // ⚡ SYNC inmediato
        setCart(recovered);
        accountNumRef.current = account.accountNum;
        setCurrentAccountNum(account.accountNum);
        
        console.log("Recovering account. Original capturer:", freshCapturer);
        originalCapturerRef.current = freshCapturer || currentUser;
        setOriginalCapturer(freshCapturer || currentUser);
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
        setShowDraftCorkboard(false);

        // v3.0: Desbloquear auto-save DESPUÉS de que React procese todos los setState
        requestAnimationFrame(() => {
            isRecoveringRef.current = false;
        });
    };

    // --- Handlers para Pizarrón Alterno de Borradores ---
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

    return {
        handleTicketAction,
        handlePrintTicket,
        handleAddToCart,
        handleRecoverAccount,
        handleLoadDraft,
        handleDiscardDraft,
        printTicketData,
    };
};
