import React, { forwardRef } from 'react';

export const TicketTemplate = forwardRef(({ ticket, cart, total, payments }, ref) => {
    const today = new Date().toLocaleString();
    
    return (
        <div ref={ref} className="print-ticket bg-white text-black w-[80mm] font-mono text-[10px] leading-tight">
            <style>
                {`
                    @media print {
                        @page { margin: 0; size: 80mm auto; }
                        body { margin: 0; padding: 0; }
                        .print-ticket { 
                            width: 80mm; 
                            background: white; 
                            color: black;
                            padding: 2mm; 
                            margin: 0;
                        }
                    }
                    .print-ticket { padding: 4mm; }
                    .dotted-line { border-top: 1px dotted #000; margin: 2px 0; }
                    .compact-row { display: flex; justify-content: space-between; margin-bottom: 1px; }
                `}
            </style>
            
            {/* Header */}
            <div className="text-center font-bold text-[12px] mb-0.5 uppercase">R de Rico</div>
            <div className="text-center text-[8px] mb-1">
                {today}<br/>
                No. Cuenta: {(ticket?.account_num || '---').slice(-2)}
            </div>

            <div className="dotted-line"></div>

            {/* Items Table */}
            <table className="w-full mb-1">
                <tbody>
                    {cart.map((item, idx) => (
                        <tr key={idx} className="align-top">
                            <td className="w-6">{item.quantity}x</td>
                            <td className="truncate max-w-[40mm]">{item.name}</td>
                            <td className="text-right font-bold pl-2">${(item.price * item.quantity).toFixed(2)}</td>
                        </tr>
                    ))}
                </tbody>
            </table>

            <div className="dotted-line"></div>

            {/* Totals */}
            <div className="flex justify-between font-bold text-[11px] my-1">
                <span>TOTAL</span>
                <span>${total.toFixed(2)}</span>
            </div>

            {/* Payment Details */}
            <div className="text-[7px] leading-[1.1]">
                {payments?.length > 0 && payments.map((p, idx) => (
                    <div key={idx} className="flex justify-between italic">
                        <span>{p.method} {p.type ? `(${p.type})` : ''}</span>
                        <span>${p.amount.toFixed(2)}</span>
                    </div>
                ))}
            </div>

            <div className="text-center text-[7px] italic mt-2 border-t pt-1">
                *** Disfrute su pan ***
            </div>
        </div>
    );
});
