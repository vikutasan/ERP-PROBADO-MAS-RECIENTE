import React, { useState, useMemo } from 'react';
import REAL_PRODUCTS from '../../importar_productos_AQUI.json';

/**
 * R DE RICO - PRODUCT MASTER & CATALOG MANAGER
 * 
 * Módulo central para la gestión de productos, recetas e inventario logístico.
 */

const INITIAL_CATEGORIES = [
    { name: "1.-EMPAQUE Y PAN BLANCO", icon: "🥖" },
    { name: "2.-A - B", icon: "🍪" },
    { name: "3.-C - D", icon: "🍩" },
    { name: "4.-E - K", icon: "🥐" },
    { name: "5.-L - M", icon: "🧁" },
    { name: "6.-N - P", icon: "🥧" },
    { name: "7.-R - S", icon: "🍰" },
    { name: "8.-T - Z", icon: "🥨" },
    { name: "17.-ROSCA DE REYES", icon: "👑" },
    { name: "9.-LACTEOS", icon: "🥛" },
    { name: "10.-SOBRE PEDIDO", icon: "🎂" },
    { name: "11.-ESPORADICOS", icon: "🎁" },
    { name: "12.-CAFES Y CHOCOLATES", icon: "☕" },
    { name: "13.-SOUVENIRS", icon: "🛍️" },
    { name: "14.-HELADOS", icon: "🍨" },
    { name: "15.-PALETAS", icon: "🍭" },
    { name: "16.-AGUAS Y MALTEADAS", icon: "🥤" },
    { name: "DESCONTINUADOS", icon: "📁" }
];

const INITIAL_INGREDIENTS = [
    { id: 'ing_harina', name: 'Harina de Trigo', unit: 'kg', costPerUnit: 18.5 },
    { id: 'ing_mantequilla', name: 'Mantequilla de Planta', unit: 'kg', costPerUnit: 120.0 },
    { id: 'ing_azucar', name: 'Azúcar Refinada', unit: 'kg', costPerUnit: 22.0 },
    { id: 'ing_levadura', name: 'Levadura Seca', unit: 'kg', costPerUnit: 85.0 },
    { id: 'ing_leche', name: 'Leche Entera', unit: 'lt', costPerUnit: 24.5 },
];

// MOCK: Base de Datos de Almacenes (En un futuro vendría del Contexto Global/API)
const WAREHOUSE_MOCKS = [
    { id: 'WH-001', name: 'Almacén Central', type: 'RAW_MATERIAL' },
    { id: 'WH-002', name: 'Mostrador Tienda 1', type: 'STORE_SHELF' },
    { id: 'WH-003', name: 'Cámaras Frigoríficas', type: 'COLD_STORAGE' }
];

const WAREHOUSE_INVENTORY_MOCKS = {
    'WH-002': [
        { sku: 'PAN-001', name: 'Concha Vainilla', stock: 45, unit: 'PZA', costPerUnit: 4.5, expiryStatus: 'OK' },
        { sku: 'PAN-002', name: 'Oreja Clásica', stock: 12, unit: 'PZA', costPerUnit: 3.2, expiryStatus: 'WARNING' },
        { sku: 'EMP-01', name: 'Caja Pastel (25x25)', stock: 500, unit: 'PZA', costPerUnit: 12.0, expiryStatus: 'OK' }
    ],
    'WH-003': [
        { sku: 'PAS-001', name: 'Pastel de 3 Leches', stock: 8, unit: 'PZA', costPerUnit: 120.0, expiryStatus: 'CRITICAL' },
        { sku: 'POS-05', name: 'Gelatina Mosaico', stock: 20, unit: 'PZA', costPerUnit: 15.0, expiryStatus: 'OK' }
    ]
};

const UNIT_OPTIONS = {
    "Conteo": ["PZA", "DOCENA", "CAJA", "PAQUETE", "BOLSA", "BARRA", "PAR"],
    "Masa": ["KG", "G", "MG", "LB", "OZ"],
    "Volumen": ["LT", "ML", "GAL", "OZ FL", "COPA"]
};

export const ProductMasterUI = () => {
    const [searchTerm, setSearchTerm] = useState('');
    const [activeCategory, setActiveCategory] = useState('TODOS');
    const [editingProduct, setEditingProduct] = useState(null);
    const [products, setProducts] = useState(() => 
        REAL_PRODUCTS.map(p => ({
            ...p,
            categories: p.category ? [p.category] : []
        }))
    );
    const [categories, setCategories] = useState(INITIAL_CATEGORIES);
    const [globalIngredients, setGlobalIngredients] = useState(INITIAL_INGREDIENTS);
    const [showIngredientSelector, setShowIngredientSelector] = useState(false);
    const [showCategoryManager, setShowCategoryManager] = useState(false);
    const [newCategory, setNewCategory] = useState({ name: '', icon: '📦' });
    const [renamingCategory, setRenamingCategory] = useState(null);
    const [renameValue, setRenameValue] = useState('');
    const [categoryToDelete, setCategoryToDelete] = useState(null);
    const [deleteOption, setDeleteOption] = useState('ONLY_CAT'); // 'ONLY_CAT' | 'CAT_AND_PROD'
    const [showProductLinker, setShowProductLinker] = useState(false);
    const [linkerSearch, setLinkerSearch] = useState('');
    const [showUnlinkConfirm, setShowUnlinkConfirm] = useState(false);
    const [productToUnlink, setProductToUnlink] = useState(null);
    const [showPermanentDeleteConfirm, setShowPermanentDeleteConfirm] = useState(false);
    const [productToDeletePermanently, setProductToDeletePermanently] = useState(null);

    // Filtrado de productos
    const filteredProducts = useMemo(() => {
        return products.filter(p => {
            const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                 p.sku.toLowerCase().includes(searchTerm.toLowerCase());
            const matchesCategory = activeCategory === 'TODOS' || (p.categories && p.categories.includes(activeCategory));
            return matchesSearch && matchesCategory;
        });
    }, [searchTerm, activeCategory, products]);

    const handleSaveProduct = (updatedProduct) => {
        const exists = products.find(p => p.sku === updatedProduct.sku);
        if (exists) {
            setProducts(products.map(p => p.sku === updatedProduct.sku ? updatedProduct : p));
        } else {
            setProducts([updatedProduct, ...products]);
        }
        setEditingProduct(null);
    };

    const handleCreateProduct = () => {
        const newProd = {
            sku: `NEW-${Math.floor(Math.random() * 10000)}`,
            name: 'NUEVO PRODUCTO',
            categories: activeCategory === 'TODOS' ? [(categories[0]?.name || 'GENERAL')] : [activeCategory],
            price: 0,
            unit: 'PZA',
            productType: 'RESALE',
            isLinkedToWarehouse: false,
            linkedWhId: '',
            linkedItemSku: '',
            isNew: true // Bandera para permitir editar el SKU la primera vez
        };
        setEditingProduct(newProd);
    };

    const handleUnlinkProduct = (product, categoryName) => {
        const remainingCats = product.categories.filter(c => c !== categoryName);
        
        if (remainingCats.length === 0) {
            setProductToUnlink(product);
            setShowUnlinkConfirm(true);
        } else {
            setProducts(products.map(p => 
                p.sku === product.sku ? { ...p, categories: remainingCats } : p
            ));
        }
    };

    const confirmMoveToDiscontinued = () => {
        if (!productToUnlink) return;
        setProducts(products.map(p => 
            p.sku === productToUnlink.sku ? { ...p, categories: ['DESCONTINUADOS'] } : p
        ));
        setShowUnlinkConfirm(false);
        setProductToUnlink(null);
    };

    const handlePermanentDelete = (product) => {
        setProducts(products.filter(p => p.sku !== product.sku));
        setShowPermanentDeleteConfirm(false);
        setProductToDeletePermanently(null);
        setEditingProduct(null);
    };

    const handleLinkProduct = (product) => {
        if (!activeCategory || activeCategory === 'TODOS' || activeCategory === 'DESCONTINUADOS') return;
        
        setProducts(products.map(p => {
            if (p.sku === product.sku) {
                // Si estaba en DESCONTINUADOS, lo quitamos al vincular a una real
                const filtered = p.categories.filter(c => c !== 'DESCONTINUADOS');
                const updatedCategories = filtered.includes(activeCategory) 
                    ? filtered 
                    : [...filtered, activeCategory];
                return { ...p, categories: updatedCategories };
            }
            return p;
        }));
        setShowProductLinker(false);
    };

    const handleExportData = () => {
        const data = {
            products,
            categories,
            ingredients: globalIngredients,
            exportDate: new Date().toISOString()
        };
        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `CATALOGO_RDERICO_${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    };

    const handleImportData = (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                const importedData = JSON.parse(event.target.result);
                if (importedData.products && Array.isArray(importedData.products)) {
                    setProducts(importedData.products);
                    if (importedData.categories) setCategories(importedData.categories);
                    if (importedData.ingredients) setGlobalIngredients(importedData.ingredients);
                    alert("✅ Catálogo importado con éxito.");
                } else {
                    alert("❌ Formato de archivo no cargado correctamente.");
                }
            } catch (err) {
                alert("❌ Error al leer el archivo JSON.");
            }
        };
        reader.readAsText(file);
    };

    const unlinkedProducts = useMemo(() => {
        if (!activeCategory || activeCategory === 'TODOS') return [];
        return products.filter(p => 
            !p.categories.includes(activeCategory) &&
            (p.name.toLowerCase().includes(linkerSearch.toLowerCase()) || p.sku.toLowerCase().includes(linkerSearch.toLowerCase()))
        );
    }, [products, activeCategory, linkerSearch]);

    const addIngredientToRecipe = (ingredient) => {
        const currentRecipe = editingProduct.recipe || [];
        if (currentRecipe.find(ri => ri.id === ingredient.id)) return;
        
        const newRecipe = [...currentRecipe, { ...ingredient, quantity: 0 }];
        setEditingProduct({ ...editingProduct, recipe: newRecipe });
        setShowIngredientSelector(false);
    };

    const updateIngredientQuantity = (id, quantity) => {
        const newRecipe = editingProduct.recipe.map(ri => 
            ri.id === id ? { ...ri, quantity: parseFloat(quantity) || 0 } : ri
        );
        setEditingProduct({ ...editingProduct, recipe: newRecipe });
    };

    const updateGlobalIngredientCost = (id, newCost) => {
        const cost = parseFloat(newCost) || 0;
        setGlobalIngredients(globalIngredients.map(ing => 
            ing.id === id ? { ...ing, costPerUnit: cost } : ing
        ));
        
        // También actualizar en el producto que estamos editando si lo tiene
        if (editingProduct && editingProduct.recipe) {
            const newRecipe = editingProduct.recipe.map(ri => 
                ri.id === id ? { ...ri, costPerUnit: cost } : ri
            );
            setEditingProduct({ ...editingProduct, recipe: newRecipe });
        }
    };

    const calculateProductionCost = (product) => {
        if (!product || !product.recipe) return 0;
        return product.recipe.reduce((total, ri) => {
            return total + (ri.quantity * ri.costPerUnit);
        }, 0);
    };

    const totalCost = calculateProductionCost(editingProduct);
    const unitaryCost = editingProduct?.productionMode === 'BATCH' 
        ? (totalCost / (editingProduct.batchSize || 100)) 
        : totalCost;
    const margin = editingProduct ? (((editingProduct.price - unitaryCost) / editingProduct.price) * 100).toFixed(1) : 0;

    const handleAddCategory = () => {
        if (!newCategory.name) return;
        setCategories([...categories, newCategory]);
        setNewCategory({ name: '', icon: '📦' });
    };

    const handleDeleteCategory = () => {
        const catName = categoryToDelete;
        if (!catName) return;

        if (deleteOption === 'CAT_AND_PROD') {
            // Borrar categoría y productos que SOLO estén en esta categoría
            // O borrar productos que contengan esta categoría si así se desea
            setCategories(categories.filter(c => c.name !== catName));
            setProducts(products.filter(p => !p.categories.includes(catName)));
        } else {
            // Borrar solo etiqueta de categoría de los productos
            setCategories(categories.filter(c => c.name !== catName));
            setProducts(products.map(p => ({
                ...p,
                categories: p.categories.filter(cat => cat !== catName).concat(p.categories.length === 1 && p.categories.includes(catName) ? ['SIN CATEGORÍA'] : [])
            })));
        }
        
        if (activeCategory === catName) setActiveCategory('TODOS');
        setCategoryToDelete(null);
    };

    const handleStartRename = (cat) => {
        setRenamingCategory(cat.name);
        setRenameValue(cat.name);
    };

    const handleRenameCategory = (oldName) => {
        if (!renameValue || renameValue === oldName) {
            setRenamingCategory(null);
            return;
        }
        setCategories(categories.map(c => c.name === oldName ? { ...c, name: renameValue } : c));
        setProducts(products.map(p => ({
            ...p,
            categories: p.categories.map(cat => cat === oldName ? renameValue : cat)
        })));
        if (activeCategory === oldName) setActiveCategory(renameValue);
        setRenamingCategory(null);
    };

    return (
        <div className="bg-[#050505]/60 backdrop-blur-xl min-h-screen text-white p-8 font-sans flex gap-8">
            
            {/* Modal de Eliminación de Categoría */}
            {categoryToDelete && (
                <div className="fixed inset-0 z-[200] flex items-start justify-center p-6 pt-20 animate-in fade-in duration-300">
                    <div className="absolute inset-0 bg-black/90 backdrop-blur-xl" onClick={() => setCategoryToDelete(null)} />
                    <div className="relative w-full max-w-lg bg-gray-900 border border-red-900/30 rounded-[40px] p-10 shadow-2xl overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-1 bg-red-600/50" />
                        
                        <h3 className="text-3xl font-black uppercase italic tracking-tighter text-red-500 mb-2">¿Qué deseas eliminar?</h3>
                        <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-10">Categoría seleccionada: <span className="text-white">{categoryToDelete}</span></p>

                        <div className="space-y-4 mb-10">
                            {/* Opción 1: Solo Categoría */}
                            <label className={`block p-6 rounded-3xl border transition-all cursor-pointer ${deleteOption === 'ONLY_CAT' ? 'bg-indigo-600/10 border-indigo-500' : 'bg-black/40 border-gray-800 hover:border-gray-600'}`}>
                                <div className="flex items-center gap-4">
                                    <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${deleteOption === 'ONLY_CAT' ? 'border-white' : 'border-gray-600'}`}>
                                        {deleteOption === 'ONLY_CAT' && <div className="w-2.5 h-2.5 bg-[#c1d72e] rounded-full" />}
                                    </div>
                                    <div>
                                        <p className="text-xs font-black uppercase italic leading-none mb-1">Eliminar solo la categoría</p>
                                        <p className="text-[9px] text-gray-400 font-bold uppercase tracking-tighter">Los productos seguirán estando disponibles en "SIN CATEGORÍA"</p>
                                    </div>
                                    <input 
                                        type="radio" 
                                        className="hidden" 
                                        checked={deleteOption === 'ONLY_CAT'} 
                                        onChange={() => setDeleteOption('ONLY_CAT')} 
                                    />
                                </div>
                            </label>

                            {/* Opción 2: Categoría y Productos */}
                            <label className={`block p-6 rounded-3xl border transition-all cursor-pointer ${deleteOption === 'CAT_AND_PROD' ? 'bg-red-600/10 border-red-500' : 'bg-black/40 border-gray-800 hover:border-gray-600'}`}>
                                <div className="flex items-center gap-4">
                                    <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${deleteOption === 'CAT_AND_PROD' ? 'border-white' : 'border-gray-600'}`}>
                                        {deleteOption === 'CAT_AND_PROD' && <div className="w-2.5 h-2.5 bg-red-500 rounded-full" />}
                                    </div>
                                    <div>
                                        <p className="text-xs font-black uppercase italic leading-none mb-1">Eliminar la categoría y productos</p>
                                        <p className="text-[9px] text-red-400 font-bold uppercase tracking-tighter">Se perderán todos los productos que contiene la categoría</p>
                                    </div>
                                    <input 
                                        type="radio" 
                                        className="hidden" 
                                        checked={deleteOption === 'CAT_AND_PROD'} 
                                        onChange={() => setDeleteOption('CAT_AND_PROD')} 
                                    />
                                </div>
                            </label>
                        </div>

                        <div className="flex gap-4">
                            <button 
                                onClick={() => setCategoryToDelete(null)}
                                className="flex-1 py-5 bg-gray-800 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-gray-700 transition-all"
                            >
                                Cancelar
                            </button>
                            <button 
                                onClick={handleDeleteCategory}
                                className="flex-1 py-5 bg-red-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:scale-105 active:scale-95 transition-all shadow-xl shadow-red-600/20"
                            >
                                Aceptar
                            </button>
                        </div>
                    </div>
                </div>
            )}
            {/* Panel Izquierdo: Catálogo y Filtros */}
            <div className="flex-1 flex flex-col min-w-0">
                <header className="mb-8 flex justify-between items-start">
                    <div>
                        <h1 className="text-4xl font-black uppercase italic tracking-tighter text-indigo-500">Maestro de Productos</h1>
                        <p className="text-[10px] font-black text-gray-500 uppercase tracking-[0.4em] mt-2">Control Central de Catálogo y Fórmulas | R DE RICO</p>
                    </div>
                    
                    <div className="flex gap-3">
                        <label className="cursor-pointer bg-gray-900 border border-gray-800 px-6 py-4 rounded-2xl flex items-center gap-3 hover:border-indigo-500 transition-all group">
                            <span className="text-lg group-hover:scale-110 transition-transform">📥</span>
                            <div className="text-left">
                                <p className="text-[10px] font-black uppercase italic leading-none mb-1">Importar</p>
                                <p className="text-[7px] text-gray-600 font-black uppercase tracking-widest">JSON / Catálogo</p>
                            </div>
                            <input type="file" className="hidden" accept=".json" onChange={handleImportData} />
                        </label>
                        
                        <button 
                            onClick={handleExportData}
                            className="bg-gray-900 border border-gray-800 px-6 py-4 rounded-2xl flex items-center gap-3 hover:border-[#c1d72e] transition-all group"
                        >
                            <span className="text-lg group-hover:scale-110 transition-transform">📤</span>
                            <div className="text-left">
                                <p className="text-[10px] font-black uppercase italic leading-none mb-1">Exportar</p>
                                <p className="text-[7px] text-gray-600 font-black uppercase tracking-widest">Backup Masivo</p>
                            </div>
                        </button>
                    </div>
                </header>

                <div className="flex gap-4 mb-6">
                    <div className="flex-1 relative group">
                        <span className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500 group-focus-within:text-indigo-500 transition-colors">🔍</span>
                        <input 
                            type="text" 
                            placeholder="Buscar por nombre o SKU..."
                            className="w-full bg-black/40 border border-gray-800 p-4 pl-12 rounded-2xl outline-none focus:border-indigo-500 font-bold transition-all"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {/* Filtro de Categorías */}
                <div className="flex gap-2 overflow-x-auto pb-4 mb-6 custom-scrollbar">
                    <button 
                        onClick={() => setActiveCategory('TODOS')}
                        className={`px-6 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest whitespace-nowrap transition-all ${activeCategory === 'TODOS' ? 'bg-indigo-600 text-white shadow-lg' : 'bg-gray-900/50 text-gray-500 hover:text-white'}`}
                    >
                        Todos los Productos
                    </button>
                    {categories.map(cat => (
                        <div key={cat.name} className="relative group/cat">
                            {renamingCategory === cat.name ? (
                                <div className="flex gap-1 bg-gray-900 border border-indigo-500 rounded-xl p-1 animate-in zoom-in-95 duration-200">
                                    <input 
                                        autoFocus
                                        className="bg-transparent border-none outline-none text-[10px] font-black uppercase text-white px-2 w-24"
                                        value={renameValue}
                                        onChange={(e) => setRenameValue(e.target.value.toUpperCase())}
                                        onKeyDown={(e) => e.key === 'Enter' && handleRenameCategory(cat.name)}
                                        onBlur={() => handleRenameCategory(cat.name)}
                                    />
                                </div>
                            ) : (
                                <button 
                                    onClick={() => setActiveCategory(cat.name)}
                                    className={`px-6 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest whitespace-nowrap transition-all flex items-center gap-2 ${activeCategory === cat.name ? 'bg-indigo-600 text-white shadow-lg' : 'bg-gray-900/50 text-gray-500 hover:text-white'}`}
                                >
                                    <span>{cat.icon}</span>
                                    {cat.name}
                                </button>
                            )}
                            
                            {renamingCategory !== cat.name && (
                                <div className="absolute -top-1 -right-1 flex gap-1 hidden group-hover/cat:flex z-10">
                                    <button 
                                        onClick={(e) => { e.stopPropagation(); handleStartRename(cat); }}
                                        className="w-4 h-4 bg-indigo-600 rounded-full text-[8px] items-center justify-center hover:scale-110 transition-all shadow-lg"
                                    >
                                        ✎
                                    </button>
                                    <button 
                                        onClick={(e) => { e.stopPropagation(); setCategoryToDelete(cat.name); }}
                                        className="w-4 h-4 bg-red-600 rounded-full text-[8px] items-center justify-center hover:scale-110 transition-all shadow-lg"
                                    >
                                        ✕
                                    </button>
                                </div>
                            )}
                        </div>
                    ))}
                    
                    <button 
                        onClick={() => setShowCategoryManager(!showCategoryManager)}
                        className={`px-4 py-3 rounded-xl text-[14px] font-black transition-all ${showCategoryManager ? 'bg-[#c1d72e] text-black' : 'bg-gray-900/50 text-[#c1d72e] hover:bg-gray-800'}`}
                    >
                        {showCategoryManager ? '−' : '+'}
                    </button>

                    {showCategoryManager && (
                        <div className="flex gap-2 items-center bg-gray-900/80 p-2 rounded-xl border border-[#c1d72e]/30 animate-in fade-in zoom-in-95 duration-200">
                            <input 
                                type="text"
                                placeholder="Nueva Categoría..."
                                className="bg-black/60 border border-gray-800 p-2 rounded-lg text-[10px] uppercase font-black outline-none focus:border-[#c1d72e] w-32"
                                value={newCategory.name}
                                onChange={(e) => setNewCategory({...newCategory, name: e.target.value.toUpperCase()})}
                            />
                            <button 
                                onClick={handleAddCategory}
                                className="bg-[#c1d72e] text-black px-4 py-2 rounded-lg text-[9px] font-black uppercase hover:scale-105 active:scale-95 transition-all"
                            >
                                OK
                            </button>
                        </div>
                    )}
                </div>

                {/* Modal: Vinculador de Productos Existentes */}
                {showProductLinker && (
                    <div className="fixed inset-0 z-[200] flex items-start justify-center p-6 pt-20 animate-in fade-in duration-300">
                        <div className="absolute inset-0 bg-black/90 backdrop-blur-xl" onClick={() => setShowProductLinker(false)} />
                        <div className="relative w-full max-w-2xl bg-gray-900 border border-indigo-900/30 rounded-[40px] p-8 shadow-2xl overflow-hidden flex flex-col max-h-[70vh]">
                            <header className="mb-6">
                                <h3 className="text-2xl font-black uppercase italic tracking-tighter text-indigo-400 mb-2">Vincular Producto Existente</h3>
                                <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest">Añadiendo a: <span className="text-[#c1d72e] font-black">{activeCategory}</span></p>
                            </header>

                            <input 
                                type="text"
                                placeholder="Buscar en el catálogo maestro..."
                                className="w-full bg-black/40 border border-gray-800 p-4 rounded-2xl outline-none focus:border-indigo-500 font-bold mb-6"
                                value={linkerSearch}
                                onChange={(e) => setLinkerSearch(e.target.value)}
                            />

                            <div className="flex-1 overflow-y-auto space-y-2 custom-scrollbar">
                                {unlinkedProducts.slice(0, 30).map(p => (
                                    <div 
                                        key={p.sku} 
                                        onClick={() => handleLinkProduct(p)}
                                        className="bg-black/40 border border-gray-800 p-4 rounded-2xl flex justify-between items-center group hover:border-[#c1d72e] transition-all cursor-pointer"
                                    >
                                        <div>
                                            <p className="text-xs font-black uppercase italic group-hover:text-[#c1d72e]">{p.name}</p>
                                            <p className="text-[9px] font-mono text-gray-600">{p.sku}</p>
                                        </div>
                                        <div className="bg-indigo-600/10 text-indigo-400 px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest group-hover:bg-[#c1d72e] group-hover:text-black transition-all">
                                            Vincular
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                )}

                <div className="flex justify-between items-center mb-6">
                    <p className="text-[10px] font-black text-gray-600 uppercase tracking-widest">Mostrando {filteredProducts.length} productos registrados</p>
                    <div className="flex gap-4">
                        {activeCategory !== 'TODOS' && (
                            <button 
                                onClick={() => setShowProductLinker(true)}
                                className="bg-gray-800 px-6 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest text-indigo-400 hover:bg-gray-700 transition-all border border-indigo-500/20"
                            >
                                🔗 Vincular Existente
                            </button>
                        )}
                        <button 
                            onClick={handleCreateProduct}
                            className="bg-indigo-600 px-6 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest text-white hover:scale-105 active:scale-95 transition-all shadow-lg shadow-indigo-600/20"
                        >
                            + Nuevo Producto
                        </button>
                    </div>
                </div>

                {/* Grid de Productos */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 overflow-y-auto pr-2 custom-scrollbar flex-1">
                    {filteredProducts.map(product => (
                        <div 
                            key={product.sku}
                            onClick={() => setEditingProduct(product)}
                            className="bg-gray-900/40 border border-gray-800 p-6 rounded-[32px] hover:border-indigo-500/50 transition-all cursor-pointer group relative overflow-hidden"
                        >
                            {/* Botón de Desvincular (Solo en vista de categoría) */}
                            {activeCategory !== 'TODOS' && (
                                <button 
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        handleUnlinkProduct(product, activeCategory);
                                    }}
                                    className="absolute top-4 right-12 w-8 h-8 bg-black/40 border border-gray-800 rounded-full flex items-center justify-center text-[10px] text-gray-500 hover:bg-red-600 hover:text-white hover:border-red-600 transition-all z-10 opacity-0 group-hover:opacity-100"
                                    title="Quitar de esta categoría"
                                >
                                    ✕
                                </button>
                            )}
                            
                            {activeCategory === 'DESCONTINUADOS' && (
                                <button 
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        setProductToDeletePermanently(product);
                                        setShowPermanentDeleteConfirm(true);
                                    }}
                                    className="absolute top-4 right-4 w-8 h-8 bg-red-600/20 border border-red-500/30 rounded-full flex items-center justify-center text-[10px] text-red-500 hover:bg-red-600 hover:text-white transition-all z-10 opacity-0 group-hover:opacity-100"
                                    title="Eliminar permanentemente"
                                >
                                    🗑️
                                </button>
                            )}
                            
                            {activeCategory !== 'DESCONTINUADOS' && (
                                <div className="absolute top-4 right-4 text-2xl opacity-20 group-hover:opacity-100 transition-opacity">📦</div>
                            )}

                            <div className="mb-4">
                                <div className="flex flex-wrap gap-1 mb-1">
                                    {(product.categories || []).map(cat => (
                                        <span key={cat} className="text-[7px] font-black uppercase text-indigo-400 tracking-widest bg-indigo-500/10 px-2 py-0.5 rounded-sm">{cat}</span>
                                    ))}
                                </div>
                                <h3 className="text-sm font-black uppercase italic leading-tight group-hover:text-indigo-400 transition-colors">{product.name}</h3>
                                <p className="text-[9px] text-gray-600 font-mono mt-2">{product.sku}</p>
                            </div>
                            <div className="flex justify-between items-end mt-4">
                                <span className="text-lg font-black italic text-[#c1d72e]">${product.price}</span>
                                <span className="text-[9px] font-black uppercase text-gray-500 bg-black/40 px-3 py-1 rounded-full">{product.unit}</span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Panel Derecho: Editor Detallado (Solo si hay producto seleccionado) */}
            {editingProduct && (
                <div className="w-96 bg-gray-900/80 backdrop-blur-2xl border-l border-gray-800 p-8 flex flex-col animate-in slide-in-from-right-8 duration-500">
                    <div className="flex justify-between items-center mb-8">
                        <h2 className="text-xl font-black uppercase italic tracking-tighter">Editor Detallado</h2>
                        <button onClick={() => setEditingProduct(null)} className="text-gray-500 hover:text-white text-xl">✕</button>
                    </div>

                    <div className="flex-1 overflow-y-auto pr-2 custom-scrollbar space-y-8">
                        {/* Selector de Naturaleza */}
                        <section className="space-y-4">
                            <h3 className="text-[10px] font-black uppercase text-indigo-500 tracking-[0.3em]">Naturaleza del Producto</h3>
                            <div className="flex bg-black/40 p-1 rounded-2xl border border-gray-800">
                                <button 
                                    onClick={() => setEditingProduct({...editingProduct, productType: 'RESALE'})}
                                    className={`flex-1 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${editingProduct.productType === 'RESALE' ? 'bg-indigo-600 text-white' : 'text-gray-500 hover:text-white'}`}
                                >
                                    Reventa
                                </button>
                                <button 
                                    onClick={() => setEditingProduct({...editingProduct, productType: 'PRODUCED'})}
                                    className={`flex-1 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${editingProduct.productType === 'PRODUCED' ? 'bg-indigo-600 text-white' : 'text-gray-500 hover:text-white'}`}
                                >
                                    Producido
                                </button>
                            </div>

                            {/* NUEVO: Switch de Vinculación a Almacén */}
                            <div className="bg-indigo-600/5 p-4 rounded-[24px] border border-indigo-500/20 mt-4 transition-all">
                                <div className="flex justify-between items-center mb-4">
                                    <div>
                                        <p className="text-[10px] font-black tracking-widest uppercase text-indigo-400">Vincular a Almacén Físico</p>
                                        <p className="text-[8px] text-gray-500 font-bold uppercase mt-0.5">Controla Stock y Costos en Automático</p>
                                    </div>
                                    <button 
                                        onClick={() => setEditingProduct({...editingProduct, isLinkedToWarehouse: !editingProduct.isLinkedToWarehouse, linkedWhId: '', linkedItemSku: ''})}
                                        className={`w-12 h-6 rounded-full relative transition-all duration-300 ${editingProduct.isLinkedToWarehouse ? 'bg-[#c1d72e]' : 'bg-gray-800 border border-gray-700'}`}
                                    >
                                        <div className={`w-4 h-4 bg-black rounded-full absolute top-1 transition-all duration-300 ${editingProduct.isLinkedToWarehouse ? 'left-7' : 'left-1'}`} />
                                    </button>
                                </div>

                                {editingProduct.isLinkedToWarehouse && (
                                    <div className="space-y-3 animate-in fade-in slide-in-from-top-2 duration-300">
                                        <select 
                                            value={editingProduct.linkedWhId || ''}
                                            onChange={(e) => setEditingProduct({...editingProduct, linkedWhId: e.target.value, linkedItemSku: ''})}
                                            className="w-full bg-black/60 border border-indigo-500/30 p-3 rounded-xl font-black text-[10px] uppercase outline-none focus:border-indigo-500 text-white"
                                        >
                                            <option value="" disabled>Selecciona un Almacén Punto de Venta...</option>
                                            {WAREHOUSE_MOCKS.filter(wh => wh.type !== 'RAW_MATERIAL').map(wh => (
                                                <option key={wh.id} value={wh.id}>{wh.name}</option>
                                            ))}
                                        </select>

                                        {editingProduct.linkedWhId && (
                                            <select 
                                                value={editingProduct.linkedItemSku || ''}
                                                onChange={(e) => {
                                                    const sku = e.target.value;
                                                    const whItems = WAREHOUSE_INVENTORY_MOCKS[editingProduct.linkedWhId] || [];
                                                    const selectedItem = whItems.find(i => i.sku === sku);
                                                    
                                                    // Auto-override
                                                    if (selectedItem) {
                                                        setEditingProduct({
                                                            ...editingProduct, 
                                                            linkedItemSku: sku,
                                                            name: selectedItem.name,
                                                            sku: selectedItem.sku,
                                                            purchasePrice: selectedItem.costPerUnit,
                                                            price: selectedItem.costPerUnit * 1.6 // Margen de ejemplo sugerido min 60%
                                                        });
                                                    }
                                                }}
                                                className="w-full bg-black/60 border border-[#c1d72e]/50 p-3 rounded-xl font-bold text-[10px] uppercase outline-none focus:border-[#c1d72e] text-[#c1d72e]"
                                            >
                                                <option value="" disabled>Selecciona un Artículo Físico...</option>
                                                {(WAREHOUSE_INVENTORY_MOCKS[editingProduct.linkedWhId] || []).map(item => (
                                                    <option key={item.sku} value={item.sku}>
                                                        {item.sku} - {item.name} (Stock: {item.stock})
                                                    </option>
                                                ))}
                                            </select>
                                        )}
                                    </div>
                                )}
                            </div>
                        </section>

                        {/* Identidad Base */}
                        <section className="space-y-4">
                            <h3 className="text-[10px] font-black uppercase text-indigo-500 tracking-[0.3em]">Atributos Base</h3>
                            <div className={`bg-black/40 p-4 rounded-2xl border border-gray-800 text-center ${editingProduct.isLinkedToWarehouse ? 'opacity-60 grayscale' : ''}`}>
                                <div className="w-24 h-24 bg-gray-800 rounded-3xl mx-auto mb-4 flex items-center justify-center text-4xl relative">
                                    🖼️
                                    {editingProduct.isLinkedToWarehouse && (
                                        <div className="absolute top-1 right-1 bg-black rounded-full w-6 h-6 flex items-center justify-center text-[10px]">🔒</div>
                                    )}
                                </div>
                                <button disabled={editingProduct.isLinkedToWarehouse} className="text-[9px] font-black uppercase text-indigo-400 hover:underline disabled:text-gray-600 disabled:no-underline">
                                    {editingProduct.isLinkedToWarehouse ? 'Heredada de Almacén' : 'Subir Fotografía'}
                                </button>
                            </div>
                            <div>
                                <label className="text-[9px] font-black uppercase text-gray-600 mb-3 block">Categorías Vinculadas</label>
                                <div className="flex flex-wrap gap-2 mb-4 bg-black/40 p-4 rounded-2xl border border-gray-800">
                                    {(editingProduct.categories || []).map(cat => (
                                        <div key={cat} className="bg-indigo-600/20 border border-indigo-500/30 px-3 py-1.5 rounded-lg flex items-center gap-2 group-tag">
                                            <span className="text-[9px] font-black uppercase text-indigo-300">{cat}</span>
                                            <button 
                                                onClick={() => setEditingProduct({
                                                    ...editingProduct,
                                                    categories: editingProduct.categories.filter(c => c !== cat)
                                                })}
                                                className="text-red-500 hover:text-red-300 text-[10px] leading-none"
                                            >✕</button>
                                        </div>
                                    ))}
                                    <select 
                                        className="bg-gray-800 border-none outline-none text-[8px] font-black uppercase text-indigo-400 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-700 transition-all"
                                        onChange={(e) => {
                                            if (e.target.value) {
                                                const newCat = e.target.value;
                                                const currentCats = editingProduct.categories || [];
                                                if (!currentCats.includes(newCat)) {
                                                    // Si añadimos una real, quitamos DESCONTINUADOS
                                                    const filtered = currentCats.filter(c => c !== 'DESCONTINUADOS');
                                                    setEditingProduct({
                                                        ...editingProduct,
                                                        categories: [...filtered, newCat]
                                                    });
                                                }
                                            }
                                        }}
                                        value=""
                                    >
                                        <option value="">+ Añadir</option>
                                        {categories.map(c => <option key={c.name} value={c.name}>{c.name}</option>)}
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label className="text-[9px] font-black uppercase text-gray-600 mb-1 block">Nombre Comercial</label>
                                <input 
                                    type="text" 
                                    value={editingProduct.name}
                                    disabled={editingProduct.isLinkedToWarehouse}
                                    onChange={(e) => setEditingProduct({...editingProduct, name: e.target.value})}
                                    className={`w-full bg-black/60 border border-gray-800 p-3 rounded-xl font-bold text-sm outline-none focus:border-indigo-500 ${editingProduct.isLinkedToWarehouse ? 'text-gray-500 opacity-70' : ''}`}
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="text-[9px] font-black uppercase text-gray-600 mb-1 block">Precio Venta General</label>
                                    <div className="relative">
                                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 text-sm">$</span>
                                        <input 
                                            type="number" 
                                            value={editingProduct.price}
                                            onChange={(e) => setEditingProduct({...editingProduct, price: parseFloat(e.target.value) || 0})}
                                            className="w-full bg-black/60 border border-gray-800 p-3 pl-8 rounded-xl font-black text-sm outline-none focus:border-indigo-500 text-[#c1d72e]"
                                        />
                                    </div>
                                </div>
                                <div>
                                    <label className="text-[9px] font-black uppercase text-gray-600 mb-1 block">
                                        SKU / ID {editingProduct.isLinkedToWarehouse && '🔒'}
                                    </label>
                                    <input 
                                        type="text" 
                                        value={editingProduct.sku}
                                        disabled={!editingProduct.isNew || editingProduct.isLinkedToWarehouse}
                                        onChange={(e) => setEditingProduct({...editingProduct, sku: e.target.value.toUpperCase()})}
                                        className={`w-full bg-black/60 border border-gray-800 p-3 rounded-xl font-mono text-sm outline-none focus:border-indigo-500 ${(!editingProduct.isNew || editingProduct.isLinkedToWarehouse) ? 'text-gray-500 opacity-60' : ''}`}
                                    />
                                </div>
                            </div>
                        </section>

                        {/* Data Extendida para Productos Reventa o Vinculados */}
                        {editingProduct.isLinkedToWarehouse && editingProduct.linkedItemSku && (
                            <section className="space-y-4 animate-in fade-in zoom-in-95 duration-300">
                                <h3 className="text-[10px] font-black uppercase text-amber-500 tracking-[0.3em]">Stock Logístico en Vivo</h3>
                                <div className="bg-gray-900/50 border border-gray-800 p-4 rounded-2xl flex items-center justify-between">
                                    <div>
                                        <p className="text-[8px] font-black uppercase text-gray-500">Existencias Disponibles</p>
                                        <p className="text-3xl font-black italic text-white mt-1">
                                            {WAREHOUSE_INVENTORY_MOCKS[editingProduct.linkedWhId].find(i => i.sku === editingProduct.linkedItemSku)?.stock}
                                        </p>
                                    </div>
                                    <div className="text-right">
                                        <p className="text-[8px] font-black uppercase text-gray-500">Estado P.E.P.S</p>
                                        <span className="inline-block mt-2 bg-[#c1d72e] text-black px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest">Apto Venta</span>
                                    </div>
                                </div>
                            </section>
                        )}

                        {/* Configuración Dinámica según Naturaleza */}
                        {editingProduct.productType === 'RESALE' ? (
                            <section className="space-y-4 animate-in fade-in zoom-in-95 duration-300">
                                <h3 className="text-[10px] font-black uppercase text-amber-500 tracking-[0.3em]">Cálculos de Rentabilidad</h3>
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="text-[9px] font-black uppercase text-gray-600 mb-1 block">Costo Integrado</label>
                                        <input 
                                            type="number" 
                                            placeholder="0.00"
                                            value={editingProduct.purchasePrice || ''}
                                            disabled={editingProduct.isLinkedToWarehouse}
                                            onChange={(e) => setEditingProduct({...editingProduct, purchasePrice: parseFloat(e.target.value) || 0})}
                                            className={`w-full bg-black/60 border border-gray-800 p-3 rounded-xl font-mono text-sm outline-none focus:border-amber-500 ${editingProduct.isLinkedToWarehouse ? 'text-gray-500 opacity-60' : ''}`}
                                        />
                                    </div>
                                    <div className="flex flex-col justify-end">
                                        <div className="bg-amber-600/10 border border-amber-500/20 p-3 rounded-xl">
                                            <p className="text-[8px] font-black uppercase text-amber-500 mb-1 tracking-widest">Margen Estimado</p>
                                            <p className="text-sm font-black text-white italic">
                                                {editingProduct.purchasePrice && editingProduct.price ? (((editingProduct.price - editingProduct.purchasePrice) / editingProduct.price) * 100).toFixed(1) : 0}%
                                            </p>
                                        </div>
                                    </div>
                                </div>
                                {!editingProduct.isLinkedToWarehouse && (
                                    <div>
                                        <label className="text-[9px] font-black uppercase text-gray-600 mb-1 block">Proveedor Manual</label>
                                        <select className="w-full bg-black/60 border border-gray-800 p-3 rounded-xl font-bold text-sm outline-none focus:border-amber-500">
                                            <option>Bimbo (Empacados)</option>
                                            <option>Coca-Cola FEMSA</option>
                                            <option>Lala Distribución</option>
                                            <option>Proveedor Externo</option>
                                        </select>
                                    </div>
                                )}
                            </section>
                        ) : (
                            <section className="space-y-6 animate-in fade-in zoom-in-95 duration-300">
                                <div className="flex justify-between items-center">
                                    <h3 className="text-[10px] font-black uppercase text-[#c1d72e] tracking-[0.3em]">Fórmula de Producción</h3>
                                    <div className="flex bg-black/60 p-1 rounded-lg border border-gray-800">
                                        <button 
                                            onClick={() => setEditingProduct({...editingProduct, productionMode: 'UNIT'})}
                                            className={`px-3 py-1 rounded text-[8px] font-black uppercase transition-all ${editingProduct.productionMode !== 'BATCH' ? 'bg-[#c1d72e] text-black' : 'text-gray-500'}`}
                                        >
                                            Unidad
                                        </button>
                                        <button 
                                            onClick={() => setEditingProduct({...editingProduct, productionMode: 'BATCH'})}
                                            className={`px-3 py-1 rounded text-[8px] font-black uppercase transition-all ${editingProduct.productionMode === 'BATCH' ? 'bg-[#c1d72e] text-black' : 'text-gray-500'}`}
                                        >
                                            Tanda
                                        </button>
                                    </div>
                                </div>

                                {editingProduct.productionMode === 'BATCH' && (
                                    <div className="bg-[#c1d72e]/10 border border-[#c1d72e]/20 p-4 rounded-2xl">
                                        <label className="text-[9px] font-black uppercase text-[#c1d72e] mb-2 block tracking-widest text-emerald-400">Tamaño de la Tanda ({ (editingProduct.unit || 'PZA').toUpperCase() } por Tanda)</label>
                                        <input 
                                            type="number" 
                                            value={editingProduct.batchSize || 100}
                                            onChange={(e) => setEditingProduct({...editingProduct, batchSize: parseInt(e.target.value) || 1})}
                                            className="w-full bg-black/60 border border-gray-800 p-3 rounded-xl font-mono text-sm outline-none focus:border-[#c1d72e]"
                                        />
                                        <p className="text-[8px] text-gray-500 mt-2 italic">* Los costos se dividirán entre este número de { (editingProduct.unit || 'unidades').toLowerCase() }.</p>
                                    </div>
                                )}

                                <div className="space-y-3">
                                    <div className="flex justify-between text-[10px] font-black uppercase text-gray-600 px-1">
                                        <span>Ingrediente</span>
                                        <div className="flex gap-12 mr-8">
                                            <span>Cant.</span>
                                            <span>Costo</span>
                                        </div>
                                    </div>

                                    {(editingProduct.recipe || []).map(ri => (
                                        <div key={ri.id} className="bg-black/40 rounded-xl border border-gray-800 p-3 flex flex-col gap-3 group hover:border-[#c1d72e]/30 transition-all">
                                            <div className="flex justify-between items-center">
                                                <span className="text-xs font-bold">{ri.name}</span>
                                                <button 
                                                    onClick={() => setEditingProduct({
                                                        ...editingProduct, 
                                                        recipe: editingProduct.recipe.filter(item => item.id !== ri.id)
                                                    })}
                                                    className="text-[8px] text-red-900 group-hover:text-red-500 font-black uppercase"
                                                >
                                                    Eliminar
                                                </button>
                                            </div>
                                            <div className="flex gap-2">
                                                <div className="flex-1">
                                                    <label className="text-[7px] text-gray-600 uppercase font-black block mb-1">Costo Unit ({ri.unit})</label>
                                                    <div className="relative">
                                                        <span className="absolute left-2 top-1/2 -translate-y-1/2 text-[10px] text-gray-500">$</span>
                                                        <input 
                                                            type="number"
                                                            value={ri.costPerUnit}
                                                            onChange={(e) => updateGlobalIngredientCost(ri.id, e.target.value)}
                                                            className="w-full bg-black/60 border border-gray-900 p-2 pl-4 rounded-lg text-[10px] font-mono outline-none focus:border-amber-500"
                                                        />
                                                    </div>
                                                </div>
                                                <div className="flex-1">
                                                    <label className="text-[7px] text-gray-600 uppercase font-black block mb-1">Cant Requerida</label>
                                                    <div className="relative">
                                                        <input 
                                                            type="number"
                                                            value={ri.quantity}
                                                            onChange={(e) => updateIngredientQuantity(ri.id, e.target.value)}
                                                            className="w-full bg-black/60 border border-gray-900 p-2 pr-6 rounded-lg text-[10px] font-mono outline-none focus:border-[#c1d72e]"
                                                        />
                                                        <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[8px] text-gray-500 uppercase font-black">{ri.unit}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                    
                                    <div className="relative">
                                        <button 
                                            onClick={() => setShowIngredientSelector(!showIngredientSelector)}
                                            className="w-full py-3 border-2 border-dashed border-gray-800 rounded-xl text-[9px] font-black uppercase text-gray-600 hover:border-[#c1d72e] hover:text-[#c1d72e] transition-all"
                                        >
                                            + Añadir Insumo del Maestro
                                        </button>
                                        
                                        {showIngredientSelector && (
                                            <div className="absolute top-12 left-0 right-0 bg-gray-900 border border-gray-800 rounded-2xl p-4 shadow-2xl z-50 animate-in fade-in slide-in-from-top-2">
                                                <p className="text-[8px] font-black text-gray-500 uppercase tracking-widest mb-3">Selecciona un Ingrediente</p>
                                                <div className="space-y-1 max-h-48 overflow-y-auto custom-scrollbar">
                                                    {globalIngredients.map(ing => (
                                                        <button 
                                                            key={ing.id}
                                                            onClick={() => addIngredientToRecipe(ing)}
                                                            className="w-full text-left p-3 rounded-lg hover:bg-black/40 text-xs font-bold flex justify-between group"
                                                        >
                                                            <span>{ing.name}</span>
                                                            <span className="text-gray-600 group-hover:text-[#c1d72e] font-mono">${ing.costPerUnit}/{ing.unit}</span>
                                                        </button>
                                                    ))}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </div>

                                <div className="p-4 bg-gray-900 rounded-2xl border border-gray-800 space-y-2">
                                    <div className="flex justify-between text-[10px] font-black uppercase">
                                        <span className="text-gray-500">Costo Total de {editingProduct.productionMode === 'BATCH' ? 'Tanda' : 'Preparación'}</span>
                                        <span className="text-white">${totalCost.toFixed(2)}</span>
                                    </div>
                                    <div className="flex justify-between text-[10px] font-black uppercase border-t border-gray-800 pt-2 text-[#c1d72e]">
                                        <span>Costo por { (editingProduct.unit || 'UD').toUpperCase() } (Estimado)</span>
                                        <span>${unitaryCost.toFixed(2)}</span>
                                    </div>
                                    <div className="flex justify-between text-[10px] font-black uppercase text-indigo-400">
                                        <span>Margen sobre Venta</span>
                                        <span className={margin < 30 ? 'text-red-500' : 'text-indigo-400'}>
                                            {margin}%
                                        </span>
                                    </div>
                                </div>
                            </section>
                        )}

                        {/* Logística & Almacén */}
                        <section className="space-y-4">
                            <h3 className="text-[10px] font-black uppercase text-indigo-500 tracking-[0.3em]">Stock & Ubicación</h3>
                            <div className="space-y-3">
                                <div className="p-4 bg-black/40 rounded-2xl border border-gray-800">
                                    <div className="flex justify-between items-center mb-2">
                                        <span className="text-[9px] font-black uppercase text-gray-400">Planta Central</span>
                                        <span className="text-xs font-mono text-white">450 {editingProduct.unit}</span>
                                    </div>
                                    <input 
                                        type="text" 
                                        placeholder="Escaño (ej: Rack A-02)"
                                        className="w-full bg-black/40 border border-gray-900 p-2 rounded-lg text-[10px] font-bold outline-none focus:border-indigo-500"
                                    />
                                </div>
                                <div className="p-4 bg-black/40 rounded-2xl border border-gray-800 opacity-50">
                                    <div className="flex justify-between items-center mb-2">
                                        <span className="text-[9px] font-black uppercase text-gray-400">Sucursal Toluca</span>
                                        <span className="text-xs font-mono text-white">12 {editingProduct.unit}</span>
                                    </div>
                                    <input 
                                        type="text" 
                                        placeholder="Escaño (ej: Vitrina Frontal)"
                                        className="w-full bg-black/40 border border-gray-900 p-2 rounded-lg text-[10px] font-bold outline-none focus:border-indigo-500"
                                    />
                                </div>
                            </div>
                        </section>
                    </div>

                    <div className="mt-8 pt-6 border-t border-gray-800 grid grid-cols-2 gap-4">
                        <button 
                            onClick={() => setEditingProduct(null)}
                            className="py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest text-gray-500 hover:bg-gray-800"
                        >
                            Descartar
                        </button>
                        <button 
                            onClick={() => handleSaveProduct(editingProduct)}
                            className="bg-indigo-600 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest text-white shadow-xl shadow-indigo-600/20 active:scale-95 transition-all"
                        >
                            Guardar Cambios
                        </button>
                    </div>
                </div>
            )}

            <footer className="fixed bottom-6 left-10 text-[8px] text-gray-700 font-black uppercase tracking-[0.4em] flex items-center gap-4 pointer-events-none">
                <span>R DE RICO ERP | CATALOG MODULE V1.0</span>
                <div className="w-1 h-1 bg-gray-900 rounded-full" />
                <span className="text-indigo-900/40">Sincronizado con Prisma DB</span>
            </footer>

            {/* Modal: Confirmación Mover a Descontinuados */}
            {showUnlinkConfirm && (
                <div className="fixed inset-0 z-[300] flex items-start justify-center p-6 pt-20 animate-in fade-in duration-300">
                    <div className="absolute inset-0 bg-black/95 backdrop-blur-2xl" />
                    <div className="relative w-full max-w-md bg-gray-900 border border-amber-900/30 rounded-[40px] p-10 shadow-2xl overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-1 bg-amber-500/50" />
                        <h3 className="text-2xl font-black uppercase italic tracking-tighter text-amber-500 mb-4">¡Alerta de Categoría!</h3>
                        <p className="text-sm font-bold text-gray-300 mb-2">Si quita este producto se quedará sin categoría.</p>
                        <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-10 leading-relaxed">
                            Por seguridad, será enviado a la categoría <span className="text-white italic">"DESCONTINUADOS"</span>. Podrás rescatarlo después si lo deseas.
                        </p>
                        <div className="flex gap-4">
                            <button 
                                onClick={() => setShowUnlinkConfirm(false)}
                                className="flex-1 py-5 bg-gray-800 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-gray-700 transition-all"
                            >
                                Cancelar
                            </button>
                            <button 
                                onClick={confirmMoveToDiscontinued}
                                className="flex-1 py-5 bg-amber-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:scale-105 active:scale-95 transition-all shadow-xl shadow-amber-600/20"
                            >
                                Aceptar
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Modal: Confirmación Borrado Definitivo */}
            {showPermanentDeleteConfirm && (
                <div className="fixed inset-0 z-[300] flex items-start justify-center p-6 pt-20 animate-in fade-in duration-300">
                    <div className="absolute inset-0 bg-black/95 backdrop-blur-2xl" />
                    <div className="relative w-full max-w-md bg-gray-900 border border-red-900/30 rounded-[40px] p-10 shadow-2xl overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-1 bg-red-600/50" />
                        <h3 className="text-2xl font-black uppercase italic tracking-tighter text-red-500 mb-4">Borrado Definitivo</h3>
                        <p className="text-sm font-bold text-gray-300 mb-2">¿Estás seguro de que deseas eliminar permanentemente este producto?</p>
                        <p className="text-[10px] font-black text-red-900 uppercase tracking-widest mb-10 leading-relaxed">
                            Esta acción <span className="underline italic">no se puede deshacer</span>. El SKU {productToDeletePermanently?.sku} desaparecerá del sistema.
                        </p>
                        <div className="flex gap-4">
                            <button 
                                onClick={() => setShowPermanentDeleteConfirm(false)}
                                className="flex-1 py-5 bg-gray-800 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-gray-700 transition-all"
                            >
                                Cancelar
                            </button>
                            <button 
                                onClick={() => handlePermanentDelete(productToDeletePermanently)}
                                className="flex-1 py-5 bg-red-600 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:scale-105 active:scale-95 transition-all shadow-xl shadow-red-600/20"
                            >
                                Aceptar y Eliminar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
