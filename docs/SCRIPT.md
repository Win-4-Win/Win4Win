# Instalador de Win4Win

**Versión actual: v0.2.0.** Instala aplicaciones sobre un Windows existente y aplica una configuración básica a los navegadores y, si se aporta una copia, al entorno del usuario. El catálogo de esta versión es fijo. [Historial de cambios](SCRIPT-CHANGELOG.md)

## Requisitos

- Windows 10 u 11 de 64 bits y Windows PowerShell 5.1.
- Conexión a Internet y App Installer con WinGet para instalar los paquetes del catálogo.
- Permisos de administrador en la sesión del usuario que va a recibir la configuración.

## Programas que instala

| Orden | Programa | Método |
| --- | --- | --- |
| 1 | Mozilla Firefox | WinGet |
| 2 | Google Chrome | WinGet, con el MSI oficial de Google como respaldo |
| 3 | Brave | WinGet |
| 4 | K-Lite Codec Pack Standard | WinGet |
| 5 | VLC | WinGet |
| 6 | WinRAR | WinGet |
| 7 | Adobe Acrobat Reader de 64 bits | WinGet |
| 8 | PDFgear | WinGet |
| 9 | DNIe (componente para usar el DNI electrónico) | Descarga directa |
| 10 | AutoFirma | WinGet |
| 11 | aTube Catcher | Descarga directa |

## Flujo de instalación

1. **Preparación.** [Win4Win.bat](../scripts/Win4Win.bat) abre la [interfaz](../scripts/Win4Win-GUI-v0.2.0.ps1), que solicita permisos de administrador si hacen falta. Al pulsar **Iniciar instalación**, crea una carpeta de registros y ejecuta el [motor](../scripts/Win4Win-Motor-v0.2.0.ps1) en segundo plano con `-Silencioso`. El motor comprueba la disponibilidad de WinGet.
2. **Instalación.** El motor revisa el registro de Windows para saltarse los programas que detecta como ya instalados. Instala los que faltan en el orden de la tabla y comprueba la firma digital Authenticode de los EXE y MSI descargados directamente antes de ejecutarlos.
3. **Configuración de navegadores.** Establece Google como página de inicio y de apertura en Chrome, Brave y Firefox. Configura la instalación de uBlock Origin Lite en Chrome y Video DownloadHelper en Firefox mediante políticas del navegador.
4. **Restauración opcional.** Si existe `copia_config` junto al motor, hace un respaldo del escritorio antes de copiar los elementos que faltan. También puede copiar accesos de la barra de tareas. Los anclajes dependen de Windows y los archivos de registro y de Inicio de la copia requieren revisión manual.
5. **Resultado.** Guarda el registro de PowerShell, un CSV con los resultados a medida que se ejecutan los pasos y un CSV de resumen final. Desde la GUI también quedan `salida.txt` y `errores.txt`. Las carpetas de cada ejecución se guardan en `%LOCALAPPDATA%\win4win\Registros`.

## Interfaz gráfica

La ventana muestra el estado general, la tarea activa y una barra con el porcentaje de pasos completados. El 100 % indica que el motor llegó al final, que puede incluir avisos o un reinicio pendiente. El mensaje final indica el resultado.

- **Iniciar instalación** ejecuta el catálogo completo. El botón y el cierre de la ventana quedan bloqueados durante la instalación.
- **Abrir registros** abre la carpeta de la última ejecución iniciada desde esa ventana. Antes de la primera ejecución abre la carpeta general de registros.

## Cómo usarlo

1. Descarga [Win4Win.zip](../scripts/download/Win4Win.zip) y extrae su contenido completo en una carpeta local. El ZIP incluye el lanzador, los dos scripts PowerShell y `LEEME.txt`.
2. Abre `Win4Win.bat` desde la carpeta extraída y acepta el aviso de administrador.
3. Pulsa **Iniciar instalación** y espera a que aparezca el resultado final.
4. Si hay avisos o errores, pulsa **Abrir registros** y consulta el CSV de resumen. Reinicia Windows si la ventana lo solicita. Vuelve a abrir los navegadores para que carguen su configuración.

### Comprobar las descargas desde PowerShell

Desde la carpeta extraída, ejecuta este comando para probar las descargas de los paquetes WinGet, los instaladores directos, el MSI de respaldo de Chrome y las dos extensiones, sin ejecutar instaladores ni aplicar la configuración.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Win4Win-Motor-v0.2.0.ps1" -VerificarDescargas
```
