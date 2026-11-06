# Scripts (primer prototipo)

Carpeta: [`script/`](../script). Prototipo funcional en PowerShell con envoltorios `.bat`.

## Archivos

| Archivo | Función |
|---------|---------|
| `instalar_todo.ps1` | Script principal: instala programas, configura navegadores y restaura barra de tareas, Inicio y Escritorio. |
| `instalar_todo.bat` | Lanzador: ejecuta el `.ps1` con `-ExecutionPolicy Bypass`. |
| `copia_configuracion.ps1` | Se ejecuta en el PC **de origen** y genera `copia_config/` (Escritorio, barra de tareas, Inicio y ajustes). |
| `copia_configuracion.bat` | Lanzador del anterior. |
| `dnie.exe` | Instalador de los controladores del DNIe (binario incluido en el repositorio). |
| `copia_config/` | Configuración exportada: `taskbar.reg`, `start.reg`, `advanced.reg`, `start2.bin`, `TaskBar/` y `Escritorio/`. |

## Flujo de `instalar_todo.ps1`

1. **Auto-elevación** a administrador y log en `instalacion.log` (`Start-Transcript`).
2. **Comprobación de `winget`**; si falta, avisa y termina.
3. **Instalación** (silenciosa, aceptando acuerdos) con `winget install --id`. Se tolera el código "ya instalado" (`-1978335189`):
   Firefox, Chrome, Brave, K-Lite Codec Pack, VLC, WinRAR, Adobe Acrobat Reader, PDFgear.
4. **DNIe** (`dnie.exe`) antes que **AutoFirma** (se busca por nombre en winget), porque AutoFirma lo necesita.
5. **aTube Catcher**: descarga desde una URL fija a `%TEMP%` y se instala con `/S`.
6. Función `Instalar-Auto` para `.exe`: prueba modos silenciosos (90 s cada uno) y, si falla, automatiza el asistente con `SendKeys` (Alt+A, Enter).
7. **Configuración de navegadores** por políticas:
   - Chrome y Brave: página de inicio, abrir al arrancar, y extensión **uBlock Origin Lite** forzada (`ExtensionInstallForcelist`).
   - Firefox: página de inicio mediante `distribution/policies.json`.
8. **Restauración de Escritorio, barra de tareas e Inicio** desde `copia_config/` (si existe), con opciones `$LimpiarEscritorio` (envía a la Papelera) y `$StartLimpio`. Reinicia el Explorador.
9. **Resumen** final de programas fallidos.

Parámetros editables al inicio: `$PaginaInicio`, `$StartLimpio`, `$LimpiarEscritorio`, `$ExtensionChrome`, lista `$programas`.

## Estado frente al alcance

| Paso del alcance | Estado |
|------------------|--------|
| Instalar programas (silent) | ✅ Hecho |
| Configurar navegadores (inicio, extensiones) | ✅ Chrome y Brave; Firefox solo página de inicio |
| Extensión Video DownloadHelper en Firefox | ⏳ Pendiente |
| Escritorio, barra de tareas, Inicio | ✅ Hecho (por copia de otro equipo) |
| Instalar Windows 11 (desatendido) | ⏳ Pendiente |
| Actualizar programas instalados (`winget upgrade`) | ⏳ Pendiente (v0.3.0) |
| Drivers y Windows Update | ❌ Descartado (lo gestiona Windows) |
| Office | ⏳ Pendiente (ver decisión 12) |
| Limpieza (categorías del Liberador de espacio en disco de Windows 11) | ⏳ Pendiente (v0.3.0) |
| Arranque: que los programas no se inicien con Windows, salvo los necesarios (antivirus y poco más) | ⏳ Pendiente (v0.3.0) |
| Optimización de disco (desfragmentar HDD / TRIM SSD) | ⏳ Pendiente (v0.3.0) |
| Empaquetado `.exe` | ⏳ Pendiente |

## Puntos a revisar (deuda técnica)

- **Datos personales en el repositorio:** `copia_config/Escritorio/` contiene capturas, documentos y accesos del escritorio real, y hay una copia anidada duplicada en `Nueva carpeta (2)`. No subir esto a GitHub; excluir con `.gitignore` y usar una configuración de ejemplo limpia.
- **Binario `dnie.exe`:** versionarlo no es buena práctica. Mejor descargarlo desde la fuente oficial con comprobación de hash.
- **URL fija de aTube Catcher** (con versión en el nombre) caduca; sin verificación de integridad ni confirmación de la fuente.
- **Automatización con `SendKeys`** es frágil; usar solo como último recurso.
- **Escritorio:** el vaciado a la Papelera es destructivo; pedir confirmación en la versión final.
- Mensajes sin acentos; sin pruebas automáticas todavía.
