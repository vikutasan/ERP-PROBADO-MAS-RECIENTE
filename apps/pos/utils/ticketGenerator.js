export const generateTicketHTML = (ticketData) => {
    let dateObj = new Date();
    if (ticketData.created_at) {
        dateObj = new Date(String(ticketData.created_at).endsWith('Z') ? ticketData.created_at : ticketData.created_at + 'Z');
    }
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
                <td style="width: 28px;">${qty}x</td>
                <td style="max-width: 44mm;">
                    <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${name}</div>
                    <div style="color: #000;">$${price.toFixed(2)} c/u</div>
                </td>
                <td style="text-align: right; white-space: nowrap;">$${(price * qty).toFixed(2)}</td>
            </tr>
        `;
    });

    let paymentsHtml = '';
    payments.forEach(p => {
        if (p.method === 'EFECTIVO' && p.received != null) {
            const received = p.received || 0;
            const abonado = p.amount || 0;
            const cambio = p.cambio || 0;
            paymentsHtml += `
                <div style="margin-bottom: 2px;">
                    <div style="font-weight: bold;">${p.method}</div>
                    <div style="display: flex; justify-content: space-between; padding-left: 8px;">
                        <span>Recibido:</span>
                        <span>$${received.toFixed(2)}</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding-left: 8px;">
                        <span>Abonado:</span>
                        <span>$${abonado.toFixed(2)}</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding-left: 8px;">
                        <span>Cambio:</span>
                        <span>$${cambio.toFixed(2)}</span>
                    </div>
                </div>
            `;
        } else {
            paymentsHtml += `
                <div style="display: flex; justify-content: space-between;">
                    <span>${p.method}</span>
                    <span>$${(p.amount || 0).toFixed(2)}</span>
                </div>
            `;
        }
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
                    font-size: 8pt;
                    line-height: 1.15;
                    color: #000;
                    background: #fff;
                    font-weight: bold;
                }
                .line { border-top: 1px dashed #000; margin: 2px 0; }
                .row { display: flex; justify-content: space-between; align-items: center; }
                .col { display: flex; flex-direction: column; }
                .bold { font-weight: bold; }
                .upper { text-transform: uppercase; }
                .center { text-align: center; }
                .small { font-size: 7pt; }
                .xsmall { font-size: 6.5pt; }
                table { width: 100%; border-collapse: collapse; font-size: 8pt; font-weight: bold; }
                td { padding: 1px 0; vertical-align: top; }
                .audit { font-size: 7pt; text-transform: uppercase; margin-top: 3px; padding-top: 2px; border-top: 1px dashed #000; }
            </style>
        </head>
        <body>
            <!-- ENCABEZADO: logo grande con pixel rendering nativo + nombre -->
            <div style="display: flex; justify-content: center; align-items: center; gap: 6px; margin-top: 1px; margin-bottom: 2px;">
                <img src="/assets/logo.png" alt="Logo" style="width: 32px; height: 32px; object-fit: contain; image-rendering: pixelated; flex-shrink: 0;" />
                <div class="bold upper" style="font-size: 12pt; letter-spacing: 0.5px; line-height: 1;">R DE RICO</div>
            </div>

            <!-- Fecha, Hora y Número de cuenta al CENTRO  -->
            <div class="col bold center" style="margin-bottom: 2px; align-items: center;">
                <div>CTA: ${ticketData.account_num || '---'}</div>
                <div style="margin-top: 1px;">${printDate} ${printTime}</div>
            </div>

            <div class="line"></div>

            <table style="margin: 2px 0;">
                <tbody>${itemsHtml}</tbody>
            </table>

            <div class="line"></div>

            <div class="row bold" style="margin: 2px 0;">
                <span>TOTAL DE ARTICULOS:</span>
                <span>${totalQty}</span>
            </div>

            <div class="line"></div>

            <div class="row bold" style="font-size: 10pt; margin: 2px 0;">
                <span>TOTAL</span>
                <span>$${(ticketData.total || 0).toFixed(2)}</span>
            </div>

            <div style="margin: 3px 0;">
                ${paymentsHtml}
            </div>

            <!-- SECCIÓN OMS: Detalles del Pedido -->
            ${ticketData.order_type === 'PEDIDO' ? `
                <div style="margin-top: 4px; border: 1.5px solid #000; padding: 4px; position: relative;">
                    <div class="center bold upper" style="font-size: 9pt; margin-bottom: 4px; background: #000; color: #fff; padding: 2px 0;">
                        *** DATOS DEL PEDIDO ***
                    </div>
                    
                    <div class="row"><span class="small">CLIENTE:</span> <span class="upper">${ticketData.customer_name || '---'}</span></div>
                    <div class="row"><span class="small">TIPO:</span> <span class="upper">${ticketData.delivery_type === 'PICKUP' ? '🏪 RECOLECCIÓN (PICKUP)' : '🚗 ENTREGA A DOMICILIO'}</span></div>
                    
                    <div class="row" style="margin-top: 2px;">
                        <span class="small">ENTREGA:</span>
                        <span class="upper">${ticketData.committed_at ? 
                            new Date(ticketData.committed_at).toLocaleString('es-MX', { 
                                weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' 
                            }) : '---'}
                        </span>
                    </div>

                    <div class="row" style="margin-top: 2px;">
                        <span class="small">EMPAQUE:</span>
                        <span class="upper">${ticketData.packaging_type === 'PROPIO' ? '🛍️ TRAE SU EMPAQUE' : '📦 EMPAQUE PAGADO'}</span>
                    </div>

                    ${ticketData.delivery_address ? `
                        <div style="margin-top: 4px; padding-top: 2px; border-top: 1px dashed #000;">
                            <div class="small bold">DIRECCIÓN:</div>
                            <div class="xsmall upper" style="line-height: 1.2;">${ticketData.delivery_address}</div>
                        </div>
                    ` : ''}

                    <div class="center bold upper" style="margin-top: 6px; font-size: 8.5pt; border-top: 1.5px solid #000; pt: 3px;">
                        ${ticketData.delivery_type === 'PICKUP' ? 'PAGADO - PENDIENTE DE RECOLECCION' : 'PAGADO - PENDIENTE DE ENTREGA'}
                    </div>
                </div>
            ` : ''}

            <div class="audit">
                <div class="row bold"><span>CAPTURÓ:</span><span>${capturedBy}</span></div>
                <div class="row bold"><span>COBRÓ:</span><span>${cashedBy}</span></div>
                <div class="row xsmall"><span>Terminal:</span><span>${ticketData.terminal_id || 'T1'}</span></div>
            </div>

            <div class="center xsmall" style="margin-top: 4px; padding-top: 2px; border-top: 1px solid #ccc;">
                *** Disfrute su pan ***
            </div>
            <div class="center xsmall" style="margin-top: 4px; padding-top: 2px; font-weight: bold; line-height: 1.2;">
                cuenta con 3 dias a partir de la fecha de compra para realizar alguna aclaracion respecto a su cobro, gracias por su compra
            </div>
        </body>
        </html>
    `;
};
