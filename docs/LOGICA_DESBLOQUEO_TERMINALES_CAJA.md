# LÓGICA DE DESBLOQUEO DE TERMINALES HABILITADAS COMO CAJA ESPERADA POR EL USUARIO

Este documento establece las reglas de negocio estrictas esperadas por el usuario respecto al desbloqueo de emergencia de terminales que, además de estar ocupadas, tienen una **Sesión de Caja Activa** (Cash Session). Estas reglas deben ser acatadas por cualquier IA que modifique los módulos de control de sesión de caja y desbloqueo de terminales.

---

### Situación Base
El cajero con la sesión de caja habilitada por algún motivo no está y es necesario desbloquear su caja para poder:
- Seguir cobrando.
- Que no se pierda esa información (ventas acumuladas en esa sesión).
- Sacar el corte de caja.

En estos casos de emergencia, un segundo usuario intenta forzar el desbloqueo de la terminal.

### Matriz de Comportamiento Esperado

| Estatus / Privilegios del Nuevo Usuario | Resultado Inmediato | Acciones que ocurren a Nivel Sistema (Backend) |
| :--- | :--- | :--- |
| **Tiene habilitado el permiso** de *Desbloqueo de Terminales* en el Gestor de Perfiles. | Tras aceptar el modal de advertencia, **desbloquea exitosamente** la terminal habilitada como caja. | 1. La terminal se desbloquea temporalmente del usuario anterior.<br>2. **EL USUARIO QUE DESBLOQUEÓ PASA A SER EL TITULAR DE LA SESIÓN DE CAJA** que ha desbloqueado.<br>3. El usuario original **pierde** la titularidad de su sesión de caja de manera definitiva. |
| **NO tiene habilitado el permiso** de *Desbloqueo de Terminales* en el Gestor de Perfiles. | **Se le impide** desbloquear la terminal y le aparece un Modal de falta de permisos. | 1. La terminal habilitada como caja **continúa bloqueada**.<br>2. El cajero original mantiene intacta su sesión de caja. |

### Regla de Oro a Programadores / IAs
> **TRASPUESTA DE TITULARIDAD DE CAJA:** Cuando se fuerza el cierre de la sesión (Force Unlock) sobre una terminar que está operando como punto de cobro (Caja), **no solo se reasigna el Lock de la terminal, sino que la `CashSession` activa ligada a esa caja debe cambiar de `user_id` / `employee_code` al nuevo usuario que ejecutó el desbloqueo**.
> Esto es para que el nuevo gerente o supervisor pueda emitir el Corte de Caja bajo su propio PIN y no quede flotando a nombre del empleado ausente.

*(Información extraída del PDF: LÓGICA DE DESBLOQUEO DE TERMINALES HABILITADAS COMO CAJA ESPERADA POR EL USUARIO)*
