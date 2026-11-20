# Versionado de scripts

Este documento registra las versiones publicadas del instalador y sus
características. Se utiliza **Versionado Semántico** (`MAYOR.MENOR.PARCHE`)
según la convención definida en [VERSIONES.md](VERSIONES.md).

- `0.MENOR.0`: nueva funcionalidad mientras el producto está en desarrollo.
- `0.x.PARCHE`: corrección sin funcionalidad nueva.
- `1.0.0`: primera versión estable y desplegada.

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
| `v0.2.0` | Configuración ampliada de navegadores y del entorno. |
| `v0.3.0` | Actualización de programas, optimización, limpieza y gestión del arranque. |
| `v0.4.0` | Instalación desatendida de Windows 11 mediante USB/ISO. |
| `v0.5.0` | Selección de programas y ajustes desde la web. |
| `v1.0.0` | Versión estable y desplegada. |
