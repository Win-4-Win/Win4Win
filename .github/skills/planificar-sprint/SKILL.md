---
name: planificar-sprint
description: "Use when se planifica un sprint, se crean épicas, historias de usuario, backlog, criterios de aceptación, definición de hecho, retrospectiva o revisión de sprint del proyecto (equipo de 3, Agile)."
---

# Planificación Agile

Contexto: equipo de 3 personas, sprints sin duración fijada todavía, 3 fases (instalar → automatizar → elegir en la web). Consulta AGENTS.md y docs/DECISIONES.md.

## Pasos
1. Pregunta al usuario objetivo, duración y capacidad del sprint si no están definidos.
2. Propón un **objetivo de sprint** claro y 3–8 historias: "Como <rol>, quiero <acción> para <beneficio>".
3. Cada historia lleva criterios de aceptación comprobables, estimación (puntos o tallas S/M/L) y responsable si se conoce.
4. Definición de hecho: código en PR revisado, probado en VM Windows 11, documentación actualizada.
5. Guarda el plan en `docs/sprints/sprint-XX.md` (créalo si no existe) y enlaza desde el histórico.
6. Al cerrar el sprint, añade revisión (qué se hizo), retrospectiva (qué mejorar) y registra el hito con la skill `registrar-hito`.
