#requires -Version 5.1
<#
 Instalador Windows 10/11 v2.0
 Uso: .\instalar_todo.ps1 [-Silencioso] [-LimpiarEscritorio] [-StartLimpio]
 IMPORTANTE: ejecutar en la sesion del usuario final (no SYSTEM).
 Los EXE externos solo se ejecutan si tienen firma Authenticode valida.
#>
[CmdletBinding()]
param([switch]$Silencioso, [switch]$LimpiarEscritorio, [switch]$StartLimpio)
$ErrorActionPreference = 'Stop'
$PaginaInicio = 'https://www.google.com/'
$ExtensionChrome = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
$ExtensionFirefox = 'https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper/latest.xpi'
$UrlATube = 'https://opera.dsnetwb.com/files/aTube-Catcher-Setup-26.8.20-x64.exe'
$UrlDNIe = 'https://www.dnielectronico.es/descargas/CSP_para_Sistemas_Windows/Windows_64_bits/Instalador_Tarjetas_DNIe_x64.exe'
$Programas = @(
 @{Nombre='Mozilla Firefox';Id='Mozilla.Firefox';Patron='Mozilla Firefox'},
 @{Nombre='Google Chrome';Id='Google.Chrome';Patron='Google Chrome'},
 @{Nombre='Brave';Id='Brave.Brave';Patron='Brave'},
 @{Nombre='K-Lite Codec Pack';Id='CodecGuide.K-LiteCodecPack.Standard';Patron='K-Lite Codec Pack'},
 @{Nombre='VLC';Id='VideoLAN.VLC';Patron='VLC media player'},
 @{Nombre='WinRAR';Id='RARLab.WinRAR';Patron='WinRAR'},
 @{Nombre='Adobe Acrobat Reader';Id='Adobe.Acrobat.Reader.64-bit';Patron='Adobe Acrobat'},
 @{Nombre='PDFgear';Id='PDFgear.PDFgear';Patron='PDFgear'}
)
$script:Resultados = [System.Collections.Generic.List[object]]::new()
$script:ReinicioPendiente = $false
$script:Inicio = Get-Date
$script:LogDir = Join-Path $env:ProgramData 'InstalarTodo'
New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
$script:Log = Join-Path $script:LogDir ('instalacion_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
$script:TranscriptActivo = $false
try { Start-Transcript -Path $script:Log -ErrorAction Stop | Out-Null; $script:TranscriptActivo = $true } catch { Write-Warning "No se pudo iniciar transcript: $_" }
function Registrar([string]$Nombre,[string]$Estado,[string]$Detalle='') {
 $script:Resultados.Add([pscustomobject]@{Programa=$Nombre;Estado=$Estado;Detalle=$Detalle})
 Write-Host ('[{0}] {1} {2}' -f $Estado,$Nombre,$Detalle)
}
function Es-Admin {
 $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
 return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Test-Instalado([string]$Patron) {
 $claves = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
 return [bool](Get-ItemProperty $claves -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match $Patron } | Select-Object -First 1)
}
function Esperar-Winget {
 $limite = if ($Silencioso) { (Get-Date).AddMinutes(20) } else { (Get-Date).AddSeconds(10) }
 do {
  if (Get-Command winget.exe -ErrorAction SilentlyContinue) { return $true }
  if ($Silencioso) {
   try { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue } catch {}
   Start-Sleep -Seconds 15
  } else { Start-Sleep -Seconds 2 }
 } while ((Get-Date) -lt $limite)
 return $false
}
function Invocar-Winget([string]$Nombre,[string]$Id,[string]$Patron) {
 if (Test-Instalado $Patron) { Registrar $Nombre 'OMITIDO' 'Ya instalado'; return }
 $codigo = -1
 for ($i=1; $i -le 3; $i++) {
  try {
   & winget.exe install --id $Id --exact --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
   $codigo = $LASTEXITCODE
  } catch { $codigo = -1; Write-Warning $_ }
  if ($codigo -eq 0 -or $codigo -eq -1978335189 -or (Test-Instalado $Patron)) { break }
  # Reintentar solo errores de red conocidos, no fallos de hash o instalador
  if (@(-2147012867,-2147012889,-2147012894,-2147012866,-2147012865) -notcontains $codigo) { break }
  if ($i -lt 3) { Start-Sleep -Seconds (5 * $i) }
 }
 if ($codigo -eq 3010 -or $codigo -eq 1641) { $script:ReinicioPendiente = $true }
 if ($codigo -eq 0 -or $codigo -eq -1978335189 -or $codigo -eq 3010 -or $codigo -eq 1641 -or (Test-Instalado $Patron)) {
  Registrar $Nombre 'OK' "Winget: $codigo"
 } elseif ($Id -eq 'Google.Chrome' -and $codigo -eq -1978335215) {
  Instalar-ChromeMsi
 } else { Registrar $Nombre 'FALLO' "Winget: $codigo" }
}
function Descargar-Seguro([string]$Url,[string]$Nombre) {
 $ruta = Join-Path $env:TEMP ('InstalarTodo_' + [guid]::NewGuid().ToString('N') + '.exe')
 try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $Url -OutFile $ruta -UseBasicParsing -TimeoutSec 90 -MaximumRedirection 5
  if ((Get-Item $ruta).Length -lt 10240) { throw 'Descarga demasiado pequena' }
  $firma = Get-AuthenticodeSignature -FilePath $ruta
  if ($firma.Status -ne 'Valid') { throw "Firma digital no valida: $($firma.Status)" }
  Write-Host "Firma verificada para $Nombre : $($firma.SignerCertificate.Subject)"
  return $ruta
 } catch {
  Registrar $Nombre 'FALLO' "Descarga o firma: $_"
  Remove-Item -LiteralPath $ruta -Force -ErrorAction SilentlyContinue
  return $null
 }
}
function Instalar-Exe([string]$Nombre,[string]$Url,[string]$Patron,[string]$Argumentos) {
 if (Test-Instalado $Patron) { Registrar $Nombre 'OMITIDO' 'Ya instalado'; return }
 $ruta = Descargar-Seguro $Url $Nombre
 if (-not $ruta) { return }
 try {
  $proc = Start-Process -FilePath $ruta -ArgumentList $Argumentos -PassThru
  if (-not $proc.WaitForExit(180000)) {
   Registrar $Nombre 'FALLO' 'Tiempo agotado; no se fuerza el cierre del instalador'
   return
  }
  $codigo = $proc.ExitCode
  if ($codigo -in @(3010,1641)) { $script:ReinicioPendiente = $true }
  if (Test-Instalado $Patron) { Registrar $Nombre 'OK' "Instalado (codigo $codigo)" }
  elseif ($codigo -in @(0,3010,1641)) { Registrar $Nombre 'AVISO' "Instalador finalizo ($codigo), pero no aparece en el registro; comprobar manualmente" }
  else { Registrar $Nombre 'FALLO' "Codigo $codigo" }
 } catch { Registrar $Nombre 'FALLO' "$_" }
 finally { Remove-Item -LiteralPath $ruta -Force -ErrorAction SilentlyContinue }
}
function Instalar-ChromeMsi {
 $url = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
 $ruta = Join-Path $env:TEMP ('Chrome_' + [guid]::NewGuid().ToString('N') + '.msi')
 try {
  Invoke-WebRequest -Uri $url -OutFile $ruta -UseBasicParsing -TimeoutSec 90
  if ((Get-AuthenticodeSignature $ruta).Status -ne 'Valid') { throw 'Firma MSI no valida' }
  $p = Start-Process msiexec.exe -ArgumentList "/i `"$ruta`" /qn /norestart" -Wait -PassThru
  if ($p.ExitCode -in @(3010,1641)) { $script:ReinicioPendiente = $true }
  if ($p.ExitCode -in @(0,3010,1641) -and (Test-Instalado 'Google Chrome')) { Registrar 'Google Chrome' 'OK' 'MSI oficial firmado' }
  else { Registrar 'Google Chrome' 'FALLO' "MSI codigo $($p.ExitCode)" }
 } catch { Registrar 'Google Chrome' 'FALLO' "MSI: $_" }
 finally { Remove-Item $ruta -Force -ErrorAction SilentlyContinue }
}
function Configurar-Chromium([string]$Ruta,[string]$Nombre,[string]$Extension) {
 try {
  New-Item $Ruta -Force | Out-Null
  New-Item "$Ruta\RestoreOnStartupURLs" -Force | Out-Null
  New-ItemProperty $Ruta -Name HomepageLocation -Value $PaginaInicio -PropertyType String -Force | Out-Null
  New-ItemProperty $Ruta -Name HomepageIsNewTabPage -Value 0 -PropertyType DWord -Force | Out-Null
  New-ItemProperty $Ruta -Name ShowHomeButton -Value 1 -PropertyType DWord -Force | Out-Null
  New-ItemProperty $Ruta -Name RestoreOnStartup -Value 4 -PropertyType DWord -Force | Out-Null
  New-ItemProperty "$Ruta\RestoreOnStartupURLs" -Name '1' -Value $PaginaInicio -PropertyType String -Force | Out-Null
  if ($Extension) {
   New-Item "$Ruta\ExtensionInstallForcelist" -Force | Out-Null
   New-ItemProperty "$Ruta\ExtensionInstallForcelist" -Name '1' -Value "$Extension;https://clients2.google.com/service/update2/crx" -PropertyType String -Force | Out-Null
  }
  Registrar "Configurar $Nombre" 'OK' 'Politicas aplicadas; comprobar chrome://policy o brave://policy'
 } catch { Registrar "Configurar $Nombre" 'FALLO' "$_" }
}
function Configurar-Firefox {
 $rutas = @("$env:ProgramFiles\Mozilla Firefox", "${env:ProgramFiles(x86)}\Mozilla Firefox")
 $dir = $rutas | Where-Object { $_ -and (Test-Path (Join-Path $_ 'firefox.exe')) } | Select-Object -First 1
 if (-not $dir) { Registrar 'Configurar Firefox' 'AVISO' 'Firefox no encontrado'; return }
 try {
  $distribution = Join-Path $dir 'distribution'
  New-Item $distribution -ItemType Directory -Force | Out-Null
  $archivo = Join-Path $distribution 'policies.json'
  $politicas = @{ policies = @{ Homepage = @{ URL=$PaginaInicio; Locked=$false; StartPage='homepage' }; Extensions = @{ Install = @($ExtensionFirefox) } } }
  # No borrar otras politicas ya existentes: fusionar solo las dos que gestiona este script.
  if (Test-Path $archivo) {
   $existentes = Get-Content $archivo -Raw | ConvertFrom-Json
   if ($existentes.policies) {
    foreach ($prop in $existentes.policies.PSObject.Properties) {
     if ($prop.Name -notin @('Homepage','Extensions')) { $politicas.policies[$prop.Name] = $prop.Value }
    }
   }
  }
  [IO.File]::WriteAllText($archivo,($politicas | ConvertTo-Json -Depth 20),(New-Object Text.UTF8Encoding($false)))
  Registrar 'Configurar Firefox' 'OK' 'Politicas escritas; comprobar about:policies'
 } catch { Registrar 'Configurar Firefox' 'FALLO' "$_" }
}
function Restaurar-Configuracion {
 $copia = Join-Path $PSScriptRoot 'copia_config'
 if (-not (Test-Path $copia -PathType Container)) { Registrar 'Restaurar configuracion' 'OMITIDO' 'No existe copia_config'; return }
 $origen = Join-Path $copia 'Escritorio'
 if (Test-Path $origen -PathType Container) {
  try {
   $destino = [Environment]::GetFolderPath('Desktop')
   if (-not $destino -or -not (Test-Path $destino)) { throw 'No se encuentra escritorio del usuario' }
   $archivos = @(Get-ChildItem -LiteralPath $origen -Force)
   if ($archivos.Count -eq 0) { throw 'Copia del escritorio vacia: no se modifica el destino' }
   $respaldo = Join-Path $script:LogDir ('respaldo_escritorio_{0:yyyyMMdd_HHmmss}' -f (Get-Date))
   New-Item $respaldo -ItemType Directory -Force | Out-Null
   # Guardar copia antes de modificar; nunca borrar elementos personales automaticamente.
   Get-ChildItem -LiteralPath $destino -Force | ForEach-Object {
    if ($_.FullName -ne $PSScriptRoot -and -not $PSScriptRoot.StartsWith($_.FullName + '\',[StringComparison]::OrdinalIgnoreCase)) {
     Copy-Item -LiteralPath $_.FullName -Destination $respaldo -Recurse -Force -ErrorAction Stop
    }
   }
   if ($LimpiarEscritorio) {
    Write-Warning 'Se solicito -LimpiarEscritorio, pero por seguridad no se eliminan archivos: se restauran sin borrar.'
   }
   foreach ($item in $archivos) {
    $dest = Join-Path $destino $item.Name
    if (Test-Path -LiteralPath $dest) {
     Write-Warning "Conflicto en escritorio, se conserva el original: $($item.Name)"
    } else { Copy-Item -LiteralPath $item.FullName -Destination $dest -Recurse -ErrorAction Stop }
   }
   Registrar 'Escritorio' 'OK' "Restaurado sin sobrescribir; respaldo: $respaldo"
  } catch { Registrar 'Escritorio' 'FALLO' "$_" }
 }
 # Restauraciones antiguas de taskbar/start2.bin no son compatibles con todas las builds.
 # Se mantienen opcionales, sin reiniciar explorer ni forzar sobreescritura de perfiles.
 $tbOrigen = Join-Path $copia 'TaskBar'
 if (Test-Path $tbOrigen) {
  try {
   $tb = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
   New-Item $tb -ItemType Directory -Force | Out-Null
   foreach ($item in Get-ChildItem $tbOrigen -Force) {
    $dest = Join-Path $tb $item.Name
    if (-not (Test-Path $dest)) { Copy-Item $item.FullName $dest -Recurse -ErrorAction Stop }
   }
   Registrar 'Barra de tareas' 'AVISO' 'Accesos copiados; Windows puede no restaurar los anclados'
  } catch { Registrar 'Barra de tareas' 'FALLO' "$_" }
 }
 foreach ($archivo in @('taskbar.reg','advanced.reg','start.reg','start2.bin')) {
  if (Test-Path (Join-Path $copia $archivo)) {
   Registrar $archivo 'AVISO' 'No se importa automaticamente: puede sobrescribir ajustes del usuario o ser incompatible con esta version de Windows'
  }
 }
 if ($StartLimpio) {
  try {
   $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   foreach ($kv in @(@('Start_TrackDocs',0),@('Start_TrackProgs',0),@('Start_IrisRecommendations',0))) {
    New-ItemProperty -Path $adv -Name $kv[0] -Value $kv[1] -PropertyType DWord -Force | Out-Null
   }
   Registrar 'Inicio limpio' 'OK' 'Preferencias de recientes aplicadas (segun version de Windows)'
  } catch { Registrar 'Inicio limpio' 'FALLO' "$_" }
 }
}
try {
 if (-not (Es-Admin)) {
  if ($Silencioso) { throw 'El modo silencioso requiere ejecutar como administrador en una sesion de usuario (no SYSTEM).' }
  Write-Host 'Solicitando permisos de administrador...'
  $argsElevados = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"'))
  if ($LimpiarEscritorio) { $argsElevados += '-LimpiarEscritorio' }
  if ($StartLimpio) { $argsElevados += '-StartLimpio' }
  Start-Process powershell.exe -Verb RunAs -ArgumentList $argsElevados -ErrorAction Stop
  exit 0
 }
 if ([Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) { throw 'No ejecutar como SYSTEM: la configuracion de navegadores/escritorio se aplicaria al perfil incorrecto.' }
 if (-not (Esperar-Winget)) { throw 'Winget no disponible. Instalar App Installer desde Microsoft Store y repetir.' }
 foreach ($p in $Programas) { Invocar-Winget $p.Nombre $p.Id $p.Patron }
 # DNIe primero, luego AutoFirma
 Instalar-Exe 'DNIe' $UrlDNIe 'DNIe|DNI electr|Tarjetas DNI' '/silent'
 Invocar-Winget 'AutoFirma' 'SpanishGovernment.Autofirma' 'AutoFirma'
 Instalar-Exe 'aTube Catcher' $UrlATube 'aTube' '/S'
 Configurar-Chromium 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'Chrome' $ExtensionChrome
 Configurar-Chromium 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave' 'Brave' $null
 Configurar-Firefox
 Restaurar-Configuracion
} catch { Registrar 'Ejecucion general' 'FALLO' "$_" }
finally {
 $segundos = [int]((Get-Date)-$script:Inicio).TotalSeconds
 $csv = Join-Path $script:LogDir ('resumen_{0:yyyyMMdd_HHmmss}.csv' -f $script:Inicio)
 $script:Resultados | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
 Write-Host "`n========== RESUMEN =========="
 $script:Resultados | Format-Table -AutoSize | Out-Host
 Write-Host "Tiempo total: $segundos segundos"
 Write-Host "Reinicio pendiente: $script:ReinicioPendiente"
 Write-Host "Log: $script:Log"
 Write-Host "CSV: $csv"
 Write-Host 'Reabre los navegadores para aplicar las politicas. El script NO se autoelimina.'
 if ($script:TranscriptActivo) { Stop-Transcript | Out-Null }
 if (-not $Silencioso -and [Environment]::UserInteractive) { Read-Host 'Pulsa Intro para salir' | Out-Null }
}
if (@($script:Resultados | Where-Object { $_.Estado -eq 'FALLO' }).Count -gt 0) { exit 1 }
exit 0
