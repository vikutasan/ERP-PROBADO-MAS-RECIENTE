const hostname = window.location.hostname;
const isIP = /^\d+\.\d+\.\d+\.\d+$/.test(hostname);
const isLocal = hostname === 'localhost' || isIP;

let apiUrl;
if (isLocal) {
    apiUrl = `http://${hostname}:5001/api/v1`;
} else {
    // Si entran por reparto.tudominio.com, el API está en api.tudominio.com
    const domainParts = hostname.split('.');
    domainParts[0] = 'api';
    const apiHostname = domainParts.join('.');
    apiUrl = `https://${apiHostname}/api/v1`;
}

export const CONFIG = {
    API_BASE_URL: apiUrl,
    ITEMS_PER_PAGE: 12,
    TASA_IVA_MEXICO: 0.16
};
