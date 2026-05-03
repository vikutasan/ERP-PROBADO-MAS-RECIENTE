import React, { useState, useEffect, useRef } from 'react';

/**
 * Módulo: Monitoreo de Red
 * Dashboard de salud de red para el ERP R de Rico.
 * Muestra el estado de todas las terminales, latencia en tiempo real,
 * y un historial de eventos de desconexión de las últimas 24 horas.
 */

const API_BASE = (() => {
    const host = window.location.hostname;
    const port = '5001';
    return `http://${host}:${port}/api/v1`;
})();

const TERMINALS = ['T6', 'T5', 'T4', 'T3', 'T2', 'CAJA'];

const STATUS_CONFIG = {
    online:  { color: '#4ade80', bg: 'rgba(74,222,128,0.08)', border: 'rgba(74,222,128,0.25)', label: 'EN LÍNEA',    icon: '●' },
    slow:    { color: '#facc15', bg: 'rgba(250,204,21,0.08)',  border: 'rgba(250,204,21,0.25)',  label: 'RED LENTA',   icon: '◐' },
    offline: { color: '#ef4444', bg: 'rgba(239,68,68,0.08)',   border: 'rgba(239,68,68,0.25)',   label: 'SIN CONEXIÓN',icon: '○' },
    idle:    { color: '#555',    bg: 'rgba(85,85,85,0.08)',     border: 'rgba(85,85,85,0.25)',    label: 'INACTIVA',    icon: '○' },
};

export const NetworkMonitorUI = () => {
    const [serverLatency, setServerLatency] = useState(null);
    const [serverStatus, setServerStatus] = useState('offline');
    const [terminalData, setTerminalData] = useState({});
    const [eventLog, setEventLog] = useState([]);
    const [uptimeStart, setUptimeStart] = useState(null);
    const prevStatusRef = useRef({});

    // Ping al servidor API
    useEffect(() => {
        const pingServer = async () => {
            const start = performance.now();
            try {
                const res = await fetch(`${API_BASE}/settings`, {
                    cache: 'no-store',
                    signal: AbortSignal.timeout(5000)
                });
                const elapsed = Math.round(performance.now() - start);
                setServerLatency(elapsed);
                setServerStatus(elapsed > 500 ? 'slow' : res.ok ? 'online' : 'offline');
                if (!uptimeStart) setUptimeStart(new Date());
            } catch (e) {
                setServerLatency(-1);
                setServerStatus('offline');
            }
        };
        pingServer();
        const id = setInterval(pingServer, 10000);
        return () => clearInterval(id);
    }, [uptimeStart]);

    // Estado de terminales
    useEffect(() => {
        const fetchTerminals = async () => {
            try {
                const res = await fetch(`${API_BASE}/pos/terminals/status`, { cache: 'no-store' });
                if (!res.ok) return;
                const data = await res.json();
                const now = new Date();

                const newData = {};
                TERMINALS.forEach(tid => {
                    const info = data[tid];
                    const isOccupied = info && info.occupier_id;
                    newData[tid] = {
                        status: isOccupied ? 'online' : 'idle',
                        occupier: isOccupied ? info.occupier_name : null,
                        lockedAt: info?.locked_at || null,
                        hasCash: info?.has_cash_session || false,
                    };

                    // Detectar cambios de estado para el log
                    const prevStatus = prevStatusRef.current[tid]?.status;
                    if (prevStatus === 'online' && !isOccupied) {
                        setEventLog(prev => [{
                            time: now.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
                            terminal: tid,
                            type: 'disconnect',
                            message: `${prevStatusRef.current[tid]?.occupier || 'Usuario'} se desconectó`,
                        }, ...prev].slice(0, 50));
                    } else if (prevStatus !== 'online' && isOccupied) {
                        setEventLog(prev => [{
                            time: now.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
                            terminal: tid,
                            type: 'connect',
                            message: `${info.occupier_name} se conectó`,
                        }, ...prev].slice(0, 50));
                    }
                });

                prevStatusRef.current = newData;
                setTerminalData(newData);
            } catch (e) { /* Network error — ignorar silenciosamente */ }
        };
        fetchTerminals();
        const id = setInterval(fetchTerminals, 5000);
        return () => clearInterval(id);
    }, []);

    const activeCount = Object.values(terminalData).filter(t => t.status === 'online').length;
    const srvCfg = STATUS_CONFIG[serverStatus];

    const formatUptime = () => {
        if (!uptimeStart) return '--:--:--';
        const diff = Math.floor((Date.now() - uptimeStart.getTime()) / 1000);
        const h = String(Math.floor(diff / 3600)).padStart(2, '0');
        const m = String(Math.floor((diff % 3600) / 60)).padStart(2, '0');
        const s = String(diff % 60).padStart(2, '0');
        return `${h}:${m}:${s}`;
    };

    const [, forceUpdate] = useState(0);
    useEffect(() => {
        const id = setInterval(() => forceUpdate(c => c + 1), 1000);
        return () => clearInterval(id);
    }, []);

    return (
        <div className="h-full overflow-y-auto custom-scrollbar" style={{ background: 'linear-gradient(135deg, #050505 0%, #0a0f1a 100%)' }}>
            <div className="max-w-7xl mx-auto p-10 space-y-8">

                {/* Header */}
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-4xl font-black uppercase tracking-tight text-white">
                            Monitoreo de Red
                        </h1>
                        <p className="text-sm text-gray-500 font-medium mt-1">
                            Estado en tiempo real de la infraestructura LAN
                        </p>
                    </div>
                    <div className="text-right">
                        <p className="text-[10px] text-gray-600 font-bold uppercase tracking-widest">Última actualización</p>
                        <p className="text-lg font-black text-white tabular-nums">
                            {new Date().toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                        </p>
                    </div>
                </div>

                {/* KPIs Row */}
                <div className="grid grid-cols-4 gap-4">
                    {/* Server Status */}
                    <div className="rounded-2xl p-6 border" style={{ background: srvCfg.bg, borderColor: srvCfg.border }}>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-gray-500 mb-2">Servidor API</p>
                        <div className="flex items-center gap-3">
                            <span className="text-3xl" style={{ color: srvCfg.color }}>{srvCfg.icon}</span>
                            <div>
                                <p className="text-lg font-black uppercase" style={{ color: srvCfg.color }}>{srvCfg.label}</p>
                                <p className="text-[10px] text-gray-500 font-bold tabular-nums">
                                    {serverLatency > 0 ? `${serverLatency}ms` : 'Sin respuesta'}
                                </p>
                            </div>
                        </div>
                    </div>

                    {/* Active Terminals */}
                    <div className="rounded-2xl p-6 border" style={{ background: 'rgba(74,222,128,0.05)', borderColor: 'rgba(74,222,128,0.15)' }}>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-gray-500 mb-2">Terminales Activas</p>
                        <p className="text-4xl font-black text-green-400 tabular-nums">{activeCount}<span className="text-lg text-gray-600">/6</span></p>
                    </div>

                    {/* Latency */}
                    <div className="rounded-2xl p-6 border" style={{ background: 'rgba(99,102,241,0.05)', borderColor: 'rgba(99,102,241,0.15)' }}>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-gray-500 mb-2">Latencia Servidor</p>
                        <p className={`text-4xl font-black tabular-nums ${serverLatency > 500 ? 'text-yellow-400' : serverLatency > 0 ? 'text-indigo-400' : 'text-red-400'}`}>
                            {serverLatency > 0 ? `${serverLatency}` : '--'}<span className="text-lg text-gray-600">ms</span>
                        </p>
                    </div>

                    {/* Uptime */}
                    <div className="rounded-2xl p-6 border" style={{ background: 'rgba(249,115,22,0.05)', borderColor: 'rgba(249,115,22,0.15)' }}>
                        <p className="text-[9px] font-bold uppercase tracking-widest text-gray-500 mb-2">Sesión de Monitoreo</p>
                        <p className="text-4xl font-black text-orange-400 tabular-nums">{formatUptime()}</p>
                    </div>
                </div>

                {/* Terminals Grid */}
                <div>
                    <h2 className="text-sm font-black uppercase tracking-widest text-gray-500 mb-4">Estado por Terminal</h2>
                    <div className="grid grid-cols-6 gap-3">
                        {TERMINALS.map(tid => {
                            const t = terminalData[tid] || { status: 'idle' };
                            const cfg = STATUS_CONFIG[t.status];
                            return (
                                <div
                                    key={tid}
                                    className="rounded-2xl p-5 border transition-all duration-500"
                                    style={{ background: cfg.bg, borderColor: cfg.border }}
                                >
                                    <div className="flex items-center justify-between mb-3">
                                        <span className="text-[10px] font-black uppercase tracking-widest text-gray-400">
                                            {tid === 'CAJA' ? 'Caja' : tid}
                                        </span>
                                        <span
                                            className={`w-3 h-3 rounded-full ${t.status === 'online' ? 'animate-pulse' : ''}`}
                                            style={{ backgroundColor: cfg.color }}
                                        />
                                    </div>
                                    <p className="text-[10px] font-bold uppercase truncate" style={{ color: cfg.color }}>
                                        {cfg.label}
                                    </p>
                                    {t.occupier && (
                                        <p className="text-[9px] text-gray-400 font-bold mt-1 truncate" title={t.occupier}>
                                            👤 {t.occupier}
                                        </p>
                                    )}
                                    {t.hasCash && (
                                        <p className="text-[9px] text-green-400 font-bold mt-0.5">💰 Caja Activa</p>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* Event Log */}
                <div>
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="text-sm font-black uppercase tracking-widest text-gray-500">
                            Eventos de Sesión
                        </h2>
                        {eventLog.length > 0 && (
                            <button
                                onClick={() => setEventLog([])}
                                className="text-[9px] font-bold uppercase tracking-widest text-gray-600 hover:text-red-400 transition-colors"
                            >
                                Limpiar
                            </button>
                        )}
                    </div>

                    <div className="rounded-2xl border border-gray-800/60 overflow-hidden" style={{ background: 'rgba(0,0,0,0.3)' }}>
                        {eventLog.length === 0 ? (
                            <div className="p-10 text-center">
                                <p className="text-gray-600 text-sm font-bold">Sin eventos registrados</p>
                                <p className="text-gray-700 text-xs mt-1">Las conexiones y desconexiones aparecerán aquí</p>
                            </div>
                        ) : (
                            <div className="max-h-[300px] overflow-y-auto custom-scrollbar">
                                {eventLog.map((evt, i) => (
                                    <div
                                        key={i}
                                        className="flex items-center gap-4 px-5 py-3 border-b border-gray-800/40 hover:bg-white/[0.02] transition-colors"
                                    >
                                        <span className="text-[10px] font-bold text-gray-600 tabular-nums w-20 shrink-0">
                                            {evt.time}
                                        </span>
                                        <span className={`text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-md w-10 text-center shrink-0 ${
                                            evt.type === 'disconnect'
                                                ? 'bg-red-500/10 text-red-400'
                                                : 'bg-green-500/10 text-green-400'
                                        }`}>
                                            {evt.terminal}
                                        </span>
                                        <span className={`text-xs font-bold ${
                                            evt.type === 'disconnect' ? 'text-red-400' : 'text-green-400'
                                        }`}>
                                            {evt.type === 'disconnect' ? '⬇' : '⬆'}
                                        </span>
                                        <span className="text-xs text-gray-400">
                                            {evt.message}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>

                {/* Network Tips */}
                <div className="rounded-2xl p-6 border border-orange-500/10" style={{ background: 'rgba(249,115,22,0.03)' }}>
                    <h3 className="text-[10px] font-black uppercase tracking-widest text-orange-400 mb-3">💡 Diagnóstico Rápido</h3>
                    <div className="grid grid-cols-3 gap-4 text-[10px] text-gray-400">
                        <div>
                            <p className="font-bold text-gray-300 mb-1">Latencia Normal (LAN)</p>
                            <p>&lt; 10ms — Si es mayor, revisa cables y switch.</p>
                        </div>
                        <div>
                            <p className="font-bold text-gray-300 mb-1">Desconexiones Frecuentes</p>
                            <p>Revisa conectores RJ-45 y UPS del switch.</p>
                        </div>
                        <div>
                            <p className="font-bold text-gray-300 mb-1">Servidor Sin Respuesta</p>
                            <p>Verificar que Docker Desktop esté corriendo.</p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    );
};
