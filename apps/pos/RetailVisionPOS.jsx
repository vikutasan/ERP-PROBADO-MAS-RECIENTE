import React, { useState, useEffect, useMemo } from 'react';
import { VisionScanner } from './VisionScanner';
import { OpenAccountsCorkboard } from './OpenAccountsCorkboard';

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
    const [selectedTerminal, setSelectedTerminal] = useState(null);
    const [cart, setCart] = useState([]);
    const [isScanning, setIsScanning] = useState(false);
    const [showCorkboard, setShowCorkboard] = useState(false);
    const [clientName, setClientName] = useState('');
    const [categories, setCategories] = useState([]);
    const [initialProducts, setInitialProducts] = useState([]);
    const [activeCategory, setActiveCategory] = useState(null);
    const [currentAccountNum, setCurrentAccountNum] = useState('');
    const [viewMode, setViewMode] = useState('CAMERA');
    const [currentPage, setCurrentPage] = useState(1);
    const ITEMS_PER_PAGE = 12;

    useEffect(() => {
        const fetchData = async () => {
            try {
                const catRes = await fetch("http://localhost:3001/api/v1/catalog/categories");
                if(catRes.ok) {
                    const catData = await catRes.json();
                    const normalized = catData
                        .filter(c => c.name !== 'TODOS')
                        .map(c => {
                            const original = INITIAL_CATEGORIES.find(ic => ic.name === c.name);
                            return { ...c, icon: c.icon || (original ? original.icon : '📦') };
                        });
                    setCategories(normalized);
                    if (normalized.length > 0 && !activeCategory) {
                        setActiveCategory(normalized[0].name);
                    }
                }

                const prodRes = await fetch("http://localhost:3001/api/v1/catalog/products");
                if(prodRes.ok) {
                    const prodData = await prodRes.json();
                    setInitialProducts(prodData);
                }
            } catch (error) {
                console.error("Error connecting to backend API:", error);
                alert("No se pudo conectar con el Backend (Servidor Local). Asegurese de que FastAPI este corriendo en el puerto 3001.");
            }
        };
        fetchData();
    }, []);

    const PRODUCTS = useMemo(() => initialProducts.map(p => ({
        ...p,
        id: p.id, 
        image: getProductEmoji(p),
        category: p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : 'OTROS'
    })), [initialProducts]);

    useEffect(() => {
        if (selectedTerminal && !currentAccountNum) {
            generateNewAccountNum();
        }
    }, [selectedTerminal, currentAccountNum]);

    useEffect(() => {
        let barcodeBuffer = '';
        let lastKeyTime = Date.now();

        const handleGlobalKeyDown = (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

            const now = Date.now();
            
            if (now - lastKeyTime > 100) {
                barcodeBuffer = '';
            }
            
            lastKeyTime = now;

            if (e.key === 'Enter') {
                if (barcodeBuffer) {
                    const product = PRODUCTS.find(p => 
                        p.barcode === barcodeBuffer || 
                        p.id.toString() === barcodeBuffer
                    );
                    
                    if (product) {
                        addToCart(product);
                    }
                    barcodeBuffer = '';
                }
            } else if (e.key.length === 1) {
                barcodeBuffer += e.key;
            }
        };

        window.addEventListener('keydown', handleGlobalKeyDown);
        return () => window.removeEventListener('keydown', handleGlobalKeyDown);
    }, [PRODUCTS]);

    const generateNewAccountNum = () => {
        const num = Math.floor(1000 + Math.random() * 9000);
        setCurrentAccountNum(`V${num}`);
    };

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
                    const looseFound = PRODUCTS.find(p => 
                        p.name.toUpperCase().includes(searchName) || 
                        searchName.includes(p.name.toUpperCase())
                    );
                    if (looseFound) {
                        targetProduct = { ...looseFound, quantity: product.quantity || 1 };
                    } else {
                        return prev;
                    }
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

    const ProductCard = ({ product }) => (
        <button
            onClick={() => addToCart(product)}
            className="group relative bg-black/20 hover:bg-[#c1d72e] p-6 rounded-[35px] border border-white/5 transition-all duration-500 flex flex-col items-center gap-4 hover:scale-105 active:scale-95 shadow-xl hover:shadow-[#c1d72e]/20"
        >
            <div className="text-5xl group-hover:scale-110 transition-transform">{product.image}</div>
            <div className="text-center">
                <p className="text-[10px] font-black uppercase tracking-tighter text-white group-hover:text-black mb-1 line-clamp-1">{product.name}</p>
                <p className="text-lg font-black text-[#c1d72e] group-hover:text-black italic font-mono">${(product.price || 0).toFixed(2)}</p>
            </div>
            <div className="absolute top-4 right-4 w-6 h-6 bg-white/5 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                <span className="text-black font-black text-xs">+</span>
            </div>
        </button>
    );

    const ProductGrid = ({ category }) => {
        const filtered = PRODUCTS.filter(p => p.category === category);
        const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
        const paginatedProducts = filtered.slice((currentPage - 1) * ITEMS_PER_PAGE, currentPage * ITEMS_PER_PAGE);

        return (
            <div className="flex-1 flex gap-4 overflow-hidden">
                {/* Lado Izquierdo: Botones de Paginación Estilo Touch */}
                {totalPages > 1 && (
                    <div className="w-16 flex flex-col gap-3 py-2 animate-in fade-in slide-in-from-left-4 duration-500">
                        {Array.from({ length: totalPages }).map((_, i) => (
                            <button
                                key={i + 1}
                                onClick={() => setCurrentPage(i + 1)}
                                className={`w-14 h-14 rounded-full flex items-center justify-center font-black text-lg transition-all border-2 ${
                                    currentPage === i + 1 
                                    ? 'bg-[#c1d72e] text-black border-[#c1d72e] shadow-lg shadow-[#c1d72e]/40 scale-110' 
                                    : 'bg-black/40 text-white/40 border-white/10 hover:border-white/30'
                                }`}
                            >
                                {i + 1}
                            </button>
                        ))}
                    </div>
                )}

                {/* Centro: Grid de Productos */}
                <div className="flex-1 overflow-hidden">
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 grid-rows-3 gap-4 h-full">
                        {paginatedProducts.map(p => <ProductCard key={p.id} product={p} />)}
                        
                        {/* Espacios vacios para mantener el grid estable si hay menos de 12 productos */}
                        {paginatedProducts.length < ITEMS_PER_PAGE && Array.from({length: ITEMS_PER_PAGE - paginatedProducts.length}).map((_, i) => (
                            <div key={`empty-${i}`} className="bg-black/5 rounded-[35px] border border-white/2"></div>
                        ))}
                    </div>

                    {filtered.length === 0 && (
                        <div className="h-full flex flex-col items-center justify-center text-gray-600">
                            <span className="text-4xl mb-4 opacity-20">📦</span>
                            <p className="font-black uppercase tracking-widest text-[10px]">Sin productos en esta categoria</p>
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const handleHoldAccount = async () => {
        if (cart.length === 0) {
            alert("El ticket esta vacio.");
            return;
        }

        try {
            // Reutilizamos la lógica de sesión de handleCheckout
            const sessionRes = await fetch(`http://localhost:3001/api/v1/pos/sessions/${selectedTerminal || 'T1'}/active`);
            let sessionId;
            
            if (sessionRes.ok) {
                const sessionData = await sessionRes.json();
                sessionId = sessionData.id;
            } else {
                const newSessionRes = await fetch(`http://localhost:3001/api/v1/pos/sessions`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ terminal_id: selectedTerminal || 'T1' })
                });
                const newSessionData = await newSessionRes.json();
                sessionId = newSessionData.id;
            }

            const ticketPayload = {
                account_num: currentAccountNum,
                session_id: sessionId,
                items: cart.map(item => ({
                    product_id: item.id,
                    quantity: item.quantity || 1
                })),
                status: "OPEN" // Esto lo manda al pizarron
            };

            const res = await fetch("http://localhost:3001/api/v1/pos/tickets", {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(ticketPayload)
            });

            if (res.ok) {
                setCart([]);
                generateNewAccountNum();
            } else {
                alert("Error al enviar al pizarron.");
            }
        } catch (error) {
            console.error("Hold error:", error);
            alert("Error de conexion al pizarron.");
        }
    };

    const handleCheckout = async (paymentMethod) => {
        if (cart.length === 0) {
            alert("El ticket esta vacio.");
            return;
        }

        try {
            const sessionRes = await fetch(`http://localhost:3001/api/v1/pos/sessions/${selectedTerminal || 'T1'}/active`);
            let sessionId;
            
            if (sessionRes.ok) {
                const sessionData = await sessionRes.json();
                sessionId = sessionData.id;
            } else {
                const newSessionRes = await fetch(`http://localhost:3001/api/v1/pos/sessions`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ terminal_id: selectedTerminal || 'T1' })
                });
                const newSessionData = await newSessionRes.json();
                sessionId = newSessionData.id;
            }

            const ticketPayload = {
                account_num: currentAccountNum,
                session_id: sessionId,
                items: cart.map(item => ({
                    product_id: item.id,
                    quantity: item.quantity || 1
                })),
                status: "PAID"
            };

            const ticketRes = await fetch("http://localhost:3001/api/v1/pos/tickets", {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(ticketPayload)
            });

            if (ticketRes.ok) {
                alert(`Pago exitoso con ${paymentMethod}. Ticket registrado en el ERP.`);
                setCart([]);
                generateNewAccountNum();
            } else {
                const errorData = await ticketRes.json();
                alert(`Error al cobrar: ${errorData.detail}`);
            }

        } catch (error) {
            console.error("Checkout validation error:", error);
            alert("No se pudo conectar al Backend para validar el ticket.");
        }
    };

    const handleRecoverAccount = (account) => {
        // Reconstruir el carrito con los artículos del ticket
        if (account.rawItems && account.rawItems.length > 0) {
            const recoveredCart = account.rawItems.map(item => ({
                id: item.product.id,
                name: item.product.name,
                price: item.product.price,
                quantity: item.quantity,
                category: item.product.category ? item.product.category.name : 'OTROS'
            }));
            setCart(recoveredCart);
            setCurrentAccountNum(account.accountNum);
            setShowCorkboard(false);
        } else {
            alert("Esta cuenta no tiene articulos.");
        }
    };

    const total = cart.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 1), 0);

    const [allOpenAccounts, setAllOpenAccounts] = useState([]);

    useEffect(() => {
        if (showCorkboard) {
            const fetchOpen = async () => {
                try {
                    const res = await fetch("http://localhost:3001/api/v1/pos/tickets/open");
                    if (res.ok) {
                        const data = await res.json();
                        // Mapear los datos de la API al formato que espera el Corkboard
                        const mapped = data.map(t => ({
                            id: t.account_num,
                            accountNum: t.account_num,
                            terminal: t.terminal_id || 'T1',
                            total: t.total,
                            items: t.items.length,
                            rawItems: t.items, // Guardamos los items reales para recuperarlos
                            timestamp: t.created_at,
                            cashierName: 'Operador',
                            clientName: 'Público General'
                        }));
                        setAllOpenAccounts(mapped);
                    }
                } catch (e) {
                    console.error("Fetch open tickets error:", e);
                }
            };
            fetchOpen();
        }
    }, [showCorkboard]);

    const visibleAccounts = selectedTerminal === 'CAJA'
        ? allOpenAccounts
        : allOpenAccounts.filter(acc => acc.terminal === selectedTerminal);

    if (!selectedTerminal) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center p-20 animate-in fade-in zoom-in-95 duration-700">
                <div className="text-center mb-16">
                    <h3 className="text-orange-500 font-black uppercase tracking-[0.5em] text-xs mb-4">Configuracion de Estacion</h3>
                    <h2 className="text-6xl font-black uppercase tracking-tighter italic">Selecciona tu <span className="text-white/20">Terminal</span></h2>
                </div>

                <div className="grid grid-cols-3 md:grid-cols-6 gap-8 max-w-7xl w-full">
                    {terminals.map((t) => (
                        <button
                            key={t.id}
                            onClick={() => setSelectedTerminal(t.id)}
                            className="group relative bg-black/20 hover:bg-orange-600 transition-all duration-500 p-10 rounded-[40px] border border-white/5 hover:border-orange-400 flex flex-col items-center gap-6 shadow-2xl hover:scale-110"
                        >
                            <div className="w-24 h-24 flex items-center justify-center bg-white/5 group-hover:bg-white/20 rounded-3xl transition-colors">
                                {t.icon.endsWith('.png') ? (
                                    <img src={t.icon} alt={t.name} className="w-16 h-16 object-contain" />
                                ) : (
                                    <span className="text-4xl">{t.icon}</span>
                                )}
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

    return (
        <div className="flex flex-col h-full bg-transparent text-white overflow-hidden">
            <div className="p-4 pb-2 z-20">
                <div className="flex justify-between items-center mb-3">
                    <div className="w-1/3 flex justify-start">
                        <button
                            onClick={() => setSelectedTerminal(null)}
                            className="bg-black/40 backdrop-blur-md border border-white/10 px-4 py-2 rounded-xl flex items-center gap-3 hover:bg-white/10 transition-all group shadow-xl"
                        >
                            <div className="w-8 h-8 bg-orange-600/20 rounded-lg flex items-center justify-center text-orange-500 border border-orange-500/20">
                                🖥️
                            </div>
                            <div className="text-left">
                                <p className="text-[9px] font-black text-white/90 uppercase tracking-tighter">Terminal {selectedTerminal}</p>
                                <p className="text-[7px] font-bold text-orange-400 uppercase tracking-widest group-hover:underline">Cambiar Estacion</p>
                            </div>
                        </button>
                    </div>

                    <div className="w-1/3 flex flex-col items-center gap-2">
                        <img src="/assets/logo.png" alt="R de Rico" className="w-10 h-10 object-contain drop-shadow-xl" />
                        <div className="bg-black border border-white/10 px-6 py-1 rounded-2xl shadow-2x flex flex-col items-center">
                            <span className="text-[7px] font-black uppercase text-white/40 tracking-[0.5em] mb-0.5">Transaccion Activa</span>
                            <span className="text-xl font-black uppercase tracking-tighter italic text-[#c1d72e] drop-shadow-[0_0_8px_rgba(193,215,46,0.3)]">
                                CUENTA #{(currentAccountNum || '----').slice(-4)}
                            </span>
                        </div>
                    </div>

                    <div className="w-1/3 flex justify-end">
                        <button
                            onClick={() => setShowCorkboard(true)}
                            className="bg-[#2d1e13] border border-white/10 px-4 py-2 rounded-xl flex items-center gap-2 hover:bg-[#3d2b1f] transition-all group shadow-xl"
                        >
                            <span className="text-lg">📌</span>
                            <div className="text-left">
                                <p className="text-[7px] font-black uppercase text-white/40 tracking-widest">Ver Pizarron</p>
                                <p className="text-[9px] font-bold text-[#c1d72e] uppercase tracking-tighter">{visibleAccounts.length} {selectedTerminal === 'CAJA' ? 'TOTALES' : 'MIAS'}</p>
                            </div>
                        </button>
                    </div>
                </div>

                <div className="bg-black/40 backdrop-blur-md rounded-2xl p-2 border border-white/5 shadow-2xl">
                    <div className="overflow-x-auto custom-scrollbar pb-1">
                        <div className="flex gap-2 min-w-max">
                            <button
                                onClick={() => setViewMode('CAMERA')}
                                className={`px-4 py-2 rounded-lg text-xs font-black uppercase tracking-wider transition-all whitespace-nowrap shadow-xl flex items-center gap-2 ${viewMode === 'CAMERA' ? 'bg-[#c1d72e] text-black shadow-[#c1d72e]/20' : 'bg-white/5 text-white/90 hover:bg-white/10'}`}
                            >
                                <span className="text-sm">👁️</span>
                                ESCANER IA
                            </button>
                            <div className="w-px h-8 bg-white/5 mx-1"></div>
                            {categories.map(cat => (
                                <button
                                    key={cat.name}
                                    onClick={() => { setActiveCategory(cat.name); setViewMode('GRID'); setCurrentPage(1); }}
                                    className={`px-4 py-2 rounded-lg text-xs font-black uppercase tracking-wider transition-all whitespace-nowrap drop-shadow-sm ${viewMode === 'GRID' && activeCategory === cat.name ? 'bg-[#c1d72e] text-black' : 'bg-white/5 text-white/90 hover:bg-white/10'}`}
                                >
                                    {cat.name}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>
            </div>

            <div className="flex-1 flex overflow-hidden">
                <div className="flex-1 flex flex-col p-4 pt-0 bg-transparent overflow-hidden">
                    {viewMode === 'CAMERA' ? (
                        <div className="flex-1 relative rounded-[40px] overflow-hidden shadow-2xl border border-white/10 group bg-black/5 animate-in fade-in zoom-in-95 duration-500">
                            <VisionScanner isScanning={isScanning} onScan={addToCart} products={PRODUCTS} categories={categories} />

                            <div className="absolute top-8 left-8 z-30 pointer-events-none">
                                <div className="bg-black/40 backdrop-blur-md px-5 py-3 rounded-2xl border border-white/10">
                                    <h3 className="text-[9px] font-black text-[#c1d72e] uppercase tracking-[0.4em] mb-1 drop-shadow-lg">Vision Inteligente</h3>
                                    <h2 className="text-xl font-black uppercase tracking-tighter italic text-white/90 drop-shadow-lg">Scanner R-1 <span className="text-white/20 font-black">PRO</span></h2>
                                </div>
                            </div>

                            {!isScanning && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center bg-transparent transition-all duration-700">
                                    <button
                                        onClick={() => setIsScanning(true)}
                                        className="bg-[#c1d72e] text-black px-12 py-6 rounded-[30px] font-black uppercase tracking-[0.3em] flex items-center gap-6 hover:scale-105 active:scale-95 transition-all shadow-[0_0_50px_rgba(193,215,46,0.3)] group"
                                    >
                                        <div className="w-10 h-10 bg-black/10 rounded-full flex items-center justify-center">
                                            🔍
                                        </div>
                                        INICIAR ESCANEO IA
                                    </button>
                                    <p className="mt-8 text-white/30 text-[10px] font-black uppercase tracking-[0.5em]">Esperando producto...</p>
                                </div>
                            )}

                            {isScanning && (
                                <div className="absolute top-10 right-10 z-30 flex flex-col gap-3">
                                    <div className="bg-black/20 border border-white/10 p-4 rounded-3xl animate-in fade-in slide-in-from-top-4 duration-500">
                                        <p className="text-[8px] font-black text-white/50 uppercase tracking-widest mb-1">Procesando</p>
                                        <p className="text-[10px] font-bold text-orange-400">FPS: 60.4 ms</p>
                                    </div>
                                    <button
                                        onClick={() => setIsScanning(false)}
                                        className="bg-red-500 hover:bg-red-600 text-white p-4 rounded-3xl shadow-xl border border-red-500/50 flex items-center justify-center transition-all hover:scale-105 active:scale-95 animate-in fade-in zoom-in"
                                        title="Detener Escaner"
                                    >
                                        <span className="text-xl">⏹️</span>
                                    </button>
                                </div>
                            )}
                        </div>
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

                <div className="w-[420px] bg-[#fdfbf7] px-8 pt-10 pb-8 flex flex-col shadow-2xl relative border-l border-black/10 overflow-visible transition-all duration-500 text-black font-mono z-50">
                    <div className="absolute top-[-14px] left-0 right-0 w-full overflow-hidden" style={{ height: '14px' }}>
                        <svg viewBox="0 0 420 14" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
                            <path d="M0,14 L10,0 L20,14 L30,0 L40,14 L50,0 L60,14 L70,0 L80,14 L90,0 L100,14 L110,0 L120,14 L130,0 L140,14 L150,0 L160,14 L170,0 L180,14 L190,0 L200,14 L210,0 L220,14 L230,0 L240,14 L250,0 L260,14 L270,0 L280,14 L290,0 L300,14 L310,0 L320,14 L330,0 L340,14 L350,0 L360,14 L370,0 L380,14 L390,0 L400,14 L410,0 L420,14 Z" fill="#fdfbf7" />
                        </svg>
                    </div>

                    <div className="flex justify-between items-start border-b-[1.5px] border-dashed border-gray-400 pb-3 mb-2 -mt-4">
                        <div className="flex items-start gap-3">
                            <img src="/assets/logo.png" alt="R de Rico Logo" className="w-16 h-16 object-contain grayscale opacity-80 -mt-2" />
                            <div className="flex flex-col justify-center pt-1">
                                <h2 className="text-base font-black uppercase tracking-widest leading-none text-black">R DE RICO</h2>
                                <h3 className="text-[11px] font-bold text-gray-500 uppercase tracking-widest mt-1">Ticket de Venta</h3>
                            </div>
                        </div>
                        <div className="flex flex-col items-end justify-center text-xs text-gray-500 pt-1">
                            <p className="leading-none mb-1 font-black">Term {selectedTerminal || '01'}</p>
                            <p className="leading-none">{new Date().toLocaleDateString()}</p>
                        </div>
                    </div>

                    <div className="flex-1 overflow-y-auto space-y-3 pr-2 custom-scrollbar">
                        <div className="flex justify-between text-xs text-gray-600 font-black border-b-2 border-black/20 pb-2 mb-3 uppercase tracking-wider">
                            <span>Cant. - Articulo</span>
                            <span>Importe</span>
                        </div>
                        {cart.map((item) => (
                            <div key={item.id} className="flex flex-col group animate-in slide-in-from-right-4 duration-300">
                                <div className="flex justify-between items-start">
                                    <div className="flex gap-3 w-3/4">
                                        <div className="font-black min-w-[40px] text-right text-3xl leading-none">{item.quantity || 1}x</div>
                                        <div>
                                            <p className="font-black text-lg uppercase leading-tight text-gray-900">{item.name}</p>
                                            <p className="text-base text-gray-500 uppercase">${(item.price || 0).toFixed(2)} c/u</p>
                                        </div>
                                    </div>
                                    <div className="text-right flex flex-col items-end">
                                        <p className="font-black text-2xl">${((item.price || 0) * (item.quantity || 1)).toFixed(2)}</p>
                                        <button
                                            onClick={() => setCart(prev => prev.filter(i => i.id !== item.id))}
                                            className="text-[9px] text-red-500 font-bold uppercase opacity-0 group-hover:opacity-100 transition-opacity mt-1 hover:underline"
                                        >
                                            [ Quitar ]
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ))}
                        {cart.length === 0 && (
                            <div className="h-full flex flex-col items-center justify-center text-gray-400 space-y-4">
                                <p className="font-mono text-xs uppercase text-center border-2 border-dashed border-gray-300 p-4 w-full">★ El ticket esta vacio ★</p>
                            </div>
                        )}
                    </div>

                    <div className="mt-6 pt-6 border-t-2 border-dashed border-gray-400 space-y-6">
                        <div className="flex justify-between items-end">
                            <span className="text-sm font-bold uppercase text-gray-600">Total a Pagar</span>
                            <span className="text-4xl font-black text-black tracking-tighter">${total.toFixed(2)}</span>
                        </div>

                        <div className="flex flex-col gap-3">
                            <div className="grid grid-cols-2 gap-3">
                                <button 
                                    onClick={() => handleCheckout('Efectivo')}
                                    className="bg-white border-2 border-black hover:bg-black hover:text-white p-4 flex flex-col items-center justify-center transition-all active:scale-95 group shadow-[4px_4px_0_rgba(0,0,0,1)] hover:shadow-[2px_2px_0_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px]">
                                    <span className="text-xl mb-1 grayscale group-hover:grayscale-0">💵</span>
                                    <span className="text-[10px] font-bold uppercase tracking-widest">Efectivo</span>
                                </button>
                                <button 
                                    onClick={() => handleCheckout('Tarjeta')}
                                    className="bg-white border-2 border-black hover:bg-black hover:text-white p-4 flex flex-col items-center justify-center transition-all active:scale-95 group shadow-[4px_4px_0_rgba(0,0,0,1)] hover:shadow-[2px_2px_0_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px]">
                                    <span className="text-xl mb-1 grayscale group-hover:grayscale-0">💳</span>
                                    <span className="text-[10px] font-bold uppercase tracking-widest">Tarjeta/QR</span>
                                </button>
                            </div>
                            
                            {/* Botón Nueva Cuenta (Envío al Pizarron) */}
                            <button 
                                onClick={handleHoldAccount}
                                className="w-full bg-[#c1d72e] border-2 border-black hover:bg-black hover:text-[#c1d72e] p-6 flex flex-col items-center justify-center transition-all active:scale-95 group shadow-[4px_4px_0_rgba(0,0,0,1)] hover:shadow-[2px_2px_0_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] relative overflow-hidden">
                                <div className="flex items-center gap-4">
                                    <span className="text-3xl grayscale group-hover:grayscale-0 animate-bounce">📌</span>
                                    <div className="text-left">
                                        <span className="block text-[14px] font-black uppercase tracking-tighter leading-none">ABRIR NUEVA CUENTA</span>
                                        <span className="block text-[8px] font-bold text-black/40 group-hover:text-[#c1d72e]/40 uppercase tracking-widest mt-1">Enviar ticket al pizarron central</span>
                                    </div>
                                </div>
                                <div className="absolute right-[-10px] bottom-[-10px] text-6xl opacity-10 group-hover:opacity-20 transition-opacity">
                                    🛒
                                </div>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            {showCorkboard && (
                <OpenAccountsCorkboard
                    openAccounts={visibleAccounts}
                    onSelectAccount={handleRecoverAccount}
                    onClose={() => setShowCorkboard(false)}
                />
            )}
        </div>
    );
};
