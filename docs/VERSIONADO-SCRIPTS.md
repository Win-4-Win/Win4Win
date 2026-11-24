# Versionado de scripts

Este documento registra las versiones del instalador y sus
características. Se utiliza **Versionado Semántico** (`MAYOR.MENOR.PARCHE`)
según la convención definida en [VERSIONES.md](VERSIONES.md).

- `0.MENOR.0`: nueva funcionalidad mientras el producto está en desarrollo.
- `0.x.PARCHE`: corrección sin funcionalidad nueva.
- `1.0.0`: primera versión estable y desplegada.

## v0.2.0

- **Estado:** implementación en desarrollo, pendiente de validación integral.
- **Fase:** 1 — instalación de programas y configuración básica.
- **Sistema previsto:** Windows 10 y 11 de 64 bits, con Windows PowerShell 5.1.

| Archivo | Función |
|---------|---------|
| [`exec-main-v0.2.0.bat`](../scripts/exec-main-v0.2.0.bat) | Abre la interfaz en Windows PowerShell. |
| [`exec-main-gui-v0.2.0.ps1`](../scripts/exec-main-gui-v0.2.0.ps1) | Solicita permisos de administrador, inicia el motor en segundo plano y muestra una barra de actividad y el resultado general. **Abrir registros** lleva a la carpeta de ejecución. |
| [`exec-main-motor-v0.2.0.ps1`](../scripts/exec-main-motor-v0.2.0.ps1) | Comprueba los programas instalados, instala los que faltan y aplica la configuración de navegadores y del entorno. |

### Cambios frente a v0.1.1

- La interfaz gráfica y el motor se separan. La interfaz de esta revisión
  muestra el estado general y una barra de actividad durante la ejecución.
- Los registros se organizan por ejecución en
  `%LOCALAPPDATA%\win4win\Registros`. Se guardan el registro de PowerShell
  y los informes CSV. La interfaz captura además la salida y los errores.
- El parámetro `-VerificarDescargas` del motor permite comprobar los paquetes
  de WinGet, DNIe, aTube Catcher, el MSI de respaldo de Chrome y las extensiones
  de Chrome y Firefox sin ejecutar los instaladores.
- Las descargas directas comparten la comprobación de firma Authenticode y
  los reintentos para fallos transitorios. El MSI oficial de Chrome sigue
  disponible como respaldo.
- Se conservan las políticas de Chrome, Brave y Firefox y la restauración
  opcional desde `copia_config`, con respaldo del escritorio y copia sin
  sobrescribir los elementos existentes.

### Validación pendiente

- El BAT apunta a la GUI versionada. La GUI todavía busca
  `win4win_motor.ps1` en vez del nombre del motor presente en `scripts/`.
  Esta referencia impide completar la instalación desde la ventana tal
  como están los archivos.
- Queda por validar la descarga y la instalación de extremo a extremo en
  Windows. Esta revisión de la GUI carece de tarea activa y porcentaje numérico.

## v0.1.1

Parche del instalador por consola. Añadió comprobación de firma Authenticode
para EXE y MSI descargados, eliminó la automatización de clics en los
asistentes y protegió la restauración del escritorio con un respaldo previo
y copia sin sobrescritura. Los registros y el resumen CSV se guardaban en
`%ProgramData%\InstalarTodo`.

## v0.1.0

**Estado:** primera versión funcional del prototipo  
**Fase:** 1 — instalación de programas y configuración básica  
**Sistema previsto:** Windows 11 ya instalado  
**Archivos:**

- [`scripts/script-mian-v0.1.0.ps1`](../scripts/script-mian-v0.1.0.ps1): script
  principal de instalación y configuración.
- [`scripts/exec-main-v0.1.0.bat`](../scripts/exec-main-v0.1.0.bat): lanzador
  del script PowerShell con `ExecutionPolicy Bypass`.

### Características

1. **Ejecución y permisos**
   - Comprueba si se ejecuta como administrador y se autoeleva cuando es
     necesario.
   - Permite el parámetro `-Silencioso` para una ejecución sin interacción.
   - En modo silencioso espera hasta 20 minutos a que haya red y `winget`.
   - Registra la ejecución mediante `Start-Transcript`. El registro se guarda
     junto al script o en `%ProgramData%\instalacion.log` en modo silencioso.

2. **Instalación de programas**
   - Usa `winget` con acuerdos aceptados y sin interacción.
   - Instala Firefox, Chrome, Brave, K-Lite Codec Pack, VLC, WinRAR, Adobe
     Acrobat Reader, PDFgear y AutoFirma.
   - Reintenta hasta tres veces los errores de red.
   - Considera correctamente el caso de un programa que ya estaba instalado.
   - Si el hash de Chrome no coincide con el catálogo de `winget`, utiliza el
     MSI oficial de Google como alternativa.
   - Descarga e instala DNIe y aTube Catcher desde sus URL configuradas,
     comprobando si ya están instalados antes de descargarlos.
   - Para instaladores `.exe`, prueba modos silenciosos y, si no funcionan,
     automatiza el asistente de instalación como último recurso.
   - Muestra al final los programas que no se pudieron confirmar.

3. **Configuración de navegadores**
   - Define Google como página de inicio y página de apertura de Chrome y
     Brave mediante políticas del sistema.
   - Fuerza uBlock Origin Lite en Chrome.
   - Configura Firefox mediante `distribution/policies.json` e instala
     Video DownloadHelper.
   - Escribe preferencias iniciales de Brave y realiza un primer arranque en
     segundo plano cuando todavía no existe el perfil.
   - Añade Google a los accesos directos de Brave que encuentra.

4. **Personalización del entorno**
   - Si existe `copia_config`, puede restaurar Escritorio, barra de tareas y
     menú Inicio.
   - Puede enviar el contenido actual del Escritorio a la Papelera antes de
     copiar la configuración.
   - Permite activar un Inicio limpio sin recomendados ni elementos recientes.
   - Reinicia el Explorador de Windows para aplicar los cambios.

5. **Parámetros configurables**
   - `$PaginaInicio`
   - `$StartLimpio`
   - `$LimpiarEscritorio`
   - `$ExtensionChrome`
   - `$ExtensionFirefox`
   - `$programas`

### Limitaciones conocidas

- La versión se ha descrito para Windows 11 ya instalado, aunque el encabezado
  del script indica compatibilidad con Windows 10/11.
- Todavía no incluye `winget upgrade`, limpieza del sistema, gestión de
  programas de arranque ni optimización del disco; estas funciones están
  previstas para `v0.3.0`.
- La instalación de Windows 11 desatendida se mantiene fuera de esta versión.
- El script necesita revisar antes de publicarse las fuentes, hashes y la
  inclusión de datos de `copia_config`.
- La carpeta `copia_config` es opcional y no debe contener datos personales en
  una versión distribuible.

## Próximas versiones

| Versión | Cambios previstos |
|---------|-------------------|
| `v0.3.0` | Actualización de programas, optimización, limpieza y gestión del arranque. |
| `v0.4.0` | Instalación desatendida de Windows 11 mediante USB/ISO. |
| `v0.5.0` | Selección de programas y ajustes desde la web. |
| `v1.0.0` | Versión estable y desplegada. |
