import React, { useState } from 'react';
import { CONFIG } from '../config';

/**
 * ProductCard — Tarjeta individual de producto en el catálogo.
 * Cascada de imágenes: API → SKU.png → SKU.jpg → Legacy PNG → Legacy JPG → Emoji fallback.
 */
export const ProductCard = ({ product, onAdd }) => {
    const [imgStatus, setImgStatus] = useState(product.hasRealImage ? 'API_IMG' : 'TRY_PNG');
    const baseStaticUrl = CONFIG.API_BASE_URL.replace('/api/v1', '/static/catalog');
    const skuPngUrl = `${baseStaticUrl}/${product.sku}.png`;
    const skuJpgUrl = `${baseStaticUrl}/${product.sku}.jpg`;
    const legacyPng = `${baseStaticUrl}/Img1118_${product.sku}.png`;
    const legacyJpg = `${baseStaticUrl}/Img1118_${product.sku}.jpg`;

    const imgClass = "max-w-full max-h-full object-contain drop-shadow-2xl mix-blend-normal";

    const IMG_CHAIN = [
        { key: 'API_IMG',    src: product.image, next: 'TRY_PNG' },
        { key: 'TRY_PNG',    src: skuPngUrl,     next: 'TRY_JPG' },
        { key: 'TRY_JPG',    src: skuJpgUrl,     next: 'LEGACY_PNG' },
        { key: 'LEGACY_PNG', src: legacyPng,     next: 'LEGACY_JPG' },
        { key: 'LEGACY_JPG', src: legacyJpg,     next: 'FALLBACK' },
    ];

    const activeImg = IMG_CHAIN.find(i => i.key === imgStatus);

    return (
        <button onClick={() => onAdd(product)} className="group relative bg-black hover:bg-[#c1d72e] p-3 rounded-[35px] border border-white/10 transition-all duration-500 flex flex-col items-center justify-between gap-2 hover:scale-105 active:scale-95 shadow-[0_4px_20px_rgba(0,0,0,0.6)] hover:shadow-[#c1d72e]/20 h-full w-full">
            <div className="w-full h-20 2xl:h-24 flex items-center justify-center mt-1">
                {activeImg ? (
                    <img
                        src={activeImg.src}
                        alt={product.name}
                        className={imgClass}
                        onError={() => setImgStatus(activeImg.next)}
                    />
                ) : (
                    <div className="text-6xl group-hover:scale-110 transition-transform">{product.emoji}</div>
                )}
            </div>

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
