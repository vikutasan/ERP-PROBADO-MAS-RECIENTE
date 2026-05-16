import React, { useState, useEffect, useCallback } from 'react';
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
import { usePOSSession } from './hooks/usePOSSession';
import { useTicketActions } from './hooks/useTicketActions';
import { CONFIG } from './config';

// Sub-componentes
import { ProductGrid } from './components/ProductGrid';
import { SalesReceipt } from './components/SalesReceipt';
import { VisionVisor } from './components/VisionVisor';
import { CheckoutScreen } from './components/CheckoutScreen';
import { GestorDeCaja } from './components/GestorDeCaja';
import { TerminalSelector } from './components/TerminalSelector';
import { ProgramacionPedidoModal } from './components/ProgramacionPedidoModal';
import { CollisionModal } from './components/CollisionModal';
import { DraftsCorkboard } from './components/DraftsCorkboard';
import { ForceLogoutModal, OfflineBanner, ToastNotification } from './components/POSOverlays';
import { POSHeader } from './components/POSHeader';
import { cashService } from './services/cashService';

import { generateTicketHTML } from './utils/ticketGenerator';

export const RetailVisionPOS = ({ currentUser, onForceLogout, assignedTerminal }) => {
    // --- Estado ---
    const [selectedTerminal, setSelectedTerminal] = useState(null);
    const [showCorkboard, setShowCorkboard] = useState(false);
    const [currentAccountNum, setCurrentAccountNum] = useState('');
    const [viewMode, setViewMode] = useState('CAMERA');
    const [currentPage, setCurrentPage] = useState(1);
    const [allOpenAccounts, setAllOpenAccounts] = useState([]);
    const [showCheckout, setShowCheckout] = useState(false);
    const [paymentsHistory, setPaymentsHistory] = useState([]);
    const [originalCapturer, setOriginalCapturer] = useState(null);
    const [toastMessage, setToastMessage] = useState(null);
    // v4.0 ZERO-LOSS: Estado de guardado y loading
    const [lastSaveStatus, setLastSaveStatus] = useState('idle');
    const [lastSaveTime, setLastSaveTime] = useState(null);
    const [isSendingToPizarron, setIsSendingToPizarron] = useState(false);
    const [ticketVersion, setTicketVersion] = useState(null);
    const [showCollisionModal, setShowCollisionModal] = useState(false);
    // v5.2 DRAFT: Pizarrón Alterno de Borradores
    const [showDraftCorkboard, setShowDraftCorkboard] = useState(false);
    const [terminalDrafts, setTerminalDrafts] = useState([]);
    const savedTicketRef = React.useRef(null);
    const cartRef = React.useRef([]);
    const accountNumRef = React.useRef('');
    const originalCapturerRef = React.useRef(null);
    const isGeneratingFolioRef = React.useRef(false);
    const isRecoveringRef = React.useRef(false);
    const ticketVersionRef = React.useRef(null);
    const actionMutexRef = React.useRef(Promise.resolve());

    // --- Estado de Ocupación de Terminales (Custom Hook) ---
    const { terminalStatuses, setTerminalStatuses, forceLogoutModal, setForceLogoutModal } = useTerminalLocking(selectedTerminal, currentUser);
    const { status: netStatus, latency: netLatency } = useNetworkHealth(15000);

    // --- Estado del Gestor de Caja ---
    const [isCashEnabled, setIsCashEnabled] = useState(false);
    const [showGestorCaja, setShowGestorCaja] = useState(false);
    const [cashSessionId, setCashSessionId] = useState(null);

    // --- Estado de Tipo de Venta (Venta Directa vs Pedido) ---
    const [orderType, setOrderType] = useState('VENTA_DIRECTA');
    const [showProgramacion, setShowProgramacion] = useState(false);
    const [orderData, setOrderData] = useState(null);

    // --- Hook de Sesión: catálogo, folio, inicialización ---
    const clearCartRef = React.useRef(null);
    const { categories, initialProducts, PRODUCTS, activeCategory, setActiveCategory, generateNewAccountNum } = usePOSSession({
        selectedTerminal,
        currentUser,
        clearCartRef,
        accountNumRef,
        originalCapturerRef,
        ticketVersionRef,
        isGeneratingFolioRef,
        setCurrentAccountNum,
        setOriginalCapturer,
        setTicketVersion,
        setToastMessage,
        setOrderType,
        setOrderData,
    });

    const { cart, setCart, total, addToCart, updateQuantity, removeFromCart, clearCart } = useCart(PRODUCTS, selectedTerminal);
    clearCartRef.current = clearCart;
    const { isScanning, setIsScanning } = useVision();

    // --- Mantener refs sincronizadas con state (anti-stale-closure) ---
    React.useEffect(() => { cartRef.current = cart; }, [cart]);
    React.useEffect(() => { accountNumRef.current = currentAccountNum; }, [currentAccountNum]);
    React.useEffect(() => { originalCapturerRef.current = originalCapturer; }, [originalCapturer]);
    React.useEffect(() => { ticketVersionRef.current = ticketVersion; }, [ticketVersion]);

    // --- Persistencia de Metadatos de Sesión ---
    useEffect(() => {
        if (!selectedTerminal) return;
        const sessionKey = `pos_session_${selectedTerminal}`;
        try {
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

    // --- Hook de Tickets: toda la lógica de negocio ---
    const { handleTicketAction, handlePrintTicket, handleAddToCart, handleRecoverAccount, handleLoadDraft, handleDiscardDraft } = useTicketActions({
        selectedTerminal,
        currentUser,
        currentAccountNum,
        orderType,
        orderData,
        cashSessionId,
        cartRef,
        accountNumRef,
        originalCapturerRef,
        ticketVersionRef,
        isGeneratingFolioRef,
        isRecoveringRef,
        actionMutexRef,
        savedTicketRef,
        addToCart,
        setCart,
        clearCart,
        cart,
        total,
        initialProducts,
        generateNewAccountNum,
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
        paymentsHistory,
    });

    // --- Efectos de sincronización ---
    useEffect(() => {
        if (selectedTerminal) {
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
        onSave: () => handleTicketAction('DRAFT', null, false)
    });

    useBeforeUnload(cartRef, accountNumRef, CONFIG.API_BASE_URL);

    const { pendingCount: offlinePending, isSyncing: isOfflineSyncing } = useOfflineSync({
        netStatus,
        createTicketFn: (payload) => posService.createTicket(payload),
        ticketVersionRef,
        setTicketVersion,
        accountNumRef
    });

    useBarcodeScanner(PRODUCTS, handleAddToCart);

    // --- Polling de Borradores ---
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

    // --- Polling de Cuentas Abiertas ---
    useEffect(() => {
        if (!showCorkboard) return;
        const fetchOpenAccounts = () => {
            posService.getOpenTickets().then(data => {
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
                    version: t.version || 1,
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

    // --- Renderizado ---
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

    const handleTerminalSwitch = async () => {
        const canSwitch = !assignedTerminal || currentUser?.role === 'ADMIN' || currentUser?.permissions?.access_any_terminal === 'full';
        if (!canSwitch) return;
        try {
            await posService.unlockTerminal(selectedTerminal, currentUser?.id);
        } catch(e) { console.error("Could not unlock terminal", e); }
        try {
            localStorage.removeItem(`pos_session_${selectedTerminal}`);
            localStorage.removeItem(`pos_cart_${selectedTerminal}`);
            clearCart();
            setCurrentAccountNum('');
            setOriginalCapturer(null);
        } catch(e) {}
        setSelectedTerminal(null);
    };

    // --- FASE 2: Wrappers con persistencia inmediata ---
    const handleUpdateQuantity = async (productId, newQuantity) => {
        updateQuantity(productId, newQuantity); // UI instantánea
        if (!accountNumRef.current) return;
        try {
            const result = await posService.updateItemQuantity({
                account_num: accountNumRef.current,
                product_id: productId,
                new_quantity: newQuantity,
                version: ticketVersionRef.current
            });
            if (result?.version) {
                ticketVersionRef.current = result.version;
                setTicketVersion(result.version);
            }
            setLastSaveStatus('saved');
            setLastSaveTime(new Date());
        } catch (e) {
            console.warn('Update quantity persistence failed:', e);
            setLastSaveStatus('failed');
        }
    };

    const handleRemoveFromCart = async (productId) => {
        removeFromCart(productId); // UI instantánea
        if (!accountNumRef.current) return;
        try {
            const result = await posService.removeItemFromTicket({
                account_num: accountNumRef.current,
                product_id: productId,
                version: ticketVersionRef.current
            });
            if (result?.version) {
                ticketVersionRef.current = result.version;
                setTicketVersion(result.version);
            }
            setLastSaveStatus('saved');
            setLastSaveTime(new Date());
        } catch (e) {
            console.warn('Remove item persistence failed:', e);
            setLastSaveStatus('failed');
        }
    };

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
                    removeFromCart={handleRemoveFromCart} 
                    updateQuantity={handleUpdateQuantity}
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
                        await handleTicketAction('PAID', method, true);
                    }}
                    onClose={() => setShowCheckout(false)}
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

            <ForceLogoutModal visible={forceLogoutModal} onForceLogout={onForceLogout} />
            <OfflineBanner pendingCount={offlinePending} isSyncing={isOfflineSyncing} />
            <ToastNotification message={toastMessage} />

            {showCollisionModal && (
                <CollisionModal onClose={() => setShowCollisionModal(false)} />
            )}

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
