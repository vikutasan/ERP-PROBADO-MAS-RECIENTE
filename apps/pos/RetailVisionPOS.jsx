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
    const printRef = React.useRef();

    // --- Estado de Ocupación de Terminales ---
    const [terminalStatuses, setTerminalStatuses] = useState({});
    const [unlockingTerminal, setUnlockingTerminal] = useState(null);
    const [deniedModal, setDeniedModal] = useState(null);
    const [forceLogoutModal, setForceLogoutModal] = useState(false);

    // --- Estado del Gestor de Caja ---
    const [isCashEnabled, setIsCashEnabled] = useState(false);
    const [showGestorCaja, setShowGestorCaja] = useState(false);
    const [cashSessionId, setCashSessionId] = useState(null);

    // --- Hooks Personalizados ---
    const PRODUCTS = useMemo(() => initialProducts.map(p => ({
        ...p,
        id: p.id, 
        image: p.image_url,
        emoji: getProductEmoji(p),
        hasRealImage: !!p.image_url,
        category: p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : 'OTROS'
    })), [initialProducts]);

    const { cart, setCart, total, addToCart, updateQuantity, removeFromCart, clearCart } = useCart(PRODUCTS);
    const { isScanning, setIsScanning } = useVision();

    // --- Efectos de Ocupación ---
    // Polling en pantalla principal para ver quién ocupa las terminales
    useEffect(() => {
        let interval;
        const fetchStatuses = async () => {
            if (!selectedTerminal) {
                try {
                    const data = await posService.getTerminalsStatus();
                    setTerminalStatuses(data);
                } catch (e) {
                    console.error("Error fetching terminal status", e);
                }
            }
        };
        fetchStatuses();
        interval = setInterval(fetchStatuses, 3000); // Polling cada 3 segs
        return () => clearInterval(interval);
    }, [selectedTerminal]);

    // Polling de Auto-Expulsión: verifica si un Admin rompió nuestro bloqueo
    useEffect(() => {
        if (!selectedTerminal || forceLogoutModal) return;
        
        const checkMyLock = async () => {
            try {
                const data = await posService.getTerminalsStatus();
                // Si la terminal no aparece en la vida del candado, o el dueño no soy yo...
                const myStatus = data[selectedTerminal];
                if (!myStatus || myStatus.occupier_id !== currentUser?.id) {
                    setForceLogoutModal(true);
                }
            } catch (e) {
                console.error("Polling lock error", e);
            }
        };
        
        const intervalId = setInterval(checkMyLock, 10000); // Checa cada 10 segs
        return () => clearInterval(intervalId);
    }, [selectedTerminal, currentUser, forceLogoutModal]);

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
            // Priorizar el capturador que ya tenga el ticket en el servidor
            if (ticket.captured_by) {
                setOriginalCapturer({
                    id: ticket.captured_by.id,
                    name: ticket.captured_by.name
                });
            } else {
                setOriginalCapturer(currentUser);
            }
        } catch (error) {
            console.error("Error reservando cuenta oficial, usando fallback:", error);
            const num = Math.floor(1000 + Math.random() * 9000);
            setCurrentAccountNum(`V${num}`);
            setOriginalCapturer(currentUser);
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
    const generateTicketHTML = (ticketData) => {
        const dateObj = new Date(ticketData.created_at || new Date());
        const printDate = dateObj.toLocaleDateString();
        const printTime = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        const items = ticketData.items || [];
        const payments = ticketData.payment_details || [];
        
        let totalQty = 0; // Calculador de total artículos

        // Obtener nombres e IDs de todas las fuentes posibles
        const capturedBy = ticketData.captured_by_name || ticketData.captured_by?.name || 'SISTEMA';
        const cashedBy = ticketData.cashed_by_name || ticketData.cashed_by?.name || 'SISTEMA/AUTO';
        
        let itemsHtml = '';
        items.forEach(item => {
            const name = item.product?.name || item.name || 'Articulo';
            const qty = item.quantity || 1;
            totalQty += qty; 
            const price = item.unit_price || item.price || 0;
            itemsHtml += `
                <tr>
                    <td style="width: 28px; font-weight: bold;">${qty}x</td>
                    <td>
                        <div style="font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${name}</div>
                        <div style="font-size: 12pt; font-weight: 900; color: #000;">$${price.toFixed(2)} c/u</div>
                    </td>
                    <td style="text-align: right; font-weight: bold; white-space: nowrap;">$${(price * qty).toFixed(2)}</td>
                </tr>
            `;
        });

        let paymentsHtml = '';
        payments.forEach(p => {
            paymentsHtml += `
                <div style="display: flex; justify-content: space-between;">
                    <span>${p.method}</span>
                    <span>$${(p.amount || 0).toFixed(2)}</span>
                </div>
            `;
        });

        return `
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    @page { size: 80mm auto; margin: 0; }
                    * { box-sizing: border-box; margin: 0; padding: 0; }
                    html, body {
                        font-family: 'Courier New', Courier, monospace;
                        width: 76mm;
                        padding: 0mm 1mm;
                        font-size: 14pt;
                        line-height: 1.35;
                        color: #000;
                        background: #fff;
                    }
                    .line { border-top: 1px dashed #000; margin: 4px 0; }
                    .row { display: flex; justify-content: space-between; align-items: center; }
                    .col { display: flex; flex-direction: column; }
                    .bold { font-weight: bold; }
                    .upper { text-transform: uppercase; }
                    .center { text-align: center; }
                    .small { font-size: 11pt; }
                    .xsmall { font-size: 10pt; font-style: italic; }
                    table { width: 100%; border-collapse: collapse; font-size: 13pt; }
                    td { padding: 3px 0; vertical-align: top; }
                    .audit { font-size: 11pt; text-transform: uppercase; margin-top: 6px; padding-top: 4px; border-top: 1px dashed #000; }
                </style>
            </head>
            <body>
                <!-- ENCABEZADO: logo grande con pixel rendering nativo + nombre -->
                <div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 2px; margin-bottom: 4px;">
                    <img src="/assets/logo.png" alt="Logo" style="width: 50px; height: 50px; object-fit: contain; image-rendering: pixelated; flex-shrink: 0;" />
                    <div class="bold upper" style="font-size: 18pt; letter-spacing: 1px; line-height: 1;">R DE RICO</div>
                </div>

                <!-- Fecha, Hora y Número de cuenta al CENTRO  -->
                <div class="col bold center" style="font-size: 12pt; margin-bottom: 4px; align-items: center;">
                    <div>CTA: ${ticketData.account_num || '---'}</div>
                    <div style="font-weight: normal; margin-top: 2px;">${printDate} ${printTime}</div>
                </div>

                <div class="line"></div>

                <table style="margin: 4px 0;">
                    <tbody>${itemsHtml}</tbody>
                </table>

                <div class="line"></div>

                <div class="row bold" style="font-size: 11pt; margin: 4px 0;">
                    <span>TOTAL DE ARTICULOS:</span>
                    <span>${totalQty}</span>
                </div>

                <div class="line"></div>

                <div class="row bold" style="font-size: 16pt; margin: 4px 0;">
                    <span>TOTAL</span>
                    <span>$${(ticketData.total || 0).toFixed(2)}</span>
                </div>

                <div style="margin: 4px 0; font-size: 12pt;">
                    ${paymentsHtml}
                </div>

                <div class="audit">
                    <div class="row bold"><span>CAPTURÓ:</span><span>${capturedBy}</span></div>
                    <div class="row bold"><span>COBRÓ:</span><span>${cashedBy}</span></div>
                    <div class="row xsmall"><span>Terminal:</span><span>${ticketData.terminal_id || 'T1'}</span></div>
                </div>

                <div class="center xsmall" style="margin-top: 6px; padding-top: 3px; border-top: 1px solid #ccc;">
                    *** Disfrute su pan ***
                </div>
            </body>
            </html>
        `;
    };

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
                cash_session_id: cashSessionId,
                captured_by_id: originalCapturer?.id || currentUser?.id || null,
                cashed_by_id: status === 'PAID' ? (currentUser?.id || null) : null
            };

            const savedTicket = await posService.createTicket(payload);
            setPrintTicketData(savedTicket); // Actualizar datos de impresión con la respuesta oficial del servidor
            
            if (finalizeUI) {
                if (status === 'PAID') {
                    console.log("Auto-printing PAID ticket. Response from server:", savedTicket);
                    handlePrintTicket(savedTicket);
                }
                clearCart();
                setOriginalCapturer(null);
                generateNewAccountNum();
                setShowCheckout(false);
                setPaymentsHistory([]);
                if (status === 'PAID') {
                    alert(`Venta finalizada exitosamente. Ticket impreso.`);
                }
            }
        } catch (error) {
            console.error("Ticket action error:", error);
            alert(error.message);
            throw error;
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
        // Guardar también quién la capturó originalmente para que persista en el ticket final
        // Limpiamos los datos para asegurar que tengan el formato correcto
        const capturer = account.capturedById ? { 
            id: account.capturedById, 
            name: account.capturedByName 
        } : null;
        
        console.log("Recovering account. Original capturer recovered from corkboard:", capturer);
        setOriginalCapturer(capturer || currentUser); // Si no hay capturador en DB, el actual se vuelve el capturador
        setShowCorkboard(false);
    };

    useEffect(() => {
        if (showCorkboard) {
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
                    {terminals.map(t => {
                        const isOccupied = terminalStatuses[t.id];
                        const isMine = isOccupied && isOccupied.occupier_id === currentUser?.id;
                        const lockedByOther = isOccupied && !isMine;

                        return (
                        <button 
                            key={t.id} 
                            onClick={async () => {
                                if (lockedByOther) {
                                    if (isOccupied.is_cash_register) {
                                        setDeniedModal({
                                            title: "ACCESO DENEGADO",
                                            message: `La terminal '${t.name}' tiene un turno de CAJA abierto.\nDebido a la responsabilidad del dinero, NO SE PUEDE forzar la liberación hasta que el cajero haga el Corte de Caja.`
                                        });
                                        return;
                                    }
                                    if (currentUser?.role === 'ADMIN' || currentUser?.role === 'GERENTE') {
                                        setUnlockingTerminal({ id: t.id, occupier: isOccupied.occupier_name });
                                    } else {
                                        setDeniedModal({
                                            title: "TERMINAL OCUPADA",
                                            message: `Esta terminal está siendo ocupada por ${isOccupied.occupier_name}. Solicita a un Administrador que libere la estación si quedó atascada.`
                                        });
                                    }
                                    return;
                                }
                                
                                try {
                                    await posService.lockTerminal(t.id, currentUser.id, currentUser.name);
                                    setSelectedTerminal(t.id);
                                } catch (e) {
                                    setDeniedModal({ title: "ERROR", message: e.message });
                                }
                            }} 
                            className={`group relative transition-all duration-500 rounded-[40px] border flex flex-col items-center shadow-2xl overflow-hidden
                            ${lockedByOther 
                                ? 'cursor-not-allowed border-red-500/60 bg-[#1a0808]' 
                                : 'p-10 gap-6 bg-black/20 hover:bg-orange-600 border-white/5 hover:border-orange-400 hover:scale-110'}`}>
                            
                            {lockedByOther ? (
                                /* === CARD OCUPADA: diseño re-pensado === */
                                <div className="w-full flex flex-col relative">
                                    {/* Header con nombre de terminal */}
                                    <div className="bg-red-900/60 px-4 py-2 flex items-center justify-between">
                                        <span className="text-white font-black text-sm uppercase tracking-widest">
                                            {t.name === 'CAJA' ? 'CAJA' : `T${t.name.split(' ')[1]}`}
                                        </span>
                                        <span className="text-[9px] font-black uppercase tracking-wider bg-red-600 text-white px-2 py-0.5 rounded-full">
                                            {isOccupied.is_cash_register ? 'EN CAJA' : 'OCUPADA'}
                                        </span>
                                    </div>
                                    {/* Cuerpo con cédula del ocupante */}
                                    <div className="px-4 py-5 flex flex-col items-center gap-3">
                                        <span className="text-5xl">🔒</span>
                                        <div className="text-center">
                                            <p className="text-[10px] font-bold uppercase tracking-widest text-red-400 mb-1">En uso por</p>
                                            <p className="text-white font-black text-base uppercase leading-tight">
                                                {isOccupied.occupier_name}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            ) : (
                                /* === CARD LIBRE === */
                                <>
                                    <div className="w-24 h-24 flex items-center justify-center bg-white/5 group-hover:bg-white/20 rounded-3xl transition-colors">
                                        {t.icon.endsWith('.png') ? <img src={t.icon} alt={t.name} className="w-16 h-16 object-contain" /> : <span className="text-4xl">{t.icon}</span>}
                                    </div>
                                    <div className="text-center">
                                        <span className="block text-2xl font-black italic uppercase group-hover:text-white transition-colors">
                                            {t.name === 'CAJA' ? 'CAJA' : t.name.split(' ')[1]}
                                        </span>
                                        <span className="text-[8px] font-bold text-gray-500 uppercase tracking-widest group-hover:text-orange-200">
                                            {t.name === 'CAJA' ? 'Cajero Central' : 'Punto de Venta'}
                                        </span>
                                    </div>
                                </>
                            )}
                        </button>
                    )})}
                </div>
                
                {/* Modal de Forzar Liberación */}
                {unlockingTerminal && (
                    <div className="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center z-[100] animate-in fade-in duration-300">
                        <div className="bg-gray-900 border border-white/10 p-8 rounded-[40px] shadow-[0_0_50px_rgba(255,100,0,0.2)] max-w-sm w-full text-center relative overflow-hidden">
                            <div className="absolute -top-20 -left-20 w-40 h-40 bg-red-600/20 blur-3xl rounded-full"></div>
                            <div className="text-6xl mb-4 relative z-10">⚠️</div>
                            <h2 className="text-xl font-black uppercase text-white mb-2 relative z-10">FORZAR LIBERACION</h2>
                            <p className="text-sm font-bold text-gray-400 mb-6 relative z-10">
                                La terminal está actualmente ocupada por <span className="text-orange-400">{unlockingTerminal.occupier}</span>.<br/><br/>¿Estás seguro que deseas romper su sesión y liberarla para el equipo?
                            </p>
                            <div className="flex gap-4 relative z-10">
                                <button 
                                    onClick={() => setUnlockingTerminal(null)}
                                    className="flex-1 py-3 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 font-bold uppercase text-[10px] tracking-widest transition-all"
                                >
                                    Cancelar
                                </button>
                                <button 
                                    onClick={async () => {
                                        try {
                                            await posService.forceUnlockTerminal(unlockingTerminal.id);
                                            const data = await posService.getTerminalsStatus();
                                            setTerminalStatuses(data);
                                            setUnlockingTerminal(null);
                                        } catch(e) {
                                            console.error(e);
                                        }
                                    }}
                                    className="flex-1 py-3 rounded-2xl bg-red-600/80 hover:bg-red-500 border border-red-500/50 font-black uppercase text-[10px] tracking-widest text-white shadow-lg transition-all shadow-red-500/20"
                                >
                                    SÍ, FORZAR
                                </button>
                            </div>
                        </div>
                    </div>
                )}
                
                {/* Modal de Denegado / Advertencia */}
                {deniedModal && (
                    <div className="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center z-[100] animate-in fade-in duration-300">
                        <div className="bg-gray-900 border border-white/10 p-8 rounded-[40px] shadow-[0_0_50px_rgba(255,0,0,0.2)] max-w-sm w-full text-center relative overflow-hidden">
                            <div className="absolute -top-20 -left-20 w-40 h-40 bg-red-600/20 blur-3xl rounded-full"></div>
                            <div className="text-6xl mb-4 relative z-10">❌</div>
                            <h2 className="text-xl font-black uppercase text-red-500 mb-3 relative z-10">{deniedModal.title}</h2>
                            <p className="text-xs font-bold text-gray-400 mb-8 relative z-10 whitespace-pre-wrap leading-relaxed">
                                {deniedModal.message}
                            </p>
                            <div className="flex justify-center relative z-10">
                                <button 
                                    onClick={() => setDeniedModal(null)}
                                    className="w-full py-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 font-black uppercase text-[10px] tracking-widest text-white transition-all shadow-lg"
                                >
                                    ENTENDIDO
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        );
    }

    // --- Componentes Locales (Mantenidos para preservar Grid estable) ---
    const ProductCard = ({ product }) => {
        const [imgStatus, setImgStatus] = useState(product.hasRealImage ? 'API_IMG' : 'TRY_PNG');
        const baseStaticUrl = CONFIG.API_BASE_URL.replace('/api/v1', '/static/catalog');
        const skuPngUrl = `${baseStaticUrl}/${product.sku}.png`;
        const skuJpgUrl = `${baseStaticUrl}/${product.sku}.jpg`;
        const legacyPng = `${baseStaticUrl}/Img1118_${product.sku}.png`;
        const legacyJpg = `${baseStaticUrl}/Img1118_${product.sku}.jpg`;

        return (
            <button onClick={() => addToCart(product)} className="group relative bg-black hover:bg-[#c1d72e] p-3 rounded-[35px] border border-white/10 transition-all duration-500 flex flex-col items-center justify-between gap-2 hover:scale-105 active:scale-95 shadow-[0_4px_20px_rgba(0,0,0,0.6)] hover:shadow-[#c1d72e]/20 h-full w-full">
                {/* Imagen expandida con menos márgenes */}
                <div className="w-full h-32 flex items-center justify-center mt-1">
                    {imgStatus === 'API_IMG' && (
                        <img 
                            src={product.image} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('TRY_PNG')}
                        />
                    )}
                    {imgStatus === 'TRY_PNG' && (
                        <img 
                            src={skuPngUrl} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('TRY_JPG')}
                        />
                    )}
                    {imgStatus === 'TRY_JPG' && (
                        <img 
                            src={skuJpgUrl} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('LEGACY_PNG')}
                        />
                    )}
                    {imgStatus === 'LEGACY_PNG' && (
                        <img 
                            src={legacyPng} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('LEGACY_JPG')}
                        />
                    )}
                    {imgStatus === 'LEGACY_JPG' && (
                        <img 
                            src={legacyJpg} 
                            alt={product.name} 
                            className="max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal"
                            onError={() => setImgStatus('FALLBACK')}
                        />
                    )}
                    {imgStatus === 'FALLBACK' && (
                        <div className="text-6xl group-hover:scale-110 transition-transform">{product.emoji}</div>
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
        const filtered = PRODUCTS
            .filter(p => p.category === category)
            .sort((a, b) => {
                const posA = a.position !== null && a.position !== undefined ? a.position : 9999;
                const posB = b.position !== null && b.position !== undefined ? b.position : 9999;
                if (posA !== posB) return posA - posB;
                return a.name.localeCompare(b.name);
            });
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
                        <button onClick={async () => {
                            try {
                                await posService.unlockTerminal(selectedTerminal, currentUser?.id);
                            } catch(e) { console.error("Could not unlock terminal", e); }
                            setSelectedTerminal(null);
                        }} className="bg-black/40 backdrop-blur-md border border-white/10 px-4 py-2 rounded-xl flex items-center gap-3 hover:bg-white/10 transition-all group shadow-xl">
                            <div className="w-8 h-8 bg-orange-600/20 rounded-lg flex items-center justify-center text-orange-500 border border-orange-500/20">🖥️</div>
                            <div className="text-left">
                                <p className="text-[9px] font-black text-white/90 uppercase tracking-tighter">Terminal {selectedTerminal}</p>
                                <p className="text-[7px] font-bold text-orange-400 uppercase tracking-widest group-hover:underline">Cambiar Estacion (Liberar)</p>
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
                        console.log("Manual print from CheckoutScreen requested.");
                        handlePrintTicket(printTicketData);
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
        </div>
    );
};
