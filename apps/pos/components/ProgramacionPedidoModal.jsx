import React, { useState, useEffect } from 'react';
import { X, Clock, Package, User, Phone, MapPin, Calendar } from 'lucide-react';

const API_BASE = `http://${window.location.hostname}:5001/api/v1`;

/**
 * SUITE: Programación del Pedido
 * SRP: Solo maneja la captura de datos del pedido (Pick Up o Domicilio).
 * No modifica la lógica del carrito ni del cobro.
 */
export const ProgramacionPedidoModal = ({ cart, currentAccountNum, onClose, onSave }) => {
    const [deliveryType, setDeliveryType] = useState('PICKUP'); // 'PICKUP' | 'DOMICILIO'
    const [earliestReady, setEarliestReady] = useState(null);
    const [formData, setFormData] = useState({
        customer_name: '',
        customer_phone: '',
        committed_at: '',
        packaging_type: 'PROPIO',
        delivery_address: '',
        notes: '',
    });
    const [saving, setSaving] = useState(false);
    const [confirmed, setConfirmed] = useState(false);

    // Calcular fecha más próxima de entrega basándose en preparation_time_min de cada producto
    useEffect(() => {
        if (!cart?.length) return;
        const maxPrepMin = calcMaxPrepTime(cart);
        const ready = new Date(Date.now() + maxPrepMin * 60 * 1000);
        setEarliestReady(ready);

        // Pre-llenar la fecha compromiso con la más próxima disponible
        const localIso = toLocalIsoString(ready);
        setFormData(prev => ({ ...prev, committed_at: localIso }));
    }, [cart]);

    const canSave = formData.customer_name.trim() && formData.customer_phone.trim() && formData.committed_at;

    const handleSave = async () => {
        if (!canSave) return;
        setSaving(true);
        try {
            const payload = {
                ticket_id: null, // se vinculará cuando se guarde el ticket
                delivery_type: deliveryType,
                customer_name: formData.customer_name.trim(),
                customer_phone: formData.customer_phone.trim(),
                earliest_ready_at: earliestReady?.toISOString() ?? null,
                committed_at: new Date(formData.committed_at).toISOString(),
                packaging_type: formData.packaging_type,
                delivery_address: deliveryType === 'DOMICILIO' ? formData.delivery_address : null,
                notes: formData.notes || null,
            };
            setConfirmed(true);
            // Devolver los datos al POS para marcar la cuenta como PEDIDO TENTATIVO
            setTimeout(() => onSave(payload), 1500);
        } catch (e) {
            console.error('Error guardando pedido tentativo:', e);
        } finally {
            setSaving(false);
        }
    };

    const field = (label, id, value, onChange, type = 'text', placeholder = '') => (
        <label className="block">
            <span className="text-[11px] font-black uppercase text-white/60 tracking-widest pl-2">{label}</span>
            <input
                id={id}
                type={type}
                value={value}
                onChange={e => onChange(e.target.value)}
                placeholder={placeholder}
                className="w-full mt-1 bg-white/10 border border-white/10 rounded-2xl px-4 py-3 text-white font-bold outline-none focus:border-orange-500/60 transition-colors placeholder-white/20"
            />
        </label>
    );

    if (confirmed) {
        return (
            <div className="fixed inset-0 bg-black/90 backdrop-blur-xl flex items-center justify-center z-[150]">
                <div className="bg-[#1a1a1a] border border-orange-500/30 rounded-[40px] p-12 text-center max-w-md w-full animate-in zoom-in-95 duration-300">
                    <div className="text-7xl mb-4">📦</div>
                    <h2 className="text-2xl font-black text-orange-400 uppercase tracking-tight mb-2">Pedido Tentativo Registrado</h2>
                    <p className="text-sm text-white/60 leading-relaxed">
                        El sistema procesará el pedido <span className="text-orange-400 font-black">solo cuando el pago sea recibido al 100%.</span>
                        <br/><br/>
                        El cajero podrá confirmar los detalles con el cliente antes de cobrar.
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="fixed inset-0 bg-black/85 backdrop-blur-xl flex items-center justify-center z-[150] p-6">
            <div className="bg-[#111] border border-orange-500/20 rounded-[40px] w-full max-w-2xl max-h-[90vh] flex flex-col shadow-[0_0_80px_rgba(249,115,22,0.15)] animate-in zoom-in-95 duration-300">

                {/* Header del modal */}
                <div className="flex items-center justify-between p-8 pb-4 border-b border-white/5">
                    <div>
                        <h2 className="text-3xl font-black uppercase text-white tracking-tight italic">
                            Programación del <span className="text-orange-400">Pedido</span>
                        </h2>
                        {currentAccountNum && (
                            <p className="text-[10px] font-black text-orange-400/60 uppercase tracking-widest mt-1">
                                CTA #{currentAccountNum.slice(-3)} • {cart?.length || 0} artículo(s)
                            </p>
                        )}
                    </div>
                    <button onClick={onClose} className="p-3 rounded-full bg-white/5 hover:bg-white/10 text-white/60 hover:text-white transition-all">
                        <X size={22} />
                    </button>
                </div>

                {/* Contenido scrollable */}
                <div className="flex-1 overflow-y-auto p-8 space-y-6 custom-scrollbar">

                    {/* Tipo de Entrega */}
                    <div>
                        <p className="text-[11px] font-black uppercase text-white/60 tracking-widest mb-2">Tipo de Entrega</p>
                        <div className="flex bg-white/5 border border-white/10 rounded-2xl p-1 gap-1 w-fit">
                            {['PICKUP', 'DOMICILIO'].map(type => (
                                <button
                                    key={type}
                                    onClick={() => setDeliveryType(type)}
                                    className={`px-6 py-2.5 rounded-xl text-[12px] font-black uppercase tracking-widest transition-all ${
                                        deliveryType === type
                                            ? 'bg-orange-500 text-white shadow-lg'
                                            : 'text-white/40 hover:text-white'
                                    }`}
                                >
                                    {type === 'PICKUP' ? '🏪 Pick Up' : '🚗 Domicilio'}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Fecha más próxima calculada */}
                    {earliestReady && (
                        <div className="bg-orange-500/10 border border-orange-500/20 rounded-2xl px-5 py-3 flex items-center gap-3">
                            <Clock size={18} className="text-orange-400 flex-shrink-0" />
                            <div>
                                <p className="text-[10px] font-black text-orange-400/60 uppercase tracking-widest">Fecha más próxima posible (cálculo del sistema)</p>
                                <p className="text-sm font-black text-orange-300">{formatDateTime(earliestReady)}</p>
                            </div>
                        </div>
                    )}

                    {/* Fecha y hora compromiso */}
                    <label className="block">
                        <span className="text-[11px] font-black uppercase text-white/60 tracking-widest pl-2 flex items-center gap-2">
                            <Calendar size={13}/> Fecha y Hora Compromiso de Entrega
                        </span>
                        <input
                            id="input-committed-at"
                            type="datetime-local"
                            value={formData.committed_at}
                            onChange={e => setFormData(p => ({ ...p, committed_at: e.target.value }))}
                            min={earliestReady ? toLocalIsoString(earliestReady) : undefined}
                            className="w-full mt-1 bg-white/10 border border-white/10 rounded-2xl px-4 py-3 text-white font-bold outline-none focus:border-orange-500/60 transition-colors"
                        />
                    </label>

                    {/* Datos del cliente */}
                    <div className="grid grid-cols-2 gap-4">
                        {field('Nombre del Cliente', 'input-customer-name', formData.customer_name,
                            v => setFormData(p => ({ ...p, customer_name: v })), 'text', 'Ej: María García')}
                        {field('Teléfono', 'input-customer-phone', formData.customer_phone,
                            v => setFormData(p => ({ ...p, customer_phone: v })), 'tel', 'Ej: 312 123 4567')}
                    </div>

                    {/* Empaque */}
                    <div>
                        <p className="text-[11px] font-black uppercase text-white/60 tracking-widest mb-2 flex items-center gap-2">
                            <Package size={13}/> Empaque
                        </p>
                        <div className="flex bg-white/5 border border-white/10 rounded-2xl p-1 gap-1 w-fit">
                            {[
                                { value: 'PROPIO', label: '🛍️ Empaque Propio del Cliente' },
                                { value: 'VENTA',  label: '📦 Vender Empaque' },
                            ].map(opt => (
                                <button
                                    key={opt.value}
                                    onClick={() => setFormData(p => ({ ...p, packaging_type: opt.value }))}
                                    className={`px-5 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                                        formData.packaging_type === opt.value
                                            ? 'bg-[#c1d72e] text-black shadow-lg'
                                            : 'text-white/40 hover:text-white'
                                    }`}
                                >
                                    {opt.label}
                                </button>
                            ))}
                        </div>
                        {formData.packaging_type === 'VENTA' && (
                            <p className="text-[10px] text-orange-400/70 mt-2 pl-2">
                                💡 Agrega el empaque al carrito como producto de la categoría EMPAQUES antes de programar.
                            </p>
                        )}
                    </div>

                    {/* Domicilio: campos adicionales */}
                    {deliveryType === 'DOMICILIO' && (
                        <label className="block animate-in fade-in duration-300">
                            <span className="text-[11px] font-black uppercase text-white/60 tracking-widest pl-2 flex items-center gap-2">
                                <MapPin size={13}/> Dirección de Entrega
                            </span>
                            <textarea
                                id="input-delivery-address"
                                value={formData.delivery_address}
                                onChange={e => setFormData(p => ({ ...p, delivery_address: e.target.value }))}
                                placeholder="Calle, número, colonia, referencias..."
                                rows={3}
                                className="w-full mt-1 bg-white/10 border border-white/10 rounded-2xl px-4 py-3 text-white font-bold outline-none focus:border-orange-500/60 transition-colors placeholder-white/20 resize-none"
                            />
                        </label>
                    )}

                    {/* Notas */}
                    {field('Notas adicionales (opcional)', 'input-notes', formData.notes,
                        v => setFormData(p => ({ ...p, notes: v })), 'text', 'Ej: Sin azúcar, entregar antes de las 10am...')}
                </div>

                {/* Footer con botón Guardar */}
                <div className="p-6 pt-4 border-t border-white/5">
                    <button
                        id="btn-guardar-pedido"
                        onClick={handleSave}
                        disabled={!canSave || saving}
                        className={`w-full py-4 rounded-[25px] font-black uppercase tracking-widest text-lg transition-all ${
                            canSave
                                ? 'bg-orange-500 text-white hover:bg-orange-400 active:scale-95 shadow-[0_10px_30px_rgba(249,115,22,0.3)]'
                                : 'bg-white/5 text-white/20 cursor-not-allowed'
                        }`}
                    >
                        {saving ? 'Guardando...' : '📌 Guardar Pedido Tentativo'}
                    </button>
                    {!canSave && (
                        <p className="text-center text-[10px] text-white/30 mt-2 uppercase tracking-widest">
                            Completa nombre, teléfono y fecha de entrega para continuar
                        </p>
                    )}
                </div>
            </div>
        </div>
    );
};

// ─── Helpers ────────────────────────────────────────────────────────────────

/** Calcula el tiempo máximo de preparación entre todos los ítems del carrito (en minutos). */
function calcMaxPrepTime(cart) {
    const DEFAULT_PREP_MIN = 60; // 1 hora por defecto si el producto no tiene ficha técnica
    const max = cart.reduce((acc, item) => {
        const prepMin = item.technical_sheet?.preparation_time_min ?? DEFAULT_PREP_MIN;
        return Math.max(acc, prepMin);
    }, DEFAULT_PREP_MIN);
    return max;
}

/** Convierte un Date a string datetime-local (ISO sin zona horaria) para un input. */
function toLocalIsoString(date) {
    const pad = n => String(n).padStart(2, '0');
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/** Formatea un Date a una cadena legible en español. */
function formatDateTime(date) {
    return date.toLocaleString('es-MX', {
        weekday: 'short', day: '2-digit', month: 'short',
        hour: '2-digit', minute: '2-digit'
    });
}
