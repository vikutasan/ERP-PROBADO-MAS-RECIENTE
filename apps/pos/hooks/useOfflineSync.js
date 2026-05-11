import { useState, useEffect, useRef, useCallback } from 'react';
import { dequeueNext, markSynced, markAttempt, getQueueSize, cleanupQueue } from '../services/cartPersistence';

/**
 * Hook: useOfflineSync
 * 
 * Sincroniza la cola de operaciones offline cuando la red regresa.
 * 
 * COMPORTAMIENTO:
 * 1. Monitorea netStatus (de useNetworkHealth)
 * 2. Cuando detecta transición down → good, inicia flush automático
 * 3. Procesa la cola FIFO: toma la primera entrada, la envía al servidor
 * 4. Si éxito: la marca como sincronizada, pasa a la siguiente
 * 5. Si falla: espera 10s y reintenta (máximo 3 intentos por entrada)
 * 6. Actualiza `pendingCount` para el badge visual en la UI
 * 
 * INTEGRACIÓN:
 * - NO modifica handleTicketAction ni el mutex
 * - Usa posService.createTicket directamente (bypass del wrapper resiliente)
 * - Actualiza ticketVersionRef cuando sincroniza el último save de un ticket
 * 
 * @param {string} netStatus - 'good' | 'slow' | 'down' (de useNetworkHealth)
 * @param {Function} createTicketFn - posService.createTicket (directo, sin wrapper)
 * @param {React.MutableRefObject} ticketVersionRef - Ref de versión optimista
 * @param {Function} setTicketVersion - setState de versión para UI
 */
export const useOfflineSync = ({
  netStatus,
  createTicketFn,
  ticketVersionRef,
  setTicketVersion,
  accountNumRef
}) => {
  const [pendingCount, setPendingCount] = useState(0);
  const [isSyncing, setIsSyncing] = useState(false);
  const prevStatusRef = useRef(netStatus);
  const syncIntervalRef = useRef(null);
  const isSyncingRef = useRef(false);

  // Actualizar el conteo de pendientes periódicamente
  const refreshCount = useCallback(() => {
    const count = getQueueSize();
    setPendingCount(count);
    return count;
  }, []);

  // Función principal de flush: procesa la cola FIFO
  const flushQueue = useCallback(async () => {
    if (isSyncingRef.current) return; // Evitar concurrencia
    isSyncingRef.current = true;
    setIsSyncing(true);

    console.log('🔄 [OfflineSync] Iniciando flush de cola offline...');

    let processed = 0;
    let failed = 0;
    const maxIterations = 50; // Safety valve
    let iterations = 0;

    while (iterations < maxIterations) {
      iterations++;
      const entry = dequeueNext();
      if (!entry) break; // Cola vacía

      try {
        console.log(`🔄 [OfflineSync] Sincronizando ${entry.id} (cuenta: ${entry.payload.account_num})...`);
        
        // Enviar al servidor con el payload original
        // NOTA: El servidor maneja conflictos de versión con su propia lógica
        const result = await createTicketFn(entry.payload);
        
        // Éxito — marcar como sincronizado
        markSynced(entry.id);
        processed++;

        // Si el ticket sincronizado es el que está activo en pantalla,
        // actualizar la versión para evitar 409 en el próximo auto-save
        if (result?.version && accountNumRef?.current === entry.payload.account_num) {
          ticketVersionRef.current = result.version;
          setTicketVersion(result.version);
          console.log(`📌 [OfflineSync] Versión actualizada para ${entry.payload.account_num}: v${result.version}`);
        }

      } catch (error) {
        failed++;
        markAttempt(entry.id, error.message || 'Unknown error');
        console.warn(`⚠️ [OfflineSync] Error sincronizando ${entry.id}:`, error.message);

        // Si el error es del servidor (no de red), no reintentar — el payload es inválido
        const isServerError = !(error instanceof TypeError) && !error.message?.includes('fetch');
        if (isServerError || entry.attempts >= 3) {
          console.error(`❌ [OfflineSync] Descartando ${entry.id} después de ${entry.attempts + 1} intentos`);
          markSynced(entry.id); // Marcar como procesado para no reintentar indefinidamente
        } else {
          // Error de red durante sync — parar y reintentar en el próximo ciclo
          break;
        }
      }
    }

    // Limpiar entradas ya procesadas
    cleanupQueue();
    const remaining = refreshCount();
    
    console.log(`✅ [OfflineSync] Flush completado: ${processed} sincronizados, ${failed} fallidos, ${remaining} pendientes`);

    isSyncingRef.current = false;
    setIsSyncing(false);
  }, [createTicketFn, ticketVersionRef, setTicketVersion, accountNumRef, refreshCount]);

  // Efecto: detectar transición de red y activar flush
  useEffect(() => {
    const prev = prevStatusRef.current;
    prevStatusRef.current = netStatus;

    // Transición: (down o slow) → good
    if ((prev === 'down' || prev === 'slow') && netStatus === 'good') {
      console.log('🌐 [OfflineSync] Red restaurada — iniciando flush...');
      // Delay pequeño para que la red se estabilice
      setTimeout(() => flushQueue(), 2000);
    }
  }, [netStatus, flushQueue]);

  // Efecto: verificar periódicamente si hay pendientes (cada 10s)
  // Esto cubre el caso donde la red nunca se "cayó" formalmente
  // pero un auto-save individual falló y encoló
  useEffect(() => {
    const intervalId = setInterval(() => {
      const count = refreshCount();
      // Si hay pendientes y la red está bien, intentar flush
      if (count > 0 && netStatus === 'good' && !isSyncingRef.current) {
        flushQueue();
      }
    }, 10000);

    syncIntervalRef.current = intervalId;
    return () => clearInterval(intervalId);
  }, [netStatus, refreshCount, flushQueue]);

  // Efecto: refresh inicial del conteo
  useEffect(() => {
    refreshCount();
  }, [refreshCount]);

  return {
    pendingCount,
    isSyncing,
    flushQueue // Expuesto por si se quiere trigger manual
  };
};
