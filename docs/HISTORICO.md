# Histórico del proyecto

Bitácora de hitos y decisiones. Entradas nuevas arriba.

## 2026-11-06 — Repositorio enlazado y criterio para versionar scripts
- Se inicializa Git en la carpeta del proyecto y se enlaza con `Win-4-Win/Win4Win` (rama `main`).
- Decisión 16: del directorio `script/` solo se versionan los `.ps1` y `.bat`; `copia_config/` (datos personales) y los binarios quedan excluidos con `.gitignore`. Los scripts siguen en el repositorio y la BBDD, si llega a haberla, solo guardaría metadatos (decisión 4).
- Se retira de [AGENTS.md](../AGENTS.md) la mención a un activador concreto; la regla de no incluir activadores no cambia.

## 2026-11-04 — Organización Win-4-Win creada
- Se confirma que la organización de GitHub **Win-4-Win** ya está creada; se elimina esa tarea pendiente de la decisión 14.
- Actualizados [DECISIONES.md](DECISIONES.md), [NOMBRES.md](NOMBRES.md) y [AGENTS.md](../AGENTS.md). La entrada anterior refleja el estado que había en ese momento.

## 2026-11-04 — Cambio de nombre y organización en GitHub
- Se cambia el nombre elegido del proyecto de PCReady a **Win4Win** (decisión 6).
- Se fija **Win-4-Win** como nombre de la organización prevista en GitHub (decisión 14); queda pendiente crearla y configurarla.
- Actualizados [DECISIONES.md](DECISIONES.md), [NOMBRES.md](NOMBRES.md) y [AGENTS.md](../AGENTS.md).

## 2026-11-04 — Elección provisional del nombre PCReady
- Se elige **PCReady** como nombre provisional del proyecto por ser directo y fácil de recordar.
- Actualizados [DECISIONES.md](DECISIONES.md), [NOMBRES.md](NOMBRES.md) y [AGENTS.md](../AGENTS.md). Queda pendiente comprobar disponibilidad de dominio y marca.

## 2026-11-03 — Cambio de alcance: fuera drivers y Windows Update
- Se retiran del alcance drivers y Windows Update (los gestiona Windows solo). Se sustituyen por: gestión de programas de arranque, limpieza de temporales y residuos de la instalación de Windows, optimización de disco y upgrade de los programas ya instalados.
- Actualizados AGENTS.md, VERSIONES.md (v0.3.0), SCRIPTS.md y la skill `script-powershell-instalador`.
- Nota técnica: la desfragmentación solo aplica a discos HDD; en SSD no se desfragmenta (reduce su vida útil) y Windows usa TRIM. `Optimize-Volume` elige la operación correcta según el tipo de disco.
- Precisado: "arranque" = que los programas no se inicien con Windows, salvo los necesarios (antivirus y poco más; lista de excepciones). "Limpieza" = las categorías del Liberador de espacio en disco de Windows 11 (`cleanmgr`, configurable con `/sageset` y `/sagerun`; también Configuración > Almacenamiento).

## 2026-11-03 — Alcance y versionado de la v0.1.0
- Adoptado SemVer en `0.x` y hoja de ruta inicial en [VERSIONES.md](VERSIONES.md). Decisión 15.
- v0.1.0: web estática con un descargable que instala el catálogo sobre un Windows 11 ya instalado. Se aplaza la integración con Rufus/ISO desatendida (v0.4.0).

## 2026-11-03 — Stack de la v1: solo front
- Decisión 3 cerrada para la v1: web solo con HTML, CSS y JS vanilla, sin backend. Encaja con lo visto en el curso y con el hosting estático gratuito (decisión 10).
- Consecuencia: el catálogo y los scripts se sirven como ficheros estáticos; la BBDD (decisión 4) se aplaza.

## 2026-11-03 — DNIe fuera de la v1
- El DNIe se excluye de la primera versión del catálogo: era el único programa que necesitaba un `.exe` descargado previamente. Se reevaluará con descarga automática y verificación de hash.
- Nota: `script/instalar_todo.ps1` aún lo instala; hay que retirarlo del script y de `dnie.exe` cuando se actualice.

## 2026-11-03 — Licencias cerradas
- Decisión 12 cerrada: Windows 11 sin activar y LibreOffice en lugar de Office, sin activadores.
- ArtCraft: se valorará incluir sus programas en el catálogo si evolucionan de forma interesante (pendiente de verificar licencia, `winget` e instalación silenciosa).

## 2026-11-03 — Decisiones del prototipo v1
- Cerradas: formato `.ps1` + `.bat` (decisión 1) y `winget` (decisión 2). Stack web aplazado (3). Sprint, nombre y resto, aplazados.
- Propuesta de almacén (decisión 4): scripts en Git y MongoDB Atlas M0 gratuito solo para metadatos del catálogo. Motivos: encaja con el stack JS/Node que domina el equipo; los programas tienen opciones de configuración muy variables (esquema flexible); el plan gratuito cubre el volumen previsto; los scripts siguen revisables y versionados fuera de la BBDD.
- Hosting (decisión 10): propuesta aceptada, prototipo local primero.
- Licencias (decisión 12): el equipo propuso activar Windows/Office con massgrave en la demo local. Se mantiene la regla del proyecto de no incluir ni documentar activadores; se proponen alternativas legítimas para la demo.

## 2026-10-30 — Gestor de proyectos pendiente
- Anotada como tarea pendiente la elección del gestor de proyectos (Trello o GitHub Projects). Decisión 13.
- Anotado como idea a valorar: crear una organización de GitHub para el proyecto. Decisión 14.

## 2026-10-30 — Skills del proyecto
- Creadas 4 skills de workspace en `.github/skills/`: `registrar-hito`, `script-powershell-instalador`, `anadir-programa-catalogo`, `planificar-sprint`.
- Añadida a AGENTS.md la regla: preguntar al usuario si hace falta.

## 2026-10-30 — Primer script (prototipo)
- Existe un primer prototipo en `script/` (PowerShell + `.bat`): instala los programas de la fase 1 con `winget`, configura Chrome/Brave/Firefox, y restaura Escritorio, barra de tareas e Inicio desde una copia de otro equipo. Detalle en [SCRIPTS.md](SCRIPTS.md).
- IDs de winget del catálogo usados y funcionando en el script; AutoFirma por nombre; DNIe y aTube Catcher por instalador `.exe`.
- Detectado: hay datos personales en `script/copia_config/Escritorio` que no deben subirse al repositorio.
- Pendiente del alcance: Windows desatendido, drivers, Windows Update, Office, limpieza, arranque, `.exe`.

## 2026-10-30 — Catálogo inicial
- Definida la lista de programas de la fase 1 (ver [CATALOGO.md](CATALOGO.md)).
- Activación de Windows/Office con scripts no oficiales (massgrave): **no se incluye** en el proyecto ni en la documentación; se plantean vías con licencia legítima o alternativas libres. Ver decisión 12.
- Se barajan alternativas gratuitas/open source a futuro.

## 2026-10-30 — Flujo de trabajo y presupuesto
- Se usará Git y GitHub con ramas, Pull Requests y tests.
- Presupuesto de producción limitado: priorizar opciones gratuitas o de bajo coste.
- Pendientes: fecha de entrega/requisitos del curso, reparto de roles y lista de programas de la suite básica (el mensaje llegó sin la lista).

## 2026-10-30 — Arranque del proyecto
- Definida la idea: web que sirve scripts/ejecutables preplanificados para automatizar instalaciones de Windows 11.
- Definidas las 3 fases: instalar → automatizar → selección personalizada en la web.
- Equipo de 3 personas, trabajo "tipo" Agile por sprints (duración y fecha de lanzamiento pendientes).
- Preferencia inicial de formato: **.exe** (a validar técnicamente).
- Stack web abierto: JS/Node probable, con framework (React, Astro, Angular…) si el curso lo permite. En el curso: JS vanilla, Java, Python.
- Objetivo: publicar en **producción real**, no solo demo. Habrá memoria, documentación y defensa.
- Alcance base: Windows + "suite básica" de programas elegida por el equipo; a futuro, el usuario elige solo programas, o Windows + programas.
- Creados `AGENTS.md`, `docs/HISTORICO.md`, `docs/DECISIONES.md` y `docs/NOMBRES.md`.
