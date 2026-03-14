import React, { useState, useEffect } from 'react';

export const CheckoutScreen = ({ total, onConfirm, onClose, onFinish, onPrint }) => {
    const [payments, setPayments] = useState([]);
    const [receivedAmount, setReceivedAmount] = useState('');
    const [paymentMethod, setPaymentMethod] = useState('EFECTIVO');
    const [cardType, setCardType] = useState('DEBITO'); // DEBITO, CREDITO, QR
    const [isLiquidado, setIsLiquidado] = useState(false);
    
    const totalPaid = payments.reduce((acc, p) => acc + p.amount, 0);
    const pendingAmount = Math.max(0, total - totalPaid);
    const change = Math.max(0, (parseFloat(receivedAmount) || 0) + totalPaid - total);

    const handleNumberClick = (num) => {
        if (receivedAmount.includes('.') && num === '.') return;
        setReceivedAmount(prev => prev + num);
    };

    const handleClear = () => setReceivedAmount('');

    const handleAddPayment = () => {
        if (isLiquidado) return;
        const amount = parseFloat(receivedAmount);
        if (!amount || amount <= 0) return;

        const newPayment = {
            method: paymentMethod,
            amount: Math.min(amount, pendingAmount + change), // No abonar más del total si es efectivo, el resto es cambio
            displayAmount: amount,
            type: paymentMethod === 'TARJETA' ? cardType : null,
            id: Date.now()
        };

        if (paymentMethod === 'EFECTIVO') {
            // El efectivo siempre liquida o abona. Si hay cambio, el abono físico es el total pendiente.
            const realAbono = Math.min(amount, pendingAmount);
            setPayments([...payments, { ...newPayment, amount: realAbono }]);
        } else {
            // Tarjeta no suele tener cambio en el ERP
            setPayments([...payments, { ...newPayment, amount: Math.min(amount, pendingAmount) }]);
        }
        
        setReceivedAmount('');
    };

    const handleFinalize = async () => {
        if (isLiquidado) return;
        
        // Calcular pagos finales localmente (sin depender del state de React)
        let finalPayments = [...payments];
        const entered = parseFloat(receivedAmount) || 0;
        const currentPending = Math.max(0, total - finalPayments.reduce((s, p) => s + p.amount, 0));
        
        // Si hay monto ingresado y saldo pendiente, agregarlo a los pagos
        if (currentPending > 0 && entered > 0) {
            const realAbono = paymentMethod === 'EFECTIVO' 
                ? Math.min(entered, currentPending) 
                : Math.min(entered, currentPending);
            finalPayments = [...finalPayments, {
                method: paymentMethod,
                amount: realAbono,
                displayAmount: entered,
                type: paymentMethod === 'TARJETA' ? cardType : null,
                id: Date.now()
            }];
        }
        
        const totalFinalPaid = finalPayments.reduce((s, p) => s + p.amount, 0);
        
        if (totalFinalPaid >= total) {
            try {
                await onConfirm(finalPayments);
                setIsLiquidado(true);
            } catch (error) {
                console.error("Error liquidando:", error);
                alert("Hubo un error al liquidar la cuenta. Intente de nuevo.");
            }
        } else {
            alert('Aún queda saldo pendiente por cubrir.');
        }
    };


    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-xl animate-in fade-in duration-300">
            <div className="bg-[#1a1a1a] w-[600px] rounded-[50px] border border-white/10 shadow-[0_0_100px_rgba(193,215,46,0.1)] overflow-hidden flex flex-col">
                {/* Header */}
                <div className="p-8 border-b border-white/5 flex justify-between items-center bg-black/20">
                    <div>
                        <h2 className="text-3xl font-black uppercase italic tracking-tighter text-white">SUITE DE <span className="text-[#c1d72e]">COBRO</span></h2>
                        <p className="text-[10px] font-bold text-gray-500 uppercase tracking-[0.4em] mt-1 italic">Gestión de Pagos Mixtos</p>
                    </div>
                    <button onClick={isLiquidado ? onFinish : onClose} className="w-12 h-12 rounded-full bg-white/5 flex items-center justify-center text-2xl hover:bg-red-500/20 hover:text-red-500 transition-all">✕</button>
                </div>

                <div className="flex flex-row flex-1 overflow-hidden">
                    {/* Left Panel: Payment Entry */}
                    <div className="w-3/5 p-8 border-r border-white/5 space-y-6">
                        {/* Status Display */}
                        <div className="flex flex-col bg-black/40 p-5 rounded-3xl border border-white/5">
                            <div className="flex justify-between items-center opacity-50 mb-1">
                                <span className="text-[9px] font-black uppercase tracking-widest text-gray-400">Total Original</span>
                                <span className="text-sm font-bold font-mono">${total.toFixed(2)}</span>
                            </div>
                            <div className="flex justify-between items-end">
                                <span className="text-[10px] font-black uppercase text-[#c1d72e] tracking-widest">Saldo Pendiente</span>
                                <span className="text-4xl font-black text-[#c1d72e] font-mono tracking-tighter">${pendingAmount.toFixed(2)}</span>
                            </div>
                        </div>

                        {/* Method Selector */}
                        <div className="grid grid-cols-2 gap-3">
                            <button 
                                onClick={() => setPaymentMethod('EFECTIVO')}
                                className={`py-4 rounded-2xl border-2 transition-all flex items-center justify-center gap-3 ${paymentMethod === 'EFECTIVO' ? 'border-[#c1d72e] bg-[#c1d72e]/10 text-[#c1d72e]' : 'border-white/5 bg-white/5 text-gray-400'}`}
                            >
                                <span className="text-xl">💵</span>
                                <span className="text-[9px] font-black uppercase tracking-widest">Efectivo</span>
                            </button>
                            <button 
                                onClick={() => setPaymentMethod('TARJETA')}
                                className={`py-4 rounded-2xl border-2 transition-all flex items-center justify-center gap-3 ${paymentMethod === 'TARJETA' ? 'border-orange-500 bg-orange-500/10 text-orange-500' : 'border-white/5 bg-white/5 text-gray-400'}`}
                            >
                                <span className="text-xl">💳</span>
                                <span className="text-[9px] font-black uppercase tracking-widest">Tarjeta</span>
                            </button>
                        </div>

                        {paymentMethod === 'TARJETA' && (
                            <div className="grid grid-cols-3 gap-2 animate-in fade-in zoom-in-95 duration-300">
                                {['DEBITO', 'CREDITO', 'QR'].map(t => (
                                    <button 
                                        key={t}
                                        onClick={() => setCardType(t)}
                                        className={`py-2 rounded-xl text-[8px] font-black uppercase tracking-widest border transition-all ${cardType === t ? 'bg-orange-500 text-black border-orange-500 shadow-lg shadow-orange-500/20' : 'bg-white/5 text-gray-500 border-white/5 hover:border-white/20'}`}
                                    >
                                        {t}
                                    </button>
                                ))}
                            </div>
                        )}

                        {/* Input Area */}
                        <div className="space-y-4">
                            <div className="bg-white text-black p-4 rounded-2xl text-4xl font-black text-right shadow-inner min-h-[70px] flex flex-col justify-center">
                                <span className="text-[8px] absolute top-[-10px] left-2 font-black uppercase text-gray-400">Importe a Recibir</span>
                                {receivedAmount ? `$${receivedAmount}` : '$0.00'}
                            </div>

                            <div className="grid grid-cols-3 gap-2">
                                {[1, 2, 3, 4, 5, 6, 7, 8, 9, '.', 0].map((num) => (
                                    <button 
                                        key={num}
                                        disabled={isLiquidado}
                                        onClick={() => handleNumberClick(num.toString())}
                                        className={`h-12 rounded-xl border text-lg font-black transition-all ${isLiquidado ? 'bg-white/5 border-white/5 text-gray-700 cursor-not-allowed' : 'bg-white/5 border-white/10 hover:bg-white/10 active:scale-90 text-white'}`}
                                    >
                                        {num}
                                    </button>
                                ))}
                                <button disabled={isLiquidado} onClick={handleClear} className={`h-12 rounded-xl text-[10px] font-black uppercase transition-all ${isLiquidado ? 'bg-red-500/5 text-red-500/20 cursor-not-allowed' : 'bg-red-500/10 text-red-500 hover:bg-red-500/20'}`}>C</button>
                            </div>
                        </div>
                    </div>

                    {/* Right Panel: Payments List */}
                    <div className="w-2/5 p-8 bg-black/10 flex flex-col">
                        <h3 className="text-[9px] font-black uppercase tracking-[0.3em] text-gray-500 mb-6 flex items-center gap-2">
                            <span className="w-1.5 h-1.5 rounded-full bg-orange-500 animate-pulse"></span>
                            Resumen de Pagos
                        </h3>

                        <div className="flex-1 space-y-3 overflow-y-auto custom-scrollbar pr-2">
                            {payments.map(p => (
                                <div key={p.id} className="bg-white/5 border border-white/5 p-4 rounded-2xl flex justify-between items-center animate-in slide-in-from-right-4 duration-300">
                                    <div>
                                        <p className="text-[9px] font-black uppercase text-white/90 tracking-tighter">{p.method} {p.type && `(${p.type})`}</p>
                                        <p className="text-[8px] text-gray-500 font-bold uppercase tracking-widest mt-0.5">Procesado</p>
                                    </div>
                                    <span className="text-sm font-black text-[#c1d72e] font-mono">+${p.amount.toFixed(2)}</span>
                                </div>
                            ))}
                            {payments.length === 0 && (
                                <div className="h-full flex flex-col items-center justify-center text-gray-700 text-center px-4">
                                    <span className="text-4xl mb-4 opacity-10">🎫</span>
                                    <p className="text-[9px] font-black uppercase tracking-widest opacity-30 italic leading-relaxed">No hay abonos registrados para esta cuenta</p>
                                </div>
                            )}
                        </div>

                        {change > 0 && (
                            <div className="mt-4 p-4 bg-[#c1d72e] rounded-2xl animate-in zoom-in-95 duration-300">
                                <div className="flex justify-between items-center">
                                    <span className="text-[9px] font-black uppercase text-black/60 tracking-widest">Cambio a entregar</span>
                                    <span className="text-xl font-black text-black font-mono">-${change.toFixed(2)}</span>
                                </div>
                            </div>
                        )}
                    </div>
                </div>

                {/* Footer Action */}
                <div className="p-8 bg-black/40 border-t border-white/5 flex gap-4">
                    {!isLiquidado ? (
                        <>
                            <button 
                                disabled={!receivedAmount || pendingAmount <= 0}
                                onClick={handleAddPayment}
                                className="flex-1 bg-white/10 text-white font-black py-5 rounded-[25px] text-[10px] uppercase tracking-widest hover:bg-white/20 active:scale-95 transition-all disabled:opacity-20"
                            >
                                Abonar Pago
                            </button>
                            <button 
                                onClick={handleFinalize}
                                className={`flex-[1.5] py-5 rounded-[25px] text-lg font-black uppercase italic tracking-tighter transition-all shadow-2xl active:scale-95 ${pendingAmount <= 0 || (receivedAmount && parseFloat(receivedAmount) >= pendingAmount) ? 'bg-[#c1d72e] text-black shadow-[#c1d72e]/20' : 'bg-gray-800 text-gray-500 grayscale cursor-not-allowed'}`}
                            >
                                {pendingAmount <= 0 ? 'Liquidar Cuenta' : 'Liquidar Cuenta'}
                            </button>
                        </>
                    ) : (
                        <div className="flex-1 flex gap-4 animate-in slide-in-from-bottom-4 duration-500">
                            <button 
                                onClick={onFinish}
                                className="flex-1 bg-gray-800 hover:bg-gray-700 text-white font-black py-5 rounded-[25px] text-xs uppercase tracking-widest transition-all"
                            >
                                CERRAR (SIN TICKET)
                            </button>
                            <button 
                                onClick={onPrint}
                                className="flex-[2] bg-orange-500 hover:bg-orange-600 text-white font-black py-5 rounded-[25px] text-lg uppercase italic tracking-tighter transition-all shadow-[0_0_30px_rgba(249,115,22,0.4)] hover:shadow-[0_0_50px_rgba(249,115,22,0.6)]"
                            >
                                🖨️ IMPRIMIR TICKET
                            </button>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};
