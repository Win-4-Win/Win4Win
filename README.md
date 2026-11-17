# Win4Win

Win4Win es un proyecto final del ciclo de Desarrollo de Aplicaciones Web (DAW) para facilitar la puesta a punto de equipos con Windows 11. La idea es ofrecer una web desde la que se descarguen scripts predefinidos y versionados para instalar y configurar programas; la web no generará scripts al vuelo.

> **Estado actual:** el proyecto está en fase de diseño y planificación. El repositorio contiene documentación de alcance, un prototipo de scripts descrito en `docs/SCRIPTS.md` y una primera versión de la web estática en `src/`.

## Alcance previsto

La primera versión está planteada como una web estática con HTML, CSS y JavaScript vanilla, y un descargable `.ps1` con lanzador `.bat` que instala el catálogo sobre un Windows 11 ya instalado. El catálogo y los scripts se servirían como archivos estáticos versionados en Git, sin backend ni base de datos en esta versión.

La hoja de ruta contempla:

1. Instalar el catálogo y aplicar configuración básica.
2. Automatizar la puesta a punto, incluyendo actualizaciones de programas, opciones de arranque, limpieza y optimización de disco.
3. Permitir elegir desde la web los programas y ajustes que se quieren incluir.

La instalación desatendida de Windows 11 se plantea para una fase posterior. Los drivers y Windows Update quedan fuera del alcance de los scripts: los gestiona Windows. El orden y el contenido de las versiones son propuestas sujetas a la planificación de los sprints; consulta [`docs/VERSIONES.md`](docs/VERSIONES.md).

## Desarrollo y seguridad

- Equipo de tres personas, con trabajo por sprints.
- El nombre del proyecto es **Win4Win** y la organización de GitHub es **Win-4-Win**.
- Se trabajará con ramas y Pull Requests; no se debe integrar directamente en `main`.
- La automatización prevista usa `winget`. Los scripts que se incorporen deben ser idempotentes, registrar logs, no contener secretos y descargar software de fuentes oficiales.
- No se incluyen activadores ni cracks. El catálogo debe respetar las licencias de cada programa.

Los scripts de instalación pueden ejecutar acciones con privilegios de administrador. No ejecutes scripts del proyecto en equipos que no controles; revisa su contenido antes de utilizarlos.

## Web

La web estática se encuentra en [`src/`](src/). Para visualizarla, abre `src/index.html` en un navegador.

| Archivo | Función |
|---------|---------|
| `src/index.html` | Página principal con todas las secciones. |
| `src/styles.css` | Estilos retro de terminal (fondo oscuro, texto verde, efecto CRT). |
| `src/app.js` | Modales de perfil, acordeón FAQ y menú responsive. |

**Secciones de la web:**
- **Hero:** presentación del proyecto y enlace a la descarga.
- **Script:** última versión con instrucciones de uso, programas incluidos y enlaces de descarga a `scripts/`.
- **Quiénes somos:** descripción del proyecto DAW y tarjetas del equipo (Edu, Raúl, José) con modales de perfil.
- **Preguntas frecuentes:** 10 preguntas sobre el script y el proyecto.

## Documentación

- [`docs/DECISIONES.md`](docs/DECISIONES.md): decisiones abiertas y cerradas del diseño.
- [`docs/HISTORICO.md`](docs/HISTORICO.md): registro cronológico de cambios y decisiones.
- [`docs/CATALOGO.md`](docs/CATALOGO.md): programas previstos y estado de verificación.
- [`docs/SCRIPTS.md`](docs/SCRIPTS.md): descripción y estado del prototipo documentado.
- [`docs/VERSIONES.md`](docs/VERSIONES.md): versionado y hoja de ruta.
- [`docs/GIT.md`](docs/GIT.md): flujo de trabajo con Git (ramas, commits y Pull Requests).
- [`docs/NOMBRES.md`](docs/NOMBRES.md): nombre elegido y propuestas consideradas.

## Estado de entrega

El proyecto no tiene todavía una versión publicada ni una web desplegada. La web estática en `src/` se puede visualizar localmente abriendo `src/index.html`. No hay pruebas automatizadas disponibles en este checkout.
