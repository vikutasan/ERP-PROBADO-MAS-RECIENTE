# MANUAL MAESTRO PARA IAs: LÓGICA DE TERMINALES, SESIONES Y CAJAS

> **¡ATENCIÓN A CUALQUIER IA O DESARROLLADOR!**
> Lee este documento **COMPLETO** antes de proponer, modificar o analizar cualquier código relacionado con el Punto de Venta (POS), selección de terminales, candados (locks), cuentas, o sesiones de caja. Cualquier modificación que rompa las reglas descritas aquí es considerada una **falla crítica de arquitectura**.

---

## 1. LA REGLA DE ORO: CANDADOS PERSISTENTES

**NUNCA** utilices la memoria RAM (diccionarios Python, variables globales, cachés locales) para guardar el estado de "quién está usando qué terminal".
* **Motivo:** Los contenedores Docker (o los servidores uvicorn) se reinician. Si el candado estaba en RAM, se pierde, causando que el usuario sea expulsado en medio de su captura de cobro.
* **Solución Obligatoria:** Todo candado debe vivir en la base de datos PostgreSQL, específicamente en la tabla `terminal_locks`. El backend simplemente consulta la BD.

---

## 2. REGLA DE EXPULSIÓN Y EL ANTI-PATRÓN "PING-PONG"

### Anti-Patrón 1: Robo Involuntario de Candados (Ping-Pong)
* **Historia del Error:** El frontend detectaba que había perdido su candado (por inactividad o porque el usuario inició sesión en otra terminal) y automáticamente intentaba re-adquirirlo llamando a `POST /lock` sin intervención del usuario. Como el backend respeta la regla "1 usuario = 1 terminal activa", borraba el candado de la terminal legítima y se lo daba a la vieja terminal. Inmediatamente la terminal legítima notaba que perdió su candado y hacía lo mismo, creando un ciclo infinito donde el estatus saltaba de una a otra cada pocos segundos.
* **Regla Estricta:** El Frontend **NUNCA DEBE INTENTAR RE-ADQUIRIR** un candado perdido automáticamente en su bloque de `catch` o en sus rutinas de *polling* (como `checkMyLock`). Si el candado se perdió, se debe mostrar una **advertencia visual** en la UI, pero el frontend debe "aceptar la derrota" y no volver a enviar peticiones de candado hasta que el usuario recargue o tome una acción explícita.

### Anti-Patrón 2: Expulsión por Fallos de Red
* **Regla Estricta:** **PROHIBIDO** que el frontend expulse al usuario de su pantalla de trabajo (redirigiendo al inicio) basándose en *timeouts* de red o *polls* fallidos. 
* La **única** forma en que un usuario es forzado a salir de la terminal sin su consentimiento directo es si un Administrador utiliza explícitamente el endpoint `POST /force_unlock`, en cuyo caso el backend asigna la terminal a otra persona, y el *polling* muestra un Modal Informativo de Expulsión justificada.

---

## 3. LÓGICA Y ESTADOS DE TERMINAL (MATRIZ DE INTERACCIÓN)

La UI ("Selecciona Tu Terminal") debe comportarse estrictamente de acuerdo al estado del usuario y la terminal:

### A) Estado de Habilitación / Deshabilitación
1. **Deshabilitada:** La terminal no puede ser seleccionada.
2. **Desocupada o Disponible:** Nadie tiene el candado; lista para usarse.
3. **Ocupada:** Alguien tiene el candado (aparecerá con candado cerrado y el nombre del usuario).

### B) Interacción del Usuario
* **Logueado sin terminal:** Ve las desocupadas disponibles y las ocupadas con candado rojo.
* **Logueado con terminal ocupada (en uso):** Si está usando la T1, no debe poder usar otra terminal sin soltar la T1.
* **Sale de la terminal (Cierra Pestaña o Unlock) pero con Caja Abierta:** La terminal se libera de su candado, pero como tiene `CashSession` activa, muestra "CAJA ABIERTA" sin operador presente.
* **Saca Corte de Caja:** La terminal pierde el estatus de "Caja", y vuelve a ser una terminal regular.
* **Es Administrador:** Tiene el "Poder" de ver un botón especial de **FORZAR DESBLOQUEO** en terminales bloqueadas.

---

## 4. DESBLOQUEO FORZADO Y TRASPUESTA DE TITULARIDAD DE CAJA

Cuando se utiliza un **Force Unlock** (Desbloqueo Forzado) en una terminal que tiene una `CashSession` abierta (está fungiendo como Caja):

* **Privilegios:** Si el usuario no tiene permisos en el Gestor de Perfiles, se le rechaza con error de permisos y la caja sigue intacta.
* **Traspuesta (El Cambio de Dueño):** Si el Administrador fuerza el desbloqueo, la terminal se le asigna a él. Pero **ADICIONALMENTE**, el backend altera la sesión de caja activa (`CashSession`) y **le cambia el `employee_id` y `employee_name` al del Administrador**.
* **Motivo:** El Cajero original se fue. El Gerente necesita tomar la caja para imprimir el Corte de Caja bajo su propio PIN y contabilidad. El cajero original pierde definitivamente esa caja. **NUNCA DEBE DEJARSE LA CAJA A NOMBRE DEL EMPLEADO AUSENTE SI SE FORZÓ SU DESBLOQUEO**.

---

## 5. GENERACIÓN DE FOLIOS (CUENTAS) Y EL PIZARRÓN

### Reglas de Folios
1. **Folios 100% en Backend:** El Frontend tiene **PROHIBIDO** inventar folios, ni temporales (`TEMP_123`) ni aleatorios (`Math.random()`). El único folio válido es `V{id_incremental_db}`.
2. **Lazy Reservation:** Un ticket vacío no tiene folio. Cuando el usuario agrega el **primer producto**, el frontend pide un `POST /tickets/reserve` y el backend recicla un ticket vacío o le asigna uno secuencial, garantizando no saltarse números.

### Reglas del Pizarrón (Corkboard)
1. **Solo Total > 0:** Cuentas con total $0.00 NO aparecen en el pizarrón.
2. **Visión Global:** Todas las terminales ven todas las cuentas abiertas de las demás terminales.
3. **Persistencia del Creador:** Si la terminal T4 abre la cuenta de Juan, pero luego la terminal T5 (con Ana) la recupera para cobrarla, el `captured_by_id` debe seguir diciendo "Juan" (creador original).
4. **Desaparición:** Un ticket solo sale del pizarrón si se COBRA (cambia a PAÍD), se CANCELA, o se vacía su carrito. No pueden "desaparecer" silenciosamente por timeouts de interfaz.
