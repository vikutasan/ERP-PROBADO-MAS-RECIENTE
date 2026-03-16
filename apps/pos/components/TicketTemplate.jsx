import React, { forwardRef } from 'react';

export const TicketTemplate = forwardRef(({ ticket, cart, total, payments }, ref) => {
    const today = new Date().toLocaleString();
    
    return (
        <div ref={ref} className="print-ticket bg-white text-black w-[80mm] font-mono text-[9px] leading-[1.1]">
            <style>
                {`
                    @media print {
                        @page { margin: 0; size: 80mm auto; }
                        body { margin: 0; padding: 0; }
                        .print-ticket { 
                            width: 80mm; 
                            background: white; 
                            color: black;
                            padding: 1mm 2mm; 
                            margin: 0;
                        }
                    }
                    .print-ticket { padding: 2mm 4mm; }
                    .dotted-line { border-top: 1px dotted #000; margin: 1px 0; }
                    .compact-row { display: flex; justify-content: space-between; margin-bottom: 0px; }
                `}
            </style>
            
            {/* Header Ultra Compacto */}
            <div className="text-center font-bold text-[11px] uppercase">R de Rico</div>
            <div className="text-center text-[7.5px] mb-0.5">
                {today} | CTA: {ticket?.account_num || '---'}
            </div>
 
            <div className="dotted-line"></div>
 
            {/* Items Table - Espaciado Mínimo */}
            <table className="w-full mb-0.5">
                <tbody>
                    {cart.map((item, idx) => (
                        <tr key={idx} className="align-top">
                            <td className="w-5">{item.quantity}x</td>
                            <td className="truncate max-w-[45mm]">{item.name}</td>
                            <td className="text-right font-bold pl-1">${(item.price * item.quantity).toFixed(2)}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
 
            <div className="dotted-line"></div>
 
            {/* Totals */}
            <div className="flex justify-between font-bold text-[10px] my-0.5">
                <span>TOTAL</span>
                <span>${total.toFixed(2)}</span>
            </div>
 
            {/* Payment Details */}
            <div className="text-[7px]">
                {payments?.length > 0 && payments.map((p, idx) => (
                    <div key={idx} className="flex justify-between italic">
                        <span>{p.method}</span>
                        <span>${p.amount.toFixed(2)}</span>
                    </div>
                ))}
            </div>
 
            {/* Auditoría de Responsables - Ultra Slim */}
            <div className="mt-1 pt-0.5 border-t border-dotted border-black text-[6.5px] uppercase font-bold">
                <div className="flex justify-between">
                    <span>CAP/COB:</span>
                    <span className="truncate ml-1">
                        {ticket?.captured_by?.name?.split(' ')[0] || 'SIS'} / {ticket?.cashed_by?.name?.split(' ')[0] || 'ADM'}
                    </span>
                </div>
            </div>
 
            <div className="text-center text-[7px] italic mt-1 border-t pt-0.5">
                *** Disfrute su pan ***
            </div>
        </div>
    );
});
