# Historial de cambios del instalador

Versiones de la más reciente a la más antigua. La guía de la versión actual está en [SCRIPT.md](SCRIPT.md).

## v0.2.0 — 2026-11-24

- Se separó el instalador en un lanzador BAT, una interfaz gráfica y un motor PowerShell. La ventana solicita permisos de administrador y ejecuta el motor en segundo plano al pulsar **Iniciar instalación**.
- Los registros pasaron a `%LOCALAPPDATA%\win4win\Registros`, con una carpeta por ejecución. La GUI guarda la salida y los errores del motor y ofrece el botón **Abrir registros**.
- Se añadió `-VerificarDescargas` para comprobar los paquetes WinGet, los instaladores directos, el MSI de respaldo de Chrome y los archivos de las extensiones de Chrome y Firefox.
- Las descargas directas comparten la comprobación de firma Authenticode y los reintentos ante fallos transitorios. Se mantuvieron las políticas de los navegadores y la restauración opcional desde `copia_config`.
- La revisión actual de esta misma versión añade la tarea activa, la barra con el porcentaje de pasos completados y mensajes finales que indican si hay avisos, errores o un reinicio pendiente. El lanzador quedó como `Win4Win.bat`, con la GUI y el motor bajo el prefijo `Win4Win-`, y se actualizó el ZIP de descarga.

## v0.1.1 — 2026-11-17

- Se añadió la comprobación de firma Authenticode a los EXE y MSI descargados y se eliminó la automatización de clics en los asistentes de instalación.
- La restauración del escritorio pasó a generar un respaldo y copiar solo los elementos que faltaban. Se desactivó la importación automática de archivos `.reg` y `start2.bin`.
- El instalador de consola guardaba el registro y el resumen CSV en `%ProgramData%\InstalarTodo`. El modo silencioso requería una sesión elevada del usuario final.

## v0.1.0 — Primera versión del prototipo

- Se introdujo el instalador PowerShell con lanzador BAT, petición de permisos de administrador, modo silencioso y registro de ejecución.
- Se instalaba la selección fija de programas con WinGet y con descargas directas para DNIe y aTube Catcher. Chrome disponía de un MSI oficial de respaldo si fallaba la comprobación de hash de WinGet.
- Se configuraba Google como página de inicio, uBlock Origin Lite en Chrome y Video DownloadHelper en Firefox.
- Se incorporó la restauración opcional del escritorio, la barra de tareas y el menú Inicio desde `copia_config`.
