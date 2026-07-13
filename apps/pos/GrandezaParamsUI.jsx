import React, { useState, useEffect } from 'react';
import { CONFIG } from './config';

const API_BASE = CONFIG.API_BASE_URL;

const B2BProductCard = ({ p, b2bPrice }) => {
    const [imgStatus, setImgStatus] = useState('TRY_PNG');

    const resolveUrl = (url) => {
        if (!url) return null;
        if (url.startsWith('http')) return url;
        return `${CONFIG.API_BASE_URL.replace('/api/v1', '')}${url.startsWith('/') ? '' : '/'}${url}`;
    };

    const baseStaticUrl = `${CONFIG.API_BASE_URL.replace('/api/v1', '')}/static/catalog`;
    
    const IMG_CHAIN = [
        { key: 'API_IMG',    src: resolveUrl(p.image), next: 'TRY_PNG' },
        { key: 'TRY_PNG',    src: `${baseStaticUrl}/${p.sku}.png`,     next: 'TRY_JPG' },
        { key: 'TRY_JPG',    src: `${baseStaticUrl}/${p.sku}.jpg`,     next: 'LEGACY_PNG' },
        { key: 'LEGACY_PNG', src: `${baseStaticUrl}/Img1118_${p.sku}.png`,     next: 'LEGACY_JPG' },
        { key: 'LEGACY_JPG', src: `${baseStaticUrl}/Img1118_${p.sku}.jpg`,     next: 'FALLBACK' },
    ];

    const activeImg = IMG_CHAIN.find(i => i.key === (p.image && imgStatus === 'TRY_PNG' ? 'API_IMG' : imgStatus)) || IMG_CHAIN[1];

    return (
        <div className="p-4 rounded-2xl border bg-black/60 border-amber-500/30">
            <div className="flex justify-between items-start mb-3 gap-3">
                <div className="flex gap-3 items-center">
                    <div className="w-16 h-16 rounded-xl bg-white/5 border border-white/10 p-1 flex shrink-0 items-center justify-center">
                        {imgStatus !== 'FALLBACK' ? (
                            <img 
                                src={activeImg.src}
                                alt={p.name}
                                className="max-w-full max-h-full object-contain mix-blend-screen"
                                onError={() => setImgStatus(activeImg.next)}
                            />
                        ) : (
                            <div className="text-[10px] text-gray-500 font-bold uppercase text-center leading-tight">Sin Imagen</div>
                        )}
                    </div>
                    <div>
                        <div className="text-xs font-bold text-amber-500 uppercase">{p.sku}</div>
                        <div className="font-bold text-white">{p.name}</div>
                        <div className="text-xs text-gray-400 mt-1">Precio Tienda: ${p.price.toFixed(2)}</div>
                    </div>
                </div>
                <div className="w-8 h-8 rounded-full bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold shrink-0">
                    ✓
                </div>
            </div>
            
            <div className="pt-3 border-t border-amber-500/20 flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-amber-400">Precio B2B Grandeza</span>
                <div className="font-black text-xl text-white">
                    ${b2bPrice.toFixed(2)}
                </div>
            </div>
        </div>
    );
};


export const GrandezaParamsUI = ({ onBack }) => {
    const [activeTab, setActiveTab] = useState('products');
    const [loading, setLoading] = useState(false);
    const [statusModal, setStatusModal] = useState(null);

    // Tab: Productos
    const [allProducts, setAllProducts] = useState([]);
    const [grandezaProducts, setGrandezaProducts] = useState([]);

    // Tab: Clientes
    const [clients, setClients] = useState([]);
    const [editingClient, setEditingClient] = useState(null);

    // Estadísticas por Cliente
    const [statsClient, setStatsClient] = useState(null);
    const [statsData, setStatsData] = useState(null);
    const [statsFilter, setStatsFilter] = useState('ALL');
    const [statsLoading, setStatsLoading] = useState(false);

    // Eliminación de Clientes
    const [clientTab, setClientTab] = useState('active');
    const [clientToDelete, setClientToDelete] = useState(null);
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

    // Tab: Rutas
    const [selectedDay, setSelectedDay] = useState('LUNES');
    const [routeSlots, setRouteSlots] = useState([]);

    const DAYS = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];

    useEffect(() => {
        if (activeTab === 'products') fetchProducts();
        if (activeTab === 'clients') fetchClients();
        if (activeTab === 'routes') {
            fetchClients();
            fetchRoute(selectedDay);
        }
    }, [activeTab, selectedDay]);

    // ─── Fetchers ─────────────────────────────────────────────────────────────

    const fetchProducts = async () => {
        setLoading(true);
        try {
            // Fetch catálogo completo (solo activos)
            const resCat = await fetch(`${API_BASE}/catalog/products`);
            const catData = await resCat.json();
            setAllProducts(catData.filter(p => p.active));

            // Fetch productos Grandeza
            const resGrand = await fetch(`${API_BASE}/grandeza/products`);
            const grandData = await resGrand.json();
            setGrandezaProducts(grandData);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const fetchClients = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${API_BASE}/grandeza/clients?active_only=false`);
            const data = await res.json();
            setClients(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const fetchClientStats = async (client) => {
        setStatsClient(client);
        setStatsData(null);
        setStatsFilter('ALL');
        setStatsLoading(true);
        try {
            const res = await fetch(`${API_BASE}/grandeza/clients/${client.id}/statistics`);
            if (res.ok) setStatsData(await res.json());
        } catch (e) {
            console.error('Error fetching stats:', e);
        } finally {
            setStatsLoading(false);
        }
    };

    const fetchRoute = async (day) => {
        setLoading(true);
        try {
            const res = await fetch(`${API_BASE}/grandeza/routes/${day}`);
            const data = await res.json();
            setRouteSlots(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    // ─── Handlers Clientes ───────────────────────────────────────────────────

    const handleSaveClient = async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = {
            name: formData.get('name'),
            business_name: formData.get('business_name'),
            phone: formData.get('phone'),
            address: formData.get('address'),
            google_maps_url: formData.get('google_maps_url'),
            notes: formData.get('notes'),
            active: formData.get('active') === 'true'
        };

        const isNew = !editingClient.id;
        const method = isNew ? 'POST' : 'PUT';
        const url = isNew ? `${API_BASE}/grandeza/clients` : `${API_BASE}/grandeza/clients/${editingClient.id}`;

        try {
            const res = await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            if (res.ok) {
                setEditingClient(null);
                fetchClients();
            }
        } catch (error) {
            console.error(error);
        }
    };

    // ─── Handlers Deactivación / Eliminación Clientes ────────────────────────

    const handleDeactivateClient = async (client) => {
        try {
            const res = await fetch(`${API_BASE}/grandeza/clients/${client.id}/deactivate`, { method: 'PATCH' });
            if (res.ok) {
                setEditingClient(null);
                fetchClients();
            }
        } catch (e) { console.error(e); }
    };

    const handleReactivateClient = async (client) => {
        try {
            const res = await fetch(`${API_BASE}/grandeza/clients/${client.id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ active: true })
            });
            if (res.ok) {
                setEditingClient(null);
                fetchClients();
            }
        } catch (e) { console.error(e); }
    };

    const handlePermanentDeleteClient = async (client) => {
        try {
            const res = await fetch(`${API_BASE}/grandeza/clients/${client.id}`, { method: 'DELETE' });
            if (res.ok) {
                setShowDeleteConfirm(false);
                setClientToDelete(null);
                setEditingClient(null);
                fetchClients();
            }
        } catch (e) { console.error(e); }
    };

    // ─── Handlers Rutas ──────────────────────────────────────────────────────

    const handleAddClientToRoute = async (clientId) => {
        if (!clientId) return;
        const newSlots = [...routeSlots, { client_id: parseInt(clientId), day_of_week: selectedDay, visit_order: routeSlots.length + 1 }];
        await saveRoute(newSlots);
    };

    const handleRemoveClientFromRoute = async (index) => {
        const newSlots = routeSlots.filter((_, i) => i !== index);
        // Reindexar
        newSlots.forEach((s, i) => s.visit_order = i + 1);
        await saveRoute(newSlots);
    };

    const moveSlot = async (index, direction) => {
        if (index === 0 && direction === -1) return;
        if (index === routeSlots.length - 1 && direction === 1) return;

        const newSlots = [...routeSlots];
        const temp = newSlots[index];
        newSlots[index] = newSlots[index + direction];
        newSlots[index + direction] = temp;

        // Reindexar
        newSlots.forEach((s, i) => s.visit_order = i + 1);
        setRouteSlots(newSlots);
        await saveRoute(newSlots);
    };

    const saveRoute = async (slotsToSave) => {
        try {
            const payload = slotsToSave.map((s, i) => ({
                client_id: s.client_id,
                day_of_week: selectedDay,
                visit_order: i + 1
            }));
            const res = await fetch(`${API_BASE}/grandeza/routes/${selectedDay}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (!res.ok) {
                const err = await res.json();
                console.error("Error saving route:", err);
            }
            fetchRoute(selectedDay);
        } catch (error) {
            console.error(error);
        }
    };


    // ─── Renders ─────────────────────────────────────────────────────────────

    const renderProductsTab = () => {
        const linkedProducts = allProducts.filter(p => {
            const config = grandezaProducts.find(gp => gp.product_id === p.id);
            return config && config.is_enabled;
        });

        return (
            <div className="space-y-6 animate-in fade-in duration-500">
                <div className="bg-black/70 p-6 rounded-[24px] border border-white/5">
                    <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-2">Catálogo B2B (Solo Visualización)</h3>
                    <p className="text-sm text-white mb-6">
                        Estos son los {linkedProducts.length} productos que están configurados para subir a la ruta de reparto. 
                        Para agregar o quitar productos, ve al <strong className="text-amber-400">Maestro de Productos</strong> en el menú principal.
                    </p>
                    
                    {linkedProducts.length === 0 ? (
                        <div className="flex flex-col items-center justify-center h-40 border-2 border-dashed border-white/10 rounded-2xl text-gray-500">
                            <span className="text-2xl mb-2">🍞</span>
                            <p className="font-bold">No hay productos vinculados al Reparto Pan Grandeza</p>
                            <p className="text-xs mt-1 text-gray-600">Habilita productos desde el Catálogo de Productos</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                            {linkedProducts.map(p => {
                                const config = grandezaProducts.find(gp => gp.product_id === p.id);
                                const b2bPrice = config ? config.b2b_price : p.price;

                                return <B2BProductCard key={p.id} p={p} b2bPrice={b2bPrice} />;
                            })}
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const renderClientsTab = () => {
        const activeClients = clients.filter(c => c.active);
        const inactiveClients = clients.filter(c => !c.active);
        const displayedClients = clientTab === 'active' ? activeClients : inactiveClients;

        return (
            <div className="space-y-6 animate-in fade-in duration-500">
                <div className="flex justify-between items-center bg-black/70 p-6 rounded-[24px] border border-white/5">
                    <div>
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-1">Directorio de Clientes</h3>
                        <p className="text-sm text-white">Gestiona los clientes de la ruta Grandeza.</p>
                    </div>
                    <button 
                        onClick={() => setEditingClient({ active: true })}
                        className="px-6 py-2 bg-orange-600 hover:bg-orange-500 text-white font-black uppercase tracking-widest text-xs rounded-xl transition-all"
                    >
                        + Nuevo Cliente
                    </button>
                </div>

                {/* Sub-pestañas: Activos / Inactivos */}
                <div className="flex gap-2 bg-black/40 rounded-xl p-1 border border-white/5 w-fit">
                    <button
                        onClick={() => setClientTab('active')}
                        className={`px-5 py-2 rounded-lg text-xs font-black uppercase tracking-widest transition-all ${
                            clientTab === 'active'
                            ? 'bg-green-600 text-white shadow-lg shadow-green-500/20'
                            : 'text-gray-400 hover:text-white hover:bg-white/5'
                        }`}
                    >
                        Activos ({activeClients.length})
                    </button>
                    <button
                        onClick={() => setClientTab('inactive')}
                        className={`px-5 py-2 rounded-lg text-xs font-black uppercase tracking-widest transition-all ${
                            clientTab === 'inactive'
                            ? 'bg-red-600 text-white shadow-lg shadow-red-500/20'
                            : 'text-gray-400 hover:text-white hover:bg-white/5'
                        }`}
                    >
                        Inactivos ({inactiveClients.length})
                    </button>
                </div>

                <div className="bg-black/70 rounded-[24px] border border-white/5 overflow-x-auto">
                    {displayedClients.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-16 text-gray-500">
                            <span className="text-3xl mb-3">{clientTab === 'active' ? '👥' : '📭'}</span>
                            <p className="font-bold">{clientTab === 'active' ? 'No hay clientes activos' : 'No hay clientes inactivos'}</p>
                            <p className="text-xs mt-1">{clientTab === 'active' ? 'Agrega un nuevo cliente con el botón de arriba.' : 'Los clientes desactivados aparecerán aquí.'}</p>
                        </div>
                    ) : (
                    <table className="w-full min-w-[800px] text-left">
                        <thead className="bg-black/40 text-xs font-bold text-amber-400 uppercase tracking-widest border-b border-white/5">
                            <tr>
                                <th className="p-4">Cliente / Negocio</th>
                                <th className="p-4">Contacto</th>
                                <th className="p-4">Ubicación</th>
                                <th className="p-4 text-center">Estado</th>
                                <th className="p-4 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {displayedClients.map(c => (
                                <tr key={c.id} className="hover:bg-white/5 transition-colors">
                                    <td className="p-4">
                                        <div className="font-bold text-amber-400">{c.name}</div>
                                        <div className="text-xs text-white">{c.business_name || 'Sin negocio registrado'}</div>
                                    </td>
                                    <td className="p-4">
                                        <div className="text-sm text-white">{c.phone || '-'}</div>
                                    </td>
                                    <td className="p-4">
                                        <div className="text-sm text-white truncate max-w-[200px]">{c.address || '-'}</div>
                                        {c.google_maps_url && (
                                            <a href={c.google_maps_url} target="_blank" rel="noreferrer" className="text-xs text-orange-400 hover:underline">Ver en Mapa</a>
                                        )}
                                    </td>
                                    <td className="p-4 text-center">
                                        <span className={`px-2 py-1 rounded-full text-[10px] font-black uppercase tracking-widest ${c.active ? 'bg-green-500/20 text-green-400 border border-green-500/30' : 'bg-red-500/20 text-red-400 border border-red-500/30'}`}>
                                            {c.active ? 'Activo' : 'Inactivo'}
                                        </span>
                                    </td>
                                    <td className="p-4 text-right">
                                        <div className="flex gap-2 justify-end">
                                            <button 
                                                onClick={() => fetchClientStats(c)}
                                                className="px-3 py-1.5 bg-cyan-500/10 hover:bg-cyan-500/20 border border-cyan-500/30 rounded-lg text-xs font-bold text-cyan-400 transition-all"
                                            >
                                                📊
                                            </button>
                                            <button 
                                                onClick={() => setEditingClient(c)}
                                                className="px-4 py-1.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-xs font-bold text-white transition-all"
                                            >
                                                Editar
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    )}
                </div>

                {/* Modal de Edición de Cliente */}
                {editingClient && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
                        <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={() => setEditingClient(null)}></div>
                        <div className="relative bg-[#111] border border-white/10 rounded-[32px] p-8 max-w-2xl w-full shadow-2xl animate-in zoom-in-95">
                            <h2 className="text-2xl font-black uppercase tracking-tighter text-white mb-6">
                                {editingClient.id ? 'Editar Cliente' : 'Nuevo Cliente'}
                            </h2>
                            <form onSubmit={handleSaveClient} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Nombre del Cliente *</label>
                                        <input required name="name" defaultValue={editingClient.name} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Nombre del Negocio</label>
                                        <input name="business_name" defaultValue={editingClient.business_name} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Teléfono</label>
                                        <input name="phone" defaultValue={editingClient.phone} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Estado</label>
                                        <select name="active" defaultValue={editingClient.active} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500 appearance-none">
                                            <option value="true">Activo</option>
                                            <option value="false">Inactivo</option>
                                        </select>
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Dirección Física</label>
                                        <input name="address" defaultValue={editingClient.address} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500" />
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">URL Google Maps</label>
                                        <input name="google_maps_url" defaultValue={editingClient.google_maps_url} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500 text-orange-400" />
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Notas / Instrucciones de entrega</label>
                                        <textarea name="notes" defaultValue={editingClient.notes} rows="2" className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-orange-500"></textarea>
                                    </div>
                                </div>
                                <div className="flex justify-between gap-3 mt-8">
                                    {/* Botón izquierdo: Desactivar o Eliminar según contexto */}
                                    {editingClient.id && (
                                        editingClient.active ? (
                                            <button 
                                                type="button" 
                                                onClick={() => handleDeactivateClient(editingClient)}
                                                className="px-5 py-3 bg-orange-600/10 border border-orange-500/20 text-orange-500 rounded-xl text-[10px] font-black uppercase hover:bg-orange-600 hover:text-white transition-all group relative overflow-hidden"
                                            >
                                                <span className="relative z-10 flex items-center gap-2">
                                                    <span className="text-sm">📥</span> Desactivar Cliente
                                                </span>
                                                <div className="absolute inset-0 bg-gradient-to-r from-orange-600 to-amber-600 opacity-0 group-hover:opacity-100 transition-opacity" />
                                            </button>
                                        ) : (
                                            <div className="flex gap-2">
                                                <button 
                                                    type="button" 
                                                    onClick={() => handleReactivateClient(editingClient)}
                                                    className="px-5 py-3 bg-green-600/10 border border-green-500/20 text-green-500 rounded-xl text-[10px] font-black uppercase hover:bg-green-600 hover:text-white transition-all group relative overflow-hidden"
                                                >
                                                    <span className="relative z-10 flex items-center gap-2">
                                                        <span className="text-sm">♻️</span> Reactivar
                                                    </span>
                                                    <div className="absolute inset-0 bg-gradient-to-r from-green-600 to-emerald-600 opacity-0 group-hover:opacity-100 transition-opacity" />
                                                </button>
                                                <button 
                                                    type="button" 
                                                    onClick={() => {
                                                        setClientToDelete(editingClient);
                                                        setShowDeleteConfirm(true);
                                                    }}
                                                    className="px-5 py-3 bg-red-600/10 border border-red-500/20 text-red-500 rounded-xl text-[10px] font-black uppercase hover:bg-red-600 hover:text-white transition-all group relative overflow-hidden"
                                                >
                                                    <span className="relative z-10 flex items-center gap-2">
                                                        <span className="text-sm">💀</span> Eliminar Definitivamente
                                                    </span>
                                                    <div className="absolute inset-0 bg-gradient-to-r from-red-600 to-rose-600 opacity-0 group-hover:opacity-100 transition-opacity" />
                                                </button>
                                            </div>
                                        )
                                    )}
                                    {/* Botones derechos: Cancelar + Guardar */}
                                    <div className="flex gap-3 ml-auto">
                                        <button type="button" onClick={() => setEditingClient(null)} className="px-6 py-3 border border-white/10 rounded-xl text-sm font-bold text-gray-400 hover:bg-white/5">Cancelar</button>
                                        <button type="submit" className="px-8 py-3 bg-orange-600 hover:bg-orange-500 text-white font-black uppercase tracking-widest text-sm rounded-xl transition-all shadow-lg shadow-orange-500/20">Guardar Cliente</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

                {/* Modal de Estadísticas del Cliente */}
                {statsClient && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-2 md:p-4">
                        <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={() => setStatsClient(null)}></div>
                        <div className="relative bg-[#111] border border-white/10 rounded-[24px] md:rounded-[32px] p-4 md:p-8 max-w-4xl w-full shadow-2xl animate-in zoom-in-95 max-h-[90vh] flex flex-col">
                            {/* Header */}
                            <div className="flex items-center justify-between mb-4 md:mb-6">
                                <div>
                                    <h2 className="text-lg md:text-2xl font-black uppercase tracking-tighter text-white">
                                        📊 Estadísticas
                                    </h2>
                                    <p className="text-xs md:text-sm text-amber-400 font-bold">{statsClient.name} — {statsClient.business_name || 'Sin negocio'}</p>
                                </div>
                                <button onClick={() => setStatsClient(null)} className="w-8 h-8 md:w-10 md:h-10 rounded-full bg-white/5 hover:bg-white/10 text-gray-400 hover:text-white flex items-center justify-center text-lg transition-all">✕</button>
                            </div>

                            {statsLoading ? (
                                <div className="flex items-center justify-center py-20">
                                    <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin"></div>
                                </div>
                            ) : !statsData || statsData.visits.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-20 text-gray-500">
                                    <span className="text-4xl mb-3">📭</span>
                                    <p className="font-bold">Sin historial de visitas</p>
                                    <p className="text-xs mt-1">Este cliente aún no tiene visitas completadas.</p>
                                </div>
                            ) : (
                                <>
                                    {/* Filtro por producto */}
                                    <div className="mb-4">
                                        <select 
                                            value={statsFilter} 
                                            onChange={e => setStatsFilter(e.target.value)}
                                            className="w-full md:w-auto bg-black/40 border border-white/10 rounded-xl p-2 md:p-3 text-white text-xs md:text-sm outline-none focus:border-cyan-500 appearance-none"
                                        >
                                            <option value="ALL">Todos los productos</option>
                                            {Object.values(statsData.summary).map(s => (
                                                <option key={s.product_id} value={s.product_id}>{s.product_name}</option>
                                            ))}
                                        </select>
                                    </div>

                                    {/* Resumen por producto */}
                                    <div className="grid grid-cols-2 md:grid-cols-4 gap-2 md:gap-3 mb-4">
                                        {Object.values(statsData.summary)
                                            .filter(s => statsFilter === 'ALL' || String(s.product_id) === statsFilter)
                                            .map(s => (
                                            <div key={s.product_id} className="bg-black/40 border border-white/5 rounded-xl p-3">
                                                <div className="text-[10px] md:text-xs font-black text-amber-400 uppercase truncate mb-2">{s.product_name}</div>
                                                <div className="space-y-1 text-[10px] md:text-xs">
                                                    <div className="flex justify-between"><span className="text-gray-500">Visitas:</span><span className="text-white font-bold">{s.total_visits}</span></div>
                                                    <div className="flex justify-between"><span className="text-emerald-500">Prom. Frescas:</span><span className="text-emerald-400 font-bold">{s.avg_fresh}</span></div>
                                                    <div className="flex justify-between"><span className="text-red-500">Prom. Cambios:</span><span className="text-red-400 font-bold">{s.avg_exchange}</span></div>
                                                    <div className="flex justify-between border-t border-white/10 pt-1 mt-1"><span className="text-cyan-500 font-bold">Prom. Capitalizadas:</span><span className="text-cyan-400 font-black">{s.avg_capitalized}</span></div>
                                                    <div className="flex justify-between"><span className="text-blue-500">Sugerido:</span><span className="text-blue-400 font-black">{s.suggested_qty}</span></div>
                                                </div>
                                            </div>
                                        ))}
                                    </div>

                                    {/* Tabla de historial */}
                                    <div className="flex-1 overflow-y-auto custom-scrollbar">
                                        <table className="w-full text-xs">
                                            <thead className="sticky top-0 bg-[#111] z-10">
                                                <tr className="border-b border-white/10">
                                                    <th className="p-2 text-left text-gray-500 font-black uppercase tracking-widest">Fecha</th>
                                                    <th className="p-2 text-left text-gray-500 font-black uppercase tracking-widest">Producto</th>
                                                    <th className="p-2 text-center text-emerald-500 font-black uppercase tracking-widest">Frescas</th>
                                                    <th className="p-2 text-center text-red-500 font-black uppercase tracking-widest">Cambios</th>
                                                    <th className="p-2 text-center text-cyan-500 font-black uppercase tracking-widest">Capitaliz.</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-white/5">
                                                {statsData.visits.map((v, vi) => 
                                                    v.items
                                                        .filter(item => statsFilter === 'ALL' || String(item.product_id) === statsFilter)
                                                        .map((item, ii) => (
                                                        <tr key={`${vi}-${ii}`} className={`hover:bg-white/5 transition-colors ${vi < 3 ? 'bg-cyan-500/5' : ''}`}>
                                                            <td className="p-2 text-gray-400">{ii === 0 ? v.date : ''}</td>
                                                            <td className="p-2 text-amber-400 font-bold">{item.product_name}</td>
                                                            <td className="p-2 text-center text-emerald-400 font-bold">{item.fresh_qty}</td>
                                                            <td className="p-2 text-center text-red-400 font-bold">{item.exchange_qty}</td>
                                                            <td className="p-2 text-center text-cyan-400 font-black">{item.capitalized}</td>
                                                        </tr>
                                                    ))
                                                )}
                                            </tbody>
                                        </table>
                                        {statsData.visits.length > 3 && (
                                            <p className="text-[10px] text-cyan-500/60 text-center mt-2 italic">Las 3 primeras filas (resaltadas) son las que el sistema usa para calcular la sugerencia</p>
                                        )}
                                    </div>
                                </>
                            )}
                        </div>
                    </div>
                )}

                {/* Modal de Confirmación de Eliminación Permanente */}
                {showDeleteConfirm && clientToDelete && (
                    <div className="fixed inset-0 z-[60] flex items-center justify-center p-6">
                        <div className="absolute inset-0 bg-black/95 backdrop-blur-2xl" onClick={() => setShowDeleteConfirm(false)}></div>
                        <div className="relative w-full max-w-md bg-[#0a0a0a] border border-red-900/50 rounded-[40px] p-10 shadow-[0_0_100px_-20px_rgba(220,38,38,0.3)] text-center animate-in zoom-in-95 duration-500">
                            <div className="w-20 h-20 bg-red-600/20 border-2 border-red-600 rounded-3xl mx-auto mb-8 flex items-center justify-center text-5xl animate-pulse">
                                ⚠️
                            </div>
                            <h3 className="text-3xl font-black uppercase italic tracking-tighter text-red-500 mb-4">¡ALERTA CRÍTICA!</h3>
                            <p className="text-xs text-gray-400 font-bold uppercase tracking-widest leading-loose mb-10">
                                Estás a punto de eliminar permanentemente al cliente:<br/>
                                <span className="text-white text-sm block mt-2">"{clientToDelete.name}"</span>
                                {clientToDelete.business_name && <span className="text-amber-400/60 text-[10px] block">{clientToDelete.business_name}</span>}
                                <span className="text-red-400/60 text-[10px] block mt-4 italic">Esta acción no se puede deshacer. Se borrarán todas sus visitas, historial de ventas, estadísticas y datos asociados.</span>
                            </p>
                            <div className="flex gap-4">
                                <button 
                                    onClick={() => { setShowDeleteConfirm(false); setClientToDelete(null); }}
                                    className="flex-1 py-4 bg-gray-800 rounded-2xl text-[10px] font-black uppercase hover:bg-gray-700 transition-all"
                                >
                                    Cancelar
                                </button>
                                <button 
                                    onClick={() => handlePermanentDeleteClient(clientToDelete)}
                                    className="flex-1 py-4 bg-red-600 rounded-2xl text-[10px] font-black uppercase hover:scale-105 active:scale-95 transition-all shadow-xl shadow-red-600/30"
                                >
                                    Confirmar Destrucción
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        );
    };

    const renderRoutesTab = () => {
        return (
            <div className="space-y-6 animate-in fade-in duration-500">
                {/* Días de la Semana */}
                <div className="flex flex-wrap md:flex-nowrap gap-2 p-2 bg-black/40 rounded-2xl border border-white/5">
                    {DAYS.map(day => (
                        <button
                            key={day}
                            onClick={() => setSelectedDay(day)}
                            className={`flex-1 min-w-[100px] py-3 px-2 md:px-4 rounded-xl font-black uppercase tracking-widest text-xs transition-all ${
                                selectedDay === day 
                                ? 'bg-orange-600 text-white shadow-lg shadow-orange-500/20 scale-[1.02]' 
                                : 'text-white hover:bg-white/5 hover:text-white'
                            }`}
                        >
                            {day}
                        </button>
                    ))}
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Lista de la ruta del día */}
                    <div className="col-span-1 lg:col-span-2 bg-black/70 p-4 md:p-6 rounded-[24px] border border-white/5 min-h-[300px] md:min-h-[500px]">
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-1">Ruta: {selectedDay}</h3>
                        <p className="text-sm text-white mb-6">{routeSlots.length} clientes programados para visitar.</p>
                        
                        {routeSlots.length === 0 ? (
                            <div className="flex flex-col items-center justify-center h-40 border-2 border-dashed border-white/10 rounded-2xl text-gray-500">
                                <span className="text-2xl mb-2">🚗</span>
                                <p className="font-bold">No hay clientes asignados a este día</p>
                            </div>
                        ) : (
                            <div className="space-y-2">
                                {routeSlots.map((slot, index) => (
                                    <div key={slot.slot_id || index} className="flex items-center gap-4 p-4 bg-white/5 border border-white/10 rounded-xl group hover:border-orange-500/50 transition-all">
                                        <div className="flex flex-col gap-1 opacity-20 group-hover:opacity-100 transition-opacity">
                                            <button onClick={() => moveSlot(index, -1)} disabled={index === 0} className="w-6 h-6 rounded bg-black/50 hover:bg-orange-500 text-white flex items-center justify-center disabled:opacity-0">▲</button>
                                            <button onClick={() => moveSlot(index, 1)} disabled={index === routeSlots.length - 1} className="w-6 h-6 rounded bg-black/50 hover:bg-orange-500 text-white flex items-center justify-center disabled:opacity-0">▼</button>
                                        </div>
                                        
                                        <div className="w-8 h-8 rounded-full bg-orange-500/20 border border-orange-500/30 flex items-center justify-center text-orange-400 font-black text-xs shrink-0">
                                            {slot.visit_order}
                                        </div>
                                        
                                        <div className="flex-1">
                                            <div className="font-bold text-amber-400">{slot.client?.name}</div>
                                            <div className="text-xs text-white">{slot.client?.business_name} • {slot.client?.address}</div>
                                        </div>
                                        
                                        <button 
                                            onClick={() => handleRemoveClientFromRoute(index)}
                                            className="w-8 h-8 rounded-full bg-red-500/20 text-red-400 shrink-0 hover:scale-110 transition-all flex items-center justify-center font-black"
                                            title="Remover de este día"
                                        >
                                            -
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Agregar a la ruta */}
                    <div className="bg-black/70 p-4 md:p-6 rounded-[24px] border border-white/5 h-fit lg:sticky top-6">
                        <h3 className="text-sm font-black uppercase tracking-widest text-orange-400 mb-4">Agregar Cliente a {selectedDay}</h3>
                        
                        <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                            {clients.filter(c => c.active).map(c => {
                                const isAlreadyInDay = routeSlots.some(s => s.client_id === c.id);
                                return (
                                    <div key={c.id} className={`p-3 rounded-xl border flex justify-between items-center ${isAlreadyInDay ? 'bg-black/40 border-white/5 opacity-50' : 'bg-white/5 border-white/10 hover:border-orange-500/50'}`}>
                                        <div className="truncate pr-2">
                                            <div className="text-sm font-bold text-amber-400 truncate">{c.name}</div>
                                            <div className="text-[10px] text-white truncate">{c.business_name}</div>
                                        </div>
                                        {isAlreadyInDay ? (
                                            <button 
                                                onClick={() => {
                                                    const idx = routeSlots.findIndex(s => s.client_id === c.id);
                                                    if (idx !== -1) handleRemoveClientFromRoute(idx);
                                                }}
                                                className="w-8 h-8 rounded-full bg-red-500/20 text-red-400 shrink-0 hover:scale-110 transition-all flex items-center justify-center font-black"
                                                title="Quitar de este día"
                                            >
                                                -
                                            </button>
                                        ) : (
                                            <button 
                                                onClick={() => handleAddClientToRoute(c.id)}
                                                className="w-8 h-8 rounded-full bg-orange-600 text-white shrink-0 hover:scale-110 transition-all flex items-center justify-center font-black"
                                                title="Agregar a este día"
                                            >
                                                +
                                            </button>
                                        )}
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    return (
        <div className="h-full flex flex-col text-white overflow-hidden relative" style={{ backgroundColor: '#3a2e1e' }}>
            {/* Fondo de madera */}
            <div className="absolute inset-0 z-0 pointer-events-none" style={{
                backgroundImage: 'url("/assets/wood_bg.jpg")',
                backgroundSize: 'cover',
                backgroundPosition: 'center'
            }} />

            {/* Header Global */}
            <div className="relative z-20 pt-6 px-4 md:px-8 bg-black border-b border-white/10 shadow-2xl">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
                    <div className="flex items-center gap-4 md:gap-6">
                        <div className="w-16 h-16 md:w-24 md:h-24 rounded-2xl md:rounded-3xl overflow-hidden shadow-2xl shadow-orange-500/20 border-2 border-amber-500/30 flex items-center justify-center shrink-0">
                            <img src={`${CONFIG.API_BASE_URL.replace('/api/v1', '')}/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35] md:scale-[1.35]" />
                        </div>
                        <div>
                            <h1 className="text-2xl md:text-4xl font-black uppercase tracking-tighter text-white leading-none">
                                Parámetros <span className="text-amber-400">Generales</span>
                            </h1>
                            <p className="text-xs md:text-sm font-bold text-gray-400 uppercase tracking-widest mt-1">
                                Reparto Pan Grandeza
                            </p>
                        </div>
                    </div>
                    {onBack && (
                        <button
                            onClick={onBack}
                            className="w-full md:w-auto px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-400 hover:text-white hover:bg-white/10 transition-all shrink-0"
                        >
                            ← Volver al Menú
                        </button>
                    )}
                </div>

                {/* Tabs de Navegación Interna */}
                <div className="flex gap-4 md:gap-8 px-2 mt-4 overflow-x-auto whitespace-nowrap custom-scrollbar pb-2">
                    {[
                        { id: 'products', label: 'Productos Vinculados', icon: '🍞' },
                        { id: 'clients', label: 'Directorio de Clientes', icon: '👥' },
                        { id: 'routes', label: 'Rutas por Día', icon: '🗺️' }
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id)}
                            className={`pb-3 px-2 font-black uppercase tracking-widest text-sm transition-all relative shrink-0 ${
                                activeTab === tab.id 
                                ? 'text-amber-400' 
                                : 'text-gray-500 hover:text-gray-300'
                            }`}
                        >
                            <span className="mr-2">{tab.icon}</span>
                            {tab.label}
                            {activeTab === tab.id && (
                                <div className="absolute bottom-[-8px] left-0 w-full h-[3px] bg-amber-400 rounded-t-full shadow-[0_0_10px_rgba(251,191,36,0.8)]"></div>
                            )}
                        </button>
                    ))}
                </div>
            </div>

            {/* Loading Overlay */}
            {loading && (
                <div className="absolute top-8 right-1/2 translate-x-1/2 px-4 py-2 bg-orange-500 text-white text-xs font-bold uppercase tracking-widest rounded-full animate-pulse z-50 shadow-lg shadow-orange-500/20">
                    Sincronizando...
                </div>
            )}

            {/* Contenido Dinámico */}
            <div className="relative z-10 flex-1 overflow-y-auto p-4 md:p-8 custom-scrollbar">
                <div className="max-w-7xl mx-auto">
                    {activeTab === 'products' && renderProductsTab()}
                    {activeTab === 'clients' && renderClientsTab()}
                    {activeTab === 'routes' && renderRoutesTab()}
                </div>
            </div>

            <style>{`
                .custom-scrollbar::-webkit-scrollbar { width: 6px; }
                .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
                .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 10px; }
                .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(59,130,246,0.5); }
                @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }
            `}</style>
        </div>
    );
};
