import React from 'react';
import { ProductCard } from './ProductCard';
import { CONFIG } from '../config';

/**
 * ProductGrid — Grid paginado de productos filtrados por categoría.
 * Ordena por posición y luego por nombre. Muestra placeholders para celdas vacías.
 */
export const ProductGrid = ({ products, category, currentPage, setCurrentPage, onAddToCart }) => {
    const filtered = products
        .filter(p => {
            const pCat = p.category ? (typeof p.category === 'string' ? p.category : p.category.name) : 'OTROS';
            return pCat === category;
        })
        .sort((a, b) => {
            const posA = a.position ?? 9999;
            const posB = b.position ?? 9999;
            if (posA !== posB) return posA - posB;
            return a.name.localeCompare(b.name);
        });

    const totalPages = Math.ceil(filtered.length / CONFIG.ITEMS_PER_PAGE);
    const paginated = filtered.slice((currentPage - 1) * CONFIG.ITEMS_PER_PAGE, currentPage * CONFIG.ITEMS_PER_PAGE);

    return (
        <div className="flex-1 flex gap-4 overflow-hidden">
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
            <div className="flex-1 overflow-hidden">
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 grid-rows-3 gap-4 h-full">
                    {paginated.map(p => <ProductCard key={p.id} product={p} onAdd={onAddToCart} />)}
                    {paginated.length < CONFIG.ITEMS_PER_PAGE && Array.from({ length: CONFIG.ITEMS_PER_PAGE - paginated.length }).map((_, i) => (
                        <div key={`empty-${i}`} className="bg-black/5 rounded-[35px] border border-white/2"></div>
                    ))}
                </div>
            </div>
        </div>
    );
};
