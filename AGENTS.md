# AGENTS.md

Guía para agentes de IA y colaboradores. Léelo antes de actuar en este repositorio.

## 1. Proyecto

**Nombre:** Win4Win (ver [docs/NOMBRES.md](docs/NOMBRES.md)). Organización de GitHub: **Win-4-Win** (creada).
**Contexto:** Proyecto final del ciclo DAW. Fase actual: **diseño y planificación**.

**Objetivo:** web/app que permite configurar y automatizar instalaciones de Windows 11. El usuario descarga desde la web un script/ejecutable (`.ps1`, `.bat` o `.exe`; formato por decidir) que, con pocos clics, deja un PC completamente instalado y configurado.

**Importante:** la web **no genera** los scripts al vuelo. Los sirve desde una BBDD o un repositorio de ficheros con scripts ya planificados y versionados.

## 2. Alcance funcional (visión final)

1. **Sistema operativo:** opción de instalar Windows 11 o no.
2. **Buenas prácticas de instalación/actualización**, en este orden:
   1. Instalar y actualizar (`winget upgrade`) los programas seleccionados (modo silent o con configuración elegida).
   2. Configurar los programas (p. ej. extensiones y página de inicio del navegador).
   3. Personalizar el entorno: iconos de escritorio, barra de tareas, menú Inicio, etc.
   4. Optimizar: evitar que los programas se inicien con Windows (salvo antivirus y los necesarios), limpiar con las categorías del Liberador de espacio en disco de Windows y optimizar el disco (desfragmentar HDD / TRIM en SSD).
   - Drivers y Windows Update quedan fuera del alcance de los scripts: los gestiona Windows por sí mismo (ver histórico 2026-11-03).
3. **Catálogo de programas** con opciones de configuración por programa.

## 3. Fases del proyecto

| Fase | Descripción |
|------|-------------|
| 1 | El programa permite **instalar** (software y configuración básica). |
| 2 | **Automatizar** la instalación completa (pocos clics por PC). |
| 3 | La web permite **elegir** qué programas/ajustes incluir o excluir. |

Las fases se reparten en sprints; el contenido de cada sprint se decide en su planificación.

## 4. Metodología

- **Equipo de 3 personas**, trabajo tipo Agile por sprints. Se publicará en **producción real** (no solo demo); habrá memoria, documentación y defensa.
- **Agile/Scrum por sprints.** Aún sin fecha de lanzamiento ni duración de sprint definidas (registrar la decisión en el histórico cuando se tome).
- Toda decisión de diseño, hito o cambio relevante se documenta **en el momento**, para poder redactar la memoria final.

- **Git/GitHub:** trabajo con ramas y Pull Requests, con tests. Nunca commitear directamente a `main`.
- **Presupuesto limitado:** preferir soluciones gratuitas o de bajo coste.

## 5. Reglas de documentación (obligatorias para agentes)

- [docs/HISTORICO.md](docs/HISTORICO.md): bitácora cronológica de hitos, decisiones y cambios de alcance. **Añadir una entrada al terminar cualquier hito o decisión relevante.** Entradas nuevas arriba del todo (orden cronológico inverso), con fecha `AAAA-MM-DD`.
- [docs/DECISIONES.md](docs/DECISIONES.md): decisiones abiertas y cerradas (formato de script, stack, BBDD…). Al cerrar una, actualizar su estado y referenciarla en el histórico.
- [docs/NOMBRES.md](docs/NOMBRES.md): propuestas de nombre del proyecto.
- [docs/CATALOGO.md](docs/CATALOGO.md): programas del catálogo. [docs/SCRIPTS.md](docs/SCRIPTS.md): descripción y estado de los scripts; actualizar al cambiarlos.
- No subir datos personales ni binarios al repositorio (ver deuda técnica en SCRIPTS.md).
- No borrar historial; si algo cambia, añadir una nueva entrada que lo explique.
- Documentación en **español**.

## 6. Convenciones

- **Preguntar si hace falta:** ante dudas, requisitos ambiguos o decisiones que afecten al diseño, el agente debe preguntar al usuario antes de asumir.
- **Colaboración con IA:** este es un proyecto de FP desarrollado por estudiantes. Explica y propone soluciones con un nivel adecuado para el equipo, en español por defecto, de forma breve y clara; define los términos técnicos necesarios sin dar por hecho experiencia profesional. Antes de empezar a crear, pregunta si hay dudas o si detectas una mejora sencilla que pueda cambiar el alcance o el resultado; no interrumpas con preguntas cuando la petición ya sea clara y no haya una mejora relevante que decidir.
- **Skills del proyecto** (en `.github/skills/`): `registrar-hito`, `script-powershell-instalador`, `anadir-programa-catalogo`, `planificar-sprint`. Úsalas cuando apliquen.
- **Operaciones de Git:** antes de ejecutar cualquier operación que cambie el repositorio, el índice, el historial o el remoto, pide permiso explícito al usuario. Esto incluye `git add`, `commit`, `push`, `pull`, `merge`, `rebase`, cambiar de rama, `cherry-pick`, `stash` y operaciones equivalentes. Una petición de editar o implementar cambios no autoriza estas operaciones. Las consultas de solo lectura, como `status`, `diff` y `log`, sí están permitidas.

- Idioma: documentación y comentarios en español; identificadores de código en inglés.
- Para cambios en HTML, CSS o JavaScript, aplicar también las [buenas prácticas de front-end](.github/instructions/frontend.instructions.md), especialmente las de accesibilidad.
- Cambios pequeños y justificados; no introducir dependencias sin anotarlo en DECISIONES.
- Seguridad: los scripts ejecutan acciones con privilegios de administrador. Deben ser **idempotentes**, registrar logs, no contener secretos, descargar software solo de fuentes oficiales (preferir `winget`) y verificar integridad cuando sea posible.
- **Licencias:** el proyecto no incluye ni documenta activadores ni cracks. Solo software con licencia legítima, gratuito u open source.
- Los scripts del catálogo deben estar versionados y ser revisables antes de publicarse.

## 7. Estructura prevista

```
/
├─ AGENTS.md
├─ script/          (prototipo PowerShell, ver docs/SCRIPTS.md)
└─ docs/
   ├─ HISTORICO.md
   ├─ DECISIONES.md
   ├─ CATALOGO.md
   ├─ SCRIPTS.md
   └─ NOMBRES.md
```
(Se ampliará con `web/`, `scripts/`, etc. cuando se decida el stack.)
