# REPORTE DE INCIDENCIA Y SOLUCIÓN: Falsos Positivos de "Conflicto de Versión" en Hora Pico

**Fecha de resolución:** 23 de Abril de 2026  
**Versión de Arquitectura POS:** v4.4 (Hardened)

Este documento explica técnica y conceptualmente el problema reportado donde los cajeros recibían el modal de **"Conflicto de Versión" (HTTP 409)** bloqueando sus pantallas durante horas de alto tráfico (Hora Pico), a pesar de que nadie más estaba intentando modificar sus cuentas.

---

## 1. El Síntoma Reportado por el Usuario
Durante los momentos de mayor afluencia de clientes en la panadería, los cajeros que trabajaban de manera aislada y exclusiva en sus propias cuentas (sin meterse en el Pizarrón de otros) experimentaban repentinamente una pantalla de bloqueo amarilla que decía: *"Otro usuario modificó esta cuenta mientras usted trabajaba"*. 

La intuición del usuario fue correcta: el sistema estaba **"peleando consigo mismo"** por la cuenta, no con un agente externo.

## 2. El Diagnóstico Técnico (El "Por Qué")
El sistema POS utiliza un mecanismo avanzado de **Bloqueo Optimista** (Optimistic Locking) que depende de un campo numérico llamado `version`. Cada vez que el servidor guarda un ticket, aumenta este número (Ej. de 5 a 6). El frontend debe enviar siempre la última versión que conoce para que el servidor le permita guardar.

### La Anatomía del Falso Positivo (La Trampa de la Red Lenta):
1. **Intento de Guardado:** El cajero presiona "Pagar" (o el sistema hace auto-save). El frontend envía los datos con la versión `5`.
2. **Éxito Silencioso:** El backend recibe los datos, los guarda perfectamente en PostgreSQL, y aumenta la versión en la base de datos a `6`. El backend responde "Todo bien, aquí tienes la versión 6".
3. **El Fallo de Red (Hora Pico):** Debido a la inestabilidad del Wi-Fi por la cantidad de gente, el "paquete" de respuesta del servidor se pierde en el aire o tarda demasiado.
4. **Desincronización:** El frontend (la tablet) sufre un *timeout* (tiempo de espera agotado). Como nunca recibió la respuesta, se queda pensando que la cuenta **sigue en la versión `5`**.
5. **El Reintento Fatal:** Quince segundos después, el frontend vuelve a intentar guardar, enviando nuevamente la versión `5`.
6. **El Falso Positivo:** El backend lee su base de datos y dice: *"Espera, mi versión es la 6 y tú me envías la 5. ¡Alguien más modificó esto! ¡Alerta 409!"* y lanza el modal amarillo. 

**En resumen:** La terminal de caja estaba sobre-escribiendo su propia información, pero el sistema de seguridad lo interpretaba como un ataque de concurrencia.

---

## 3. La Solución Implementada
Para erradicar estos bloqueos falsos sin sacrificar la seguridad real del sistema, se implementaron dos soluciones complementarias en la **Versión 4.4**.

### A. Bypass Idempotente de Red (Backend)
Se añadió una regla de inteligencia artificial contextual en el motor de validación (`_upsert_ticket_header` en `service.py`).
* Cuando el backend detecta una diferencia de versión (409 inminente), antes de explotar, verifica **quién** le está enviando los datos (`req_terminal_id`).
* Compara ese identificador con el dueño actual de la cuenta (`db_ticket.terminal_id`).
* **Si ambos coinciden (Ej. Terminal 4 editando la cuenta de Terminal 4), el backend deduce que es un reintento a causa de un timeout de red.** En lugar de lanzar un error, "perdona" el conflicto, acepta la actualización de forma segura (porque la terminal es dueña absoluta de sus datos) y le devuelve la versión actualizada al frontend para que se re-sincronice.

### B. Sincronización Inicial del Ticket Reciclado (Frontend)
Existía un bug secundario donde, si el backend le asignaba al cajero una cuenta "vacía y abandonada" (reciclaje de folios para evitar saltos), el frontend olvidaba preguntarle qué número de `version` tenía ese ticket viejo.
* Se modificó `generateNewAccountNum` en `RetailVisionPOS.jsx` para que desde el milisegundo 1, la terminal absorba la versión correcta del ticket (`ticket.version || 1`). 
* Esto evita que el primer *auto-save* viaje "ciego" (con version null) y rompa la cadena de seguridad desde el principio.

## 4. Archivos Modificados
Los cambios fueron puntuales y precisos para evitar regresiones en otras áreas:
1. `apps/pos/RetailVisionPOS.jsx` (Lógica de sincronización inicial en reserva de ticket).
2. `apps/api/modules/pos/service.py` (Lógica de bypass en `_upsert_ticket_header` y transposición de dueño en `_update_ticket_fields`).

## 5. Resultado Esperado
* El sistema es ahora tolerante a caídas de red, micro-desconexiones y *timeouts*.
* Los cajeros no verán el modal amarillo a menos que **genuinamente** dos terminales distintas estén modificando la misma cuenta al mismo tiempo (Ej. Terminal 4 y Terminal 5 abren el mismo folio del Pizarrón a la vez).
* La velocidad de captura en hora pico será fluida e ininterrumpida.
