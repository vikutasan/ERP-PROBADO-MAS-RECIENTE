import { CONFIG } from '../config';

class POSService {
    async getCategories() {
        const res = await fetch(`${CONFIG.API_BASE_URL}/catalog/categories`);
        if (!res.ok) throw new Error("Error cargando categorías");
        return res.json();
    }

    async getProducts() {
        const res = await fetch(`${CONFIG.API_BASE_URL}/catalog/products`);
        if (!res.ok) throw new Error("Error cargando productos");
        return res.json();
    }

    async getActiveSession(terminalId) {
        const res = await fetch(`${CONFIG.API_BASE_URL}/pos/sessions/${terminalId}/active`);
        if (res.ok) return res.json();
        return null;
    }

    async createSession(terminalId) {
        const res = await fetch(`${CONFIG.API_BASE_URL}/pos/sessions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ terminal_id: terminalId })
        });
        if (!res.ok) throw new Error("Error creando sesión");
        return res.json();
    }

    async createTicket(ticketData) {
        const res = await fetch(`${CONFIG.API_BASE_URL}/pos/tickets`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(ticketData)
        });
        if (!res.ok) {
            const error = await res.json();
            throw new Error(error.detail || "Error registrando ticket");
        }
        return res.json();
    }

    async reserveTicket(terminalId) {
        const res = await fetch(`${CONFIG.API_BASE_URL}/pos/tickets/reserve`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ terminal_id: terminalId })
        });
        if (!res.ok) throw new Error("Error reservando ticket. Verifique conexión ERP.");
        return res.json();
    }

    async getOpenTickets() {
        const res = await fetch(`${CONFIG.API_BASE_URL}/pos/tickets/open`);
        if (!res.ok) throw new Error("Error cargando pizarron");
        return res.json();
    }
}

export const posService = new POSService();
