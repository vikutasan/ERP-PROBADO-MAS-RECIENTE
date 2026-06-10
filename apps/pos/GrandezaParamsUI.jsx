import React, { useState, useEffect } from 'react';

const API_BASE = `http://${window.location.hostname}:5001/api/v1`;

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

    // Tab: Rutas
    const [selectedDay, setSelectedDay] = useState('LUNES');
    const [routeSlots, setRouteSlots] = useState([]);

    const DAYS = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES'];

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
            await fetch(`${API_BASE}/grandeza/routes/${selectedDay}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(slotsToSave)
            });
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
                <div className="bg-black/20 p-6 rounded-[24px] border border-white/5">
                    <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-2">Catálogo B2B (Solo Visualización)</h3>
                    <p className="text-sm text-gray-500 mb-6">
                        Estos son los {linkedProducts.length} productos que están configurados para subir a la ruta de reparto. 
                        Para agregar o quitar productos, ve al <strong>Maestro de Productos</strong> en el menú principal.
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

                                return (
                                    <div key={p.id} className="p-4 rounded-2xl border bg-amber-900/10 border-amber-500/30">
                                        <div className="flex justify-between items-start mb-3">
                                            <div>
                                                <div className="text-xs font-bold text-amber-500 uppercase">{p.sku}</div>
                                                <div className="font-bold text-white">{p.name}</div>
                                                <div className="text-xs text-gray-400 mt-1">Precio Tienda: ${p.price.toFixed(2)}</div>
                                            </div>
                                            <div className="w-8 h-8 rounded-full bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold">
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
                            })}
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const renderClientsTab = () => {
        return (
            <div className="space-y-6 animate-in fade-in duration-500">
                <div className="flex justify-between items-center bg-black/20 p-6 rounded-[24px] border border-white/5">
                    <div>
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-1">Directorio de Clientes</h3>
                        <p className="text-sm text-gray-500">Gestiona los {clients.length} clientes de la ruta Grandeza.</p>
                    </div>
                    <button 
                        onClick={() => setEditingClient({ active: true })}
                        className="px-6 py-2 bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-xs rounded-xl transition-all"
                    >
                        + Nuevo Cliente
                    </button>
                </div>

                <div className="bg-black/20 rounded-[24px] border border-white/5 overflow-hidden">
                    <table className="w-full text-left">
                        <thead className="bg-black/40 text-xs font-bold text-gray-500 uppercase tracking-widest border-b border-white/5">
                            <tr>
                                <th className="p-4">Cliente / Negocio</th>
                                <th className="p-4">Contacto</th>
                                <th className="p-4">Ubicación</th>
                                <th className="p-4 text-center">Estado</th>
                                <th className="p-4 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {clients.map(c => (
                                <tr key={c.id} className="hover:bg-white/5 transition-colors">
                                    <td className="p-4">
                                        <div className="font-bold text-white">{c.name}</div>
                                        <div className="text-xs text-gray-400">{c.business_name || 'Sin negocio registrado'}</div>
                                    </td>
                                    <td className="p-4">
                                        <div className="text-sm text-gray-300">{c.phone || '-'}</div>
                                    </td>
                                    <td className="p-4">
                                        <div className="text-sm text-gray-300 truncate max-w-[200px]">{c.address || '-'}</div>
                                        {c.google_maps_url && (
                                            <a href={c.google_maps_url} target="_blank" rel="noreferrer" className="text-xs text-blue-400 hover:underline">Ver en Mapa</a>
                                        )}
                                    </td>
                                    <td className="p-4 text-center">
                                        <span className={`px-2 py-1 rounded-full text-[10px] font-black uppercase tracking-widest ${c.active ? 'bg-green-500/20 text-green-400 border border-green-500/30' : 'bg-red-500/20 text-red-400 border border-red-500/30'}`}>
                                            {c.active ? 'Activo' : 'Inactivo'}
                                        </span>
                                    </td>
                                    <td className="p-4 text-right">
                                        <button 
                                            onClick={() => setEditingClient(c)}
                                            className="px-4 py-1.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-xs font-bold text-white transition-all"
                                        >
                                            Editar
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
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
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Nombre del Cliente *</label>
                                        <input required name="name" defaultValue={editingClient.name} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Nombre del Negocio</label>
                                        <input name="business_name" defaultValue={editingClient.business_name} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Teléfono</label>
                                        <input name="phone" defaultValue={editingClient.phone} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Estado</label>
                                        <select name="active" defaultValue={editingClient.active} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500 appearance-none">
                                            <option value="true">Activo</option>
                                            <option value="false">Inactivo</option>
                                        </select>
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Dirección Física</label>
                                        <input name="address" defaultValue={editingClient.address} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500" />
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">URL Google Maps</label>
                                        <input name="google_maps_url" defaultValue={editingClient.google_maps_url} className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500 text-blue-400" />
                                    </div>
                                    <div className="col-span-2">
                                        <label className="block text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Notas / Instrucciones de entrega</label>
                                        <textarea name="notes" defaultValue={editingClient.notes} rows="2" className="w-full bg-black/40 border border-white/10 rounded-xl p-3 text-white outline-none focus:border-blue-500"></textarea>
                                    </div>
                                </div>
                                <div className="flex justify-end gap-3 mt-8">
                                    <button type="button" onClick={() => setEditingClient(null)} className="px-6 py-3 border border-white/10 rounded-xl text-sm font-bold text-gray-400 hover:bg-white/5">Cancelar</button>
                                    <button type="submit" className="px-8 py-3 bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-sm rounded-xl transition-all shadow-lg shadow-blue-500/20">Guardar Cliente</button>
                                </div>
                            </form>
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
                <div className="flex gap-2 p-2 bg-black/40 rounded-2xl border border-white/5">
                    {DAYS.map(day => (
                        <button
                            key={day}
                            onClick={() => setSelectedDay(day)}
                            className={`flex-1 py-3 px-4 rounded-xl font-black uppercase tracking-widest text-xs transition-all ${
                                selectedDay === day 
                                ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20 scale-[1.02]' 
                                : 'text-gray-500 hover:bg-white/5 hover:text-white'
                            }`}
                        >
                            {day}
                        </button>
                    ))}
                </div>

                <div className="grid grid-cols-3 gap-6">
                    {/* Lista de la ruta del día */}
                    <div className="col-span-2 bg-black/20 p-6 rounded-[24px] border border-white/5 min-h-[500px]">
                        <h3 className="text-xl font-black uppercase tracking-tighter text-white mb-1">Ruta: {selectedDay}</h3>
                        <p className="text-sm text-gray-500 mb-6">{routeSlots.length} clientes programados para visitar.</p>
                        
                        {routeSlots.length === 0 ? (
                            <div className="flex flex-col items-center justify-center h-40 border-2 border-dashed border-white/10 rounded-2xl text-gray-500">
                                <span className="text-2xl mb-2">🚗</span>
                                <p className="font-bold">No hay clientes asignados a este día</p>
                            </div>
                        ) : (
                            <div className="space-y-2">
                                {routeSlots.map((slot, index) => (
                                    <div key={slot.slot_id || index} className="flex items-center gap-4 p-4 bg-white/5 border border-white/10 rounded-xl group hover:border-blue-500/50 transition-all">
                                        <div className="flex flex-col gap-1 opacity-20 group-hover:opacity-100 transition-opacity">
                                            <button onClick={() => moveSlot(index, -1)} disabled={index === 0} className="w-6 h-6 rounded bg-black/50 hover:bg-blue-500 text-white flex items-center justify-center disabled:opacity-0">▲</button>
                                            <button onClick={() => moveSlot(index, 1)} disabled={index === routeSlots.length - 1} className="w-6 h-6 rounded bg-black/50 hover:bg-blue-500 text-white flex items-center justify-center disabled:opacity-0">▼</button>
                                        </div>
                                        
                                        <div className="w-8 h-8 rounded-full bg-blue-500/20 border border-blue-500/30 flex items-center justify-center text-blue-400 font-black text-xs shrink-0">
                                            {slot.visit_order}
                                        </div>
                                        
                                        <div className="flex-1">
                                            <div className="font-bold text-white">{slot.client?.name}</div>
                                            <div className="text-xs text-gray-400">{slot.client?.business_name} • {slot.client?.address}</div>
                                        </div>
                                        
                                        <button 
                                            onClick={() => handleRemoveClientFromRoute(index)}
                                            className="w-8 h-8 rounded-full hover:bg-red-500/20 hover:text-red-400 text-gray-600 flex items-center justify-center transition-all opacity-0 group-hover:opacity-100"
                                            title="Remover de este día"
                                        >
                                            ✕
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Agregar a la ruta */}
                    <div className="bg-black/20 p-6 rounded-[24px] border border-white/5 h-fit sticky top-6">
                        <h3 className="text-sm font-black uppercase tracking-widest text-blue-400 mb-4">Agregar Cliente a {selectedDay}</h3>
                        
                        <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                            {clients.filter(c => c.active).map(c => {
                                const isAlreadyInDay = routeSlots.some(s => s.client_id === c.id);
                                return (
                                    <div key={c.id} className={`p-3 rounded-xl border flex justify-between items-center ${isAlreadyInDay ? 'bg-black/40 border-white/5 opacity-50' : 'bg-white/5 border-white/10 hover:border-blue-500/50'}`}>
                                        <div className="truncate pr-2">
                                            <div className="text-sm font-bold text-white truncate">{c.name}</div>
                                            <div className="text-[10px] text-gray-500 truncate">{c.business_name}</div>
                                        </div>
                                        <button 
                                            onClick={() => handleAddClientToRoute(c.id)}
                                            disabled={isAlreadyInDay}
                                            className="w-8 h-8 rounded-full bg-blue-600 text-white shrink-0 hover:scale-110 disabled:opacity-0 disabled:scale-100 transition-all flex items-center justify-center font-black"
                                        >
                                            +
                                        </button>
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
            <div className="relative z-20 pt-6 px-8 bg-black border-b border-white/10 shadow-2xl">
                <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center gap-6">
                        <div className="w-24 h-24 rounded-3xl overflow-hidden shadow-2xl shadow-orange-500/20 border-2 border-amber-500/30 flex items-center justify-center shrink-0">
                            <img src={`http://${window.location.hostname}:5001/static/images/grandeza/logo.png`} alt="Grandeza" className="w-full h-full object-cover scale-[1.35]" />
                        </div>
                        <div>
                            <h1 className="text-4xl font-black uppercase tracking-tighter text-white leading-none">
                                Parámetros <span className="text-amber-400">Generales</span>
                            </h1>
                            <p className="text-sm font-bold text-gray-400 uppercase tracking-widest mt-1">
                                Reparto Pan Grandeza
                            </p>
                        </div>
                    </div>
                    {onBack && (
                        <button
                            onClick={onBack}
                            className="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl text-sm font-black uppercase tracking-widest text-gray-400 hover:text-white hover:bg-white/10 transition-all shrink-0"
                        >
                            ← Volver al Menú
                        </button>
                    )}
                </div>

                {/* Tabs de Navegación Interna */}
                <div className="flex gap-8 px-2 mt-4">
                    {[
                        { id: 'products', label: 'Productos Vinculados', icon: '🍞' },
                        { id: 'clients', label: 'Directorio de Clientes', icon: '👥' },
                        { id: 'routes', label: 'Rutas por Día', icon: '🗺️' }
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id)}
                            className={`pb-4 px-2 font-black uppercase tracking-widest text-sm transition-all relative ${
                                activeTab === tab.id 
                                ? 'text-amber-400' 
                                : 'text-gray-500 hover:text-gray-300'
                            }`}
                        >
                            <span className="mr-2">{tab.icon}</span>
                            {tab.label}
                            {activeTab === tab.id && (
                                <div className="absolute bottom-0 left-0 w-full h-[3px] bg-amber-400 rounded-t-full shadow-[0_0_10px_rgba(251,191,36,0.8)]"></div>
                            )}
                        </button>
                    ))}
                </div>
            </div>

            {/* Loading Overlay */}
            {loading && (
                <div className="absolute top-8 right-1/2 translate-x-1/2 px-4 py-2 bg-blue-500 text-white text-xs font-bold uppercase tracking-widest rounded-full animate-pulse z-50 shadow-lg shadow-blue-500/20">
                    Sincronizando...
                </div>
            )}

            {/* Contenido Dinámico */}
            <div className="relative z-10 flex-1 overflow-y-auto p-8 custom-scrollbar">
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
