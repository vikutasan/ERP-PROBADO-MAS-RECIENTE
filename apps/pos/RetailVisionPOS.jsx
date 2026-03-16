import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { OpenAccountsCorkboard } from './OpenAccountsCorkboard';
import { posService } from './services/POSService';
import { useCart } from './hooks/useCart';
import { useVision } from './hooks/useVision';
import { CONFIG } from './config';

// Sub-componentes
import { CategoryBar } from './components/CategoryBar';
import { SalesReceipt } from './components/SalesReceipt';
import { VisionVisor } from './components/VisionVisor';
import { CheckoutScreen } from './components/CheckoutScreen';
import { TicketTemplate } from './components/TicketTemplate';
import { GestorDeCaja } from './components/GestorDeCaja';
import { cashService } from './services/cashService';

const INITIAL_CATEGORIES = [
    { name: "1.-EMPAQUE Y PAN BLANCO", icon: "🥖", visionEnabled: true },
    { name: "2.-A - B", icon: "🍪", visionEnabled: true },
    { name: "3.-C - D", icon: "🍩", visionEnabled: true },
    { name: "4.-E - K", icon: "🥐", visionEnabled: true },
    { name: "5.-L - M", icon: "🧁", visionEnabled: true },
    { name: "6.-N - P", icon: "🥧", visionEnabled: true },
    { name: "7.-R - S", icon: "🍰", visionEnabled: true },
    { name: "8.-T - Z", icon: "🥨", visionEnabled: true },
    { name: "17.-ROSCA DE REYES", icon: "👑", visionEnabled: true },
    { name: "9.-LACTEOS", icon: "🥛", visionEnabled: false },
    { name: "10.-SOBRE PEDIDO", icon: "🎂", visionEnabled: false },
    { name: "11.-ESPORADICOS", icon: "🎁", visionEnabled: false },
    { name: "12.-CAFES Y CHOCOLATES", icon: "☕", visionEnabled: false },
    { name: "13.-SOUVENIRS", icon: "🛍️", visionEnabled: false },
    { name: "14.-HELADOS", icon: "🍨", visionEnabled: false },
    { name: "15.-PALETAS", icon: "🍭", visionEnabled: false },
    { name: "16.-AGUAS Y MALTEADAS", icon: "🥤", visionEnabled: false }
];

const getProductEmoji = (p) => {
    const name = (p.name || '').toUpperCase();
    const categoryObj = p.category;
    const catName = (typeof categoryObj === 'string' ? categoryObj : (categoryObj?.name || 'GENERAL')).toUpperCase();
    
    if (catName.includes('LACTEOS') || name.includes('LECHE')) return '🥛';
    if (name.includes('CAF')) return '☕';
    if (name.includes('AGUA')) return '💧';
    if (name.includes('HELADO')) return '🍨';
    if (name.includes('PALETA')) return '🍭';
    if (name.includes('MALTEADA')) return '🥤';
    if (name.includes('PASTEL') || name.includes('TARTA')) return '🍰';
    if (name.includes('ROSCA')) return '👑';
    if (name.includes('DONA')) return '🍩';
    if (name.includes('CONCHA')) return '🥯';
    if (name.includes('BOLILLO') || name.includes('TELERA') || name.includes('BAGUETTE')) return '🥖';
    if (name.includes('CROISSANT') || name.includes('CUERNITO')) return '🥐';
    if (name.includes('GALLETA') || name.includes('POLVORON')) return '🍪';
    if (name.includes('MUFFIN') || name.includes('MAGDALENA')) return '🧁';
    if (catName.includes('PAN')) return '🍞';
    return '📦';
};

const terminals = [
    { id: 'T6', name: 'Terminal 6', icon: '🖥️' },
    { id: 'T5', name: 'Terminal 5', icon: '🖥️' },
    { id: 'T4', name: 'Terminal 4', icon: '🖥️' },
    { id: 'T3', name: 'Terminal 3', icon: '🖥️' },
    { id: 'T2', name: 'Terminal 2', icon: '🖥️' },
    { id: 'CAJA', name: 'CAJA', icon: '/assets/pos_register.png' }
];

export const RetailVisionPOS = () => {
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
    const printRef = React.useRef();

    // --- Estado del Gestor de Caja ---
    const [isCashEnabled, setIsCashEnabled] = useState(false);
    const [showGestorCaja, setShowGestorCaja] = useState(false);
    const [cashSessionId, setCashSessionId] = useState(null);

    // --- Hooks Personalizados ---
    const PRODUCTS = useMemo(() => initialProducts.map(p => ({
        ...p,
        id: p.id, 
        image: getProductEmoji(p),
        category: p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : 'OTROS'
    })), [initialProducts]);

    const { cart, setCart, total, addToCart, updateQuantity, removeFromCart, clearCart } = useCart(PRODUCTS);
    const { isScanning, setIsScanning } = useVision();

    // --- Efectos de Carga ---
    useEffect(() => {
        const loadInitialData = async () => {
            try {
                const catData = await posService.getCategories();
                const normalized = catData
                    .filter(c => c.name !== 'TODOS')
                    .map(c => {
                        const original = INITIAL_CATEGORIES.find(ic => ic.name === c.name);
                        return { ...c, icon: c.icon || (original ? original.icon : '📦') };
                    });
                setCategories(normalized);
                if (normalized.length > 0 && !activeCategory) setActiveCategory(normalized[0].name);

                const prodData = await posService.getProducts();
                setInitialProducts(prodData);
            } catch (error) {
                console.error("Fetch error:", error);
                alert("Error conectando con el ERP. Verifique que el servidor este activo.");
            }
        };
        loadInitialData();
    }, []);

    const generateNewAccountNum = useCallback(async () => {
        try {
            const terminalId = selectedTerminal || 'T1';
            const ticket = await posService.reserveTicket(terminalId);
            setCurrentAccountNum(ticket.account_num);
        } catch (error) {
            console.error("Error reservando cuenta oficial, usando fallback:", error);
            const num = Math.floor(1000 + Math.random() * 9000);
            setCurrentAccountNum(`V${num}`);
        }
    }, [selectedTerminal]);

    useEffect(() => {
        if (selectedTerminal) {
            if (!currentAccountNum) generateNewAccountNum();
            
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

    // --- Teclado (Barcode) ---
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
                    const prod = PRODUCTS.find(p => p.barcode === buffer || p.id.toString() === buffer);
                    if (prod) addToCart(prod);
                    buffer = '';
                }
            } else if (e.key.length === 1) buffer += e.key;
        };
        window.addEventListener('keydown', handleKeys);
        return () => window.removeEventListener('keydown', handleKeys);
    }, [PRODUCTS, addToCart]);

    // --- Lógica de Negocio (Tickets) ---
    const handlePrintTicket = () => {
        const printContent = printRef.current;
        
        // Crear un iframe invisible
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
        doc.write('<html><head><title>Ticket R de Rico</title>');
        doc.write('<link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">');
        doc.write('</head><body>');
        doc.write(printContent.innerHTML);
        doc.write('</body></html>');
        doc.close();

        // Esperar a que el CSS cargue y disparar impresión en el iframe
        setTimeout(() => {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
            
            // Limpiar el iframe después de un tiempo prudencial
            setTimeout(() => {
                document.body.removeChild(iframe);
            }, 1000);
        }, 250);
    };

    const handleTicketAction = async (status, paymentData = null, finalizeUI = true) => {
        if (cart.length === 0) return alert("El ticket esta vacio.");
        
        // Si no hay datos de pago y se intenta cobrar, abrir pantalla de pago
        if (status === 'PAID' && (!paymentData || paymentData.length === 0)) {
            setShowCheckout(true);
            return;
        }

        try {
            if (paymentData) setPaymentsHistory(paymentData);
            const terminalId = selectedTerminal || 'T1';
            let session = await posService.getActiveSession(terminalId);
            if (!session) session = await posService.createSession(terminalId);

            const payload = {
                account_num: currentAccountNum,
                session_id: session.id,
                items: cart.map(i => ({ product_id: i.id, quantity: i.quantity || 1 })),
                status: status,
                payment_details: paymentData,
                cash_session_id: cashSessionId
            };

            await posService.createTicket(payload);
            
            if (finalizeUI) {
                if (status === 'PAID') {
                    handlePrintTicket();
                    alert(`Venta finalizada exitosamente. Ticket impreso.`);
                }
                clearCart();
                generateNewAccountNum();
                setShowCheckout(false);
                setPaymentsHistory([]);
            }
        } catch (error) {
            console.error("Ticket action error:", error);
            alert(error.message);
            throw error; // Propagar para que CheckoutScreen interrumpa el proceso visual.
        }
    };

    const handleRecoverAccount = (account) => {
        if (!account.rawItems?.length) return alert("Cuenta vacia.");
        const recovered = account.rawItems.map(i => ({
            id: i.product.id,
            name: i.product.name,
            price: i.product.price,
            quantity: i.quantity,
            category: i.product.category?.name || 'OTROS'
        }));
        setCart(recovered);
        setCurrentAccountNum(account.accountNum);
        setShowCorkboard(false);
    };

    useEffect(() => {
        if (showCorkboard) {
            posService.getOpenTickets().then(data => {
                setAllOpenAccounts(data.map(t => ({
                    id: t.account_num,
                    accountNum: t.account_num,
                    terminal: t.terminal_id || 'T1',
                    total: t.total,
                    items: t.items.length,
                    rawItems: t.items,
                    timestamp: t.created_at,
                    cashierName: 'Operador',
                    clientName: 'Público General'
                })));
            }).catch(console.error);
        }
    }, [showCorkboard]);

    const visibleAccounts = selectedTerminal === 'CAJA' ? allOpenAccounts : allOpenAccounts.filter(a => a.terminal === selectedTerminal);

    // --- Renderizado de Pantalla Inicial ---
    if (!selectedTerminal) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center p-20 animate-in fade-in zoom-in-95 duration-700">
                <div className="text-center mb-16">
                    <h3 className="text-orange-500 font-black uppercase tracking-[0.5em] text-xs mb-4">Configuracion de Estacion</h3>
                    <h2 className="text-6xl font-black uppercase tracking-tighter italic">Selecciona tu <span className="text-white/20">Terminal</span></h2>
                </div>
                <div className="grid grid-cols-3 md:grid-cols-6 gap-8 max-w-7xl w-full">
                    {terminals.map(t => (
                        <button key={t.id} onClick={() => setSelectedTerminal(t.id)} className="group relative bg-black/20 hover:bg-orange-600 transition-all duration-500 p-10 rounded-[40px] border border-white/5 hover:border-orange-400 flex flex-col items-center gap-6 shadow-2xl hover:scale-110">
                            <div className="w-24 h-24 flex items-center justify-center bg-white/5 group-hover:bg-white/20 rounded-3xl transition-colors">
                                {t.icon.endsWith('.png') ? <img src={t.icon} alt={t.name} className="w-16 h-16 object-contain" /> : <span className="text-4xl">{t.icon}</span>}
                            </div>
                            <div className="text-center">
                                <span className="block text-2xl font-black italic uppercase group-hover:text-white transition-colors">{t.name === 'CAJA' ? 'CAJA' : t.name.split(' ')[1]}</span>
                                <span className="text-[8px] font-bold text-gray-500 uppercase tracking-widest group-hover:text-orange-200">{t.name === 'CAJA' ? 'Cajero Central' : 'Punto de Venta'}</span>
                            </div>
                        </button>
                    ))}
                </div>
            </div>
        );
    }

    // --- Componentes Locales (Mantenidos para preservar Grid estable) ---
    const ProductCard = ({ product }) => {
        const [imgStatus, setImgStatus] = useState('TRY_PNG'); // TRY_PNG, TRY_JPG, FALLBACK
        const baseStaticUrl = CONFIG.API_BASE_URL.replace('/api/v1', '/static/catalog');
        const pngUrl = `${baseStaticUrl}/Img1118_${product.sku}.png`;
        const jpgUrl = `${baseStaticUrl}/Img1118_${product.sku}.jpg`;

        return (
            <button onClick={() => addToCart(product)} className="group relative bg-black hover:bg-[#c1d72e] p-3 rounded-[35px] border border-white/10 transition-all duration-500 flex flex-col items-center justify-between gap-2 hover:scale-105 active:scale-95 shadow-[0_4px_20px_rgba(0,0,0,0.6)] hover:shadow-[#c1d72e]/20 h-full w-full">
                {/* Imagen expandida con menos márgenes */}
                <div className="w-full h-32 flex items-center justify-center mt-1">
                    {imgStatus === 'TRY_PNG' && (
                        <img 
                            src={pngUrl} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('TRY_JPG')}
                        />
                    )}
                    {imgStatus === 'TRY_JPG' && (
                        <img 
                            src={jpgUrl} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('FALLBACK')}
                        />
                    )}
                    {imgStatus === 'FALLBACK' && (
                        <div className="text-6xl group-hover:scale-110 transition-transform">{product.image}</div>
                    )}
                </div>
                
                {/* Nombre y Precio reestructurados */}
                <div className="text-center w-full flex flex-col items-center gap-1.5 mb-2">
                    <p className="text-xs font-black uppercase leading-tight text-white group-hover:text-black line-clamp-2 px-1 text-shadow-sm">{product.name}</p>
                    <div className="bg-[#c1d72e] group-hover:bg-black px-3 py-0.5 rounded-full shadow-md mt-1">
                        <p className="text-[14px] font-black text-black group-hover:text-[#c1d72e] italic font-mono tracking-tighter">${(product.price || 0).toFixed(2)}</p>
                    </div>
                </div>

                <div className="absolute top-3 right-3 w-6 h-6 bg-white/10 backdrop-blur-sm rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity shadow-inner">
                    <span className="text-black font-black text-xs">+</span>
                </div>
            </button>
        );
    };

    const ProductGrid = ({ category }) => {
        const filtered = PRODUCTS.filter(p => p.category === category);
        const totalPages = Math.ceil(filtered.length / CONFIG.ITEMS_PER_PAGE);
        const paginated = filtered.slice((currentPage - 1) * CONFIG.ITEMS_PER_PAGE, currentPage * CONFIG.ITEMS_PER_PAGE);

        return (
            <div className="flex-1 flex gap-4 overflow-hidden">
                {totalPages > 1 && (
                    <div className="w-16 flex flex-col gap-3 py-2 animate-in fade-in slide-in-from-left-4 duration-500">
                        {Array.from({ length: totalPages }).map((_, i) => (
                            <button key={i + 1} onClick={() => setCurrentPage(i + 1)} className={`w-14 h-14 rounded-full flex items-center justify-center font-black text-lg transition-all border-2 ${currentPage === i + 1 ? 'bg-[#c1d72e] text-black border-[#c1d72e] shadow-lg shadow-[#c1d72e]/40 scale-110' : 'bg-black/40 text-white/40 border-white/10 hover:border-white/30'}`}>{i + 1}</button>
                        ))}
                    </div>
                )}
                <div className="flex-1 overflow-hidden">
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 grid-rows-3 gap-4 h-full">
                        {paginated.map(p => <ProductCard key={p.id} product={p} />)}
                        {paginated.length < CONFIG.ITEMS_PER_PAGE && Array.from({length: CONFIG.ITEMS_PER_PAGE - paginated.length}).map((_, i) => (
                            <div key={`empty-${i}`} className="bg-black/5 rounded-[35px] border border-white/2"></div>
                        ))}
                    </div>
                </div>
            </div>
        );
    };

    return (
        <div className="flex flex-col h-full bg-transparent text-white overflow-hidden">
            {/* Header */}
            <div className="p-4 pb-2 z-20">
                <div className="flex justify-between items-center mb-3">
                    <div className="w-1/3 flex justify-start">
                        <button onClick={() => setSelectedTerminal(null)} className="bg-black/40 backdrop-blur-md border border-white/10 px-4 py-2 rounded-xl flex items-center gap-3 hover:bg-white/10 transition-all group shadow-xl">
                            <div className="w-8 h-8 bg-orange-600/20 rounded-lg flex items-center justify-center text-orange-500 border border-orange-500/20">🖥️</div>
                            <div className="text-left">
                                <p className="text-[9px] font-black text-white/90 uppercase tracking-tighter">Terminal {selectedTerminal}</p>
                                <p className="text-[7px] font-bold text-orange-400 uppercase tracking-widest group-hover:underline">Cambiar Estacion</p>
                            </div>
                        </button>
                    </div>
                    <div className="w-1/3 flex items-center justify-center">
                        <div className="bg-black border border-white/10 px-8 py-2 rounded-3xl shadow-2x flex flex-col items-center">
                            <span className="text-[7px] font-black uppercase text-white tracking-[0.5em] mb-0.5">Transaccion Activa</span>
                            <span className="text-4xl font-black uppercase tracking-tighter italic text-[#c1d72e] drop-shadow-[0_0_12px_rgba(193,215,46,0.4)]">CUENTA #{(currentAccountNum || '00').slice(-2)}</span>
                        </div>
                    </div>
                    <div className="w-1/3 flex justify-end gap-2">
                        {/* Botón CAJA — uso infrecuente, estilo discreto */}
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

                        {/* Botón Pizarrón — uso frecuente, estilo prominente */}
                        <button 
                            onClick={() => setShowCorkboard(true)} 
                            className="bg-[#2d1e13] border border-orange-900/40 px-6 py-2 rounded-xl flex items-center hover:bg-[#3d2b1f] hover:border-orange-500/50 transition-all group shadow-xl"
                        >
                            <div className="text-left">
                                <p className="text-[18px] font-black uppercase text-white tracking-widest leading-none mb-1">Pizarron</p>
                                <p className="text-[14px] font-black text-orange-500 uppercase tracking-tighter leading-none">
                                    {visibleAccounts.length} {selectedTerminal === 'CAJA' ? 'TOTALES' : 'MIAS'}
                                </p>
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
                <div className="flex-1 flex flex-col p-4 pt-0 bg-transparent overflow-hidden">
                    {viewMode === 'CAMERA' ? (
                        <VisionVisor 
                            isScanning={isScanning} 
                            setIsScanning={setIsScanning} 
                            addToCart={addToCart} 
                            products={PRODUCTS} 
                            categories={categories} 
                        />
                    ) : (
                        <div className="flex-1 flex flex-col animate-in fade-in slide-in-from-left-4 duration-500">
                            <div className="flex justify-between items-center mb-6">
                                <h3 className="text-[10px] font-black text-orange-500 uppercase tracking-[0.5em]">{activeCategory}</h3>
                                <div className="bg-white/5 border border-white/10 rounded-full px-4 py-1 text-[10px] font-bold text-white/40">Catalogo Digital</div>
                            </div>
                            <ProductGrid category={activeCategory} />
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
                />
            </div>

            {showCheckout && (
                <CheckoutScreen 
                    total={total}
                    onConfirm={async (method) => {
                        await handleTicketAction('PAID', method, false);
                    }}
                    onClose={() => {
                        setShowCheckout(false);
                    }}
                    onFinish={() => {
                        clearCart();
                        generateNewAccountNum();
                        setShowCheckout(false);
                        setPaymentsHistory([]);
                    }}
                    onPrint={() => {
                        handlePrintTicket();
                        clearCart();
                        generateNewAccountNum();
                        setShowCheckout(false);
                        setPaymentsHistory([]);
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


            {/* Impresora Oculta (Económica) */}
            <div style={{ display: 'none' }}>
                <TicketTemplate 
                    ref={printRef}
                    cart={cart}
                    total={total}
                    payments={paymentsHistory} // Pasar el historial real para el ticket
                    ticket={{ account_num: currentAccountNum }}
                />
            </div>
        </div>
    );
};
