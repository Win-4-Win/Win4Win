# Decisiones de diseño

| # | Tema | Estado | Decisión / opciones |
|---|------|--------|---------------------|
| 1 | Formato del instalador | Cerrada (prototipo) | `.ps1` + lanzador `.bat` para la v1 (evita SmartScreen/firma de código). El `.exe` se reevaluará más adelante. |
| 2 | Gestor de paquetes | Cerrada | `winget`. |
| 3 | Stack web | Cerrada (v1) | Solo front: HTML, CSS y JS vanilla, sin backend ni BBDD en la v1. Framework (React, Astro, Angular) y backend se reevaluarán después. |
| 4 | Almacén de scripts y BBDD | Propuesta (aplazada) | Para la v1 no hay BBDD: el catálogo y los scripts son ficheros estáticos versionados en Git (p. ej. un `catalogo.json`). Propuesta para después: MongoDB Atlas M0 solo para metadatos del catálogo. Ver histórico. |
| 5 | Duración de sprint y fecha de lanzamiento | Parcialmente cerrada | Sprints de 2 semanas; capacidad orientativa de 3 h por persona y semana. Fecha por confirmar; abril es una referencia aproximada. |
| 17 | Hypervisor para pruebas | Cerrada | **Oracle VirtualBox**. El equipo tiene experiencia previa con VirtualBox; ofrece mejor compatibilidad si alguien usa Windows Home y no interfiere con otras herramientas (Docker, WSL2). |
| 6 | Nombre del proyecto | Cerrada | **Win4Win**. Pendiente de comprobar disponibilidad de dominio y marca. Ver [NOMBRES.md](NOMBRES.md). |
| 7 | Alcance "instalar Windows" | Cerrada (por fases) | Base: Windows + suite básica. Final: usuario elige solo programas, o Windows + programas. |
| 9 | Flujo Git | Cerrada | GitHub, ramas por funcionalidad, Pull Requests con revisión y tests. Detalle (nombres de ramas, CI) por definir. |
| 10 | Hosting / presupuesto | Propuesta (aceptada) | Prototipo en local. Si se despliega: front estático en Cloudflare Pages/Vercel/Netlify (gratis); API Node en Render/Railway/Fly (plan gratuito o ~5 €/mes; ojo con arranques en frío); BBDD en MongoDB Atlas M0; scripts en GitHub Releases o Cloudflare R2 (gratis hasta 10 GB). Dominio ~10 €/año. |
| 11 | Suite básica de programas | Cerrada (v1) | Ver [CATALOGO.md](CATALOGO.md). |
| 12 | Licencias de Windows/Office | Cerrada | Windows 11 sin activar (o Enterprise Evaluation en VM para demos) y LibreOffice en lugar de Office. Sin activadores de terceros. |
| 13 | Gestor de proyectos | Cerrada | GitHub Projects, con tablero tipo kanban. |
| 14 | Organización en GitHub | Cerrada | Organización **Win-4-Win**, creada para centralizar repositorios, Projects y permisos del equipo. |
| 15 | Versionado y alcance de la v0.1.0 | Cerrada | SemVer en `0.x`; v0.1.0 = web estática + descargable `.ps1`/`.bat` que instala el catálogo sobre Windows 11 ya instalado (sin Rufus/ISO). Ver [VERSIONES.md](VERSIONES.md). |
| 16 | Qué se versiona de `script/` | Cerrada | Se suben al repositorio solo los `.ps1` y `.bat` (código revisable). Quedan fuera, vía `.gitignore`, `copia_config/` (datos personales) y binarios como `dnie.exe` (se descargarán de la fuente oficial con comprobación de hash). Complementa la decisión 4. |
| 8 | Entregables del curso | Abierta | Seguro: memoria, documentación y defensa. Producción real. Confirmar requisitos. |
