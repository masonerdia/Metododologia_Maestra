# Principio · Auditar por módulo, por vista Y por flujo

**Regla:** la auditoría cubre tres niveles. **Módulo** (la lógica de un dominio), **vista** (cada pantalla, mobile y desktop), y **flujo** (el recorrido del usuario *entre* vistas). Los tres, no solo los dos primeros.

**Por qué:** una pantalla puede estar perfecta y aun así el usuario no poder *llegar* a ella, o quedar atrapado. El hueco clásico se escapa cuando solo se audita vista por vista: cada vista pasa, pero el camino entre ellas no existe o es absurdo.

**Cómo aplicarlo:** además de [[auditoria-por-modulo]] y [[auditoria-por-vista]], correr [[auditoria-por-flujo]]: "¿puede el usuario llegar a esto en un clic? ¿puede salir? ¿el camino tiene sentido?".

Relacionado: [[GUARDIAN-UX]], [[mobile-y-desktop-siempre]].
