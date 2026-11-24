#requires -Version 5.1
<#
 win4win para Windows 10/11
 Uso: .\win4win_motor.ps1 [-Silencioso] [-LimpiarEscritorio] [-StartLimpio]
 IMPORTANTE: ejecutar en la sesion del usuario final (no SYSTEM).
 Los EXE externos solo se ejecutan si tienen firma Authenticode valida.
#>
[CmdletBinding()]
param([switch]$Silencioso, [switch]$LimpiarEscritorio, [switch]$StartLimpio, [string]$RunDir, [switch]$VerificarDescargas)
$ErrorActionPreference = 'Stop'
$PaginaInicio = 'https://www.google.com/'
$ExtensionChrome = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
$ExtensionFirefox = 'https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper/latest.xpi'
$UrlATube = 'https://opera.dsnetwb.com/files/aTube-Catcher-Setup-26.11.20-x64.exe'
$UrlDNIe = 'https://www.dnielectronico.es/descargas/CSP_para_Sistemas_Windows/Windows_64_bits/Instalador_Tarjetas_DNIe_x64.exe'
$Programas = @(
 @{Nombre='Mozilla Firefox';Id='Mozilla.Firefox';Patron='Mozilla Firefox'},
 @{Nombre='Google Chrome';Id='Google.Chrome';Patron='Google Chrome'},
 @{Nombre='Brave';Id='Brave.Brave';Patron='^Brave( Browser)?$'},
 @{Nombre='K-Lite Codec Pack';Id='CodecGuide.K-LiteCodecPack.Standard';Patron='K-Lite Codec Pack'},
 @{Nombre='VLC';Id='VideoLAN.VLC';Patron='VLC media player'},
 @{Nombre='WinRAR';Id='RARLab.WinRAR';Patron='WinRAR'},
 @{Nombre='Adobe Acrobat Reader';Id='Adobe.Acrobat.Reader.64-bit';Patron='^Adobe Acrobat( Reader)?(?: DC)?(?: \(|$)'},
 @{Nombre='PDFgear';Id='PDFgear.PDFgear';Patron='PDFgear'}
)
$script:Resultados = [System.Collections.Generic.List[object]]::new()
$script:ReinicioPendiente = $false
$script:Inicio = Get-Date
$script:LogDir = if ($RunDir) { $RunDir } else { Join-Path (Join-Path $env:LOCALAPPDATA 'win4win\Registros') ([guid]::NewGuid().ToString('N')) }
New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
$script:LogDir = (Resolve-Path -LiteralPath $script:LogDir).ProviderPath
$script:Log = Join-Path $script:LogDir ('instalacion_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
$script:TranscriptActivo = $false
try { Start-Transcript -Path $script:Log -ErrorAction Stop | Out-Null; $script:TranscriptActivo = $true } catch { Write-Warning "No se pudo iniciar transcript: $_" }
function Registrar([string]$Nombre,[string]$Estado,[string]$Detalle='') {
 $script:Resultados.Add([pscustomobject]@{Programa=$Nombre;Estado=$Estado;Detalle=$Detalle})
  $script:Resultados[$script:Resultados.Count - 1] | Export-Csv -LiteralPath (Join-Path $script:LogDir "estado.csv") -Append -NoTypeInformation -Encoding UTF8
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
function Test-Winget {
 try {
  if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { return $false }
  $version = & winget.exe --version
  if ($LASTEXITCODE -ne 0) { return $false }
  Write-Host "WinGet: $version"
  return $true
 } catch {
  Write-Warning "WinGet no disponible: $_"
  return $false
 }
}
function Invocar-Winget([string]$Nombre,[string]$Id,[string]$Patron) {
 if (-not $VerificarDescargas -and (Test-Instalado $Patron)) { Registrar $Nombre 'OMITIDO' 'Ya instalado'; return }
 if (-not $wingetDisponible) {
  if ($Id -eq 'Google.Chrome' -and -not $VerificarDescargas) { Instalar-ChromeMsi }
  else { Registrar $Nombre 'FALLO' 'WinGet no disponible. Revisa App Installer.' }
  return
 }
 if ($VerificarDescargas) {
  $destino = Join-Path $script:LogDir ('descarga_' + [guid]::NewGuid().ToString('N'))
  try {
   New-Item -Path $destino -ItemType Directory | Out-Null
   & winget.exe download --id $Id --exact --source winget --download-directory $destino --skip-dependencies --accept-package-agreements --accept-source-agreements --disable-interactivity
   $codigo = $LASTEXITCODE
   $archivo = Get-ChildItem -LiteralPath $destino -File | Where-Object Extension -NotIn @('.yaml','.yml','.txt') | Select-Object -First 1
   if ($codigo -ne 0 -or -not $archivo) { throw "WinGet: $codigo" }
   Registrar $Nombre 'OK' 'Descarga comprobada por WinGet'
  } catch { Registrar $Nombre 'FALLO' "$_" }
  finally {
   $item = Get-Item -LiteralPath $destino -ErrorAction SilentlyContinue
   if ($item -and $item.FullName -eq [IO.Path]::GetFullPath($destino) -and -not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
   }
  }
  return
 }
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
 if (Test-Instalado $Patron) {
  Registrar $Nombre 'OK' "Winget: $codigo"
 } elseif ($Id -eq 'Google.Chrome') {
  Write-Warning "Chrome: winget devolvio $codigo. Probando MSI oficial..."
  Instalar-ChromeMsi
 } elseif ($codigo -in @(0,3010,1641)) { Registrar $Nombre 'AVISO' "No confirmado; Winget: $codigo" } else { Registrar $Nombre 'FALLO' "Winget: $codigo" }
}
function Descargar-Seguro([uri]$Url,[string]$Nombre,[string]$Tipo = '.exe') {
 $ruta = Join-Path $env:TEMP ('win4win_' + [guid]::NewGuid().ToString('N') + $Tipo)
 try {
  if ($Url.Scheme -ne 'https') { throw 'La descarga requiere HTTPS' }
  $ProgressPreference = 'SilentlyContinue'
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  for ($intento = 1; $intento -le 3; $intento++) {
   try {
    Write-Host "Descarga: $Url (intento $intento)"
    Invoke-WebRequest -Uri $Url -OutFile $ruta -UseBasicParsing -TimeoutSec 300 -MaximumRedirection 5
    break
   } catch {
    $respuesta = $_.Exception.Response
    if ($respuesta -and [int]$respuesta.StatusCode -notin @(408,429,500,502,503,504)) { throw }
    if ($intento -eq 3) { throw }
    Start-Sleep -Seconds (3 * $intento)
   }
  }
  if ((Get-Item $ruta).Length -lt 10240) { throw 'Descarga demasiado pequena' }
  $firma = Get-AuthenticodeSignature -LiteralPath $ruta
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
 if (-not $VerificarDescargas -and (Test-Instalado $Patron)) { Registrar $Nombre 'OMITIDO' 'Ya instalado'; return }
 $ruta = Descargar-Seguro $Url $Nombre
 if (-not $ruta) { return }
 if ($VerificarDescargas) {
  Remove-Item -LiteralPath $ruta -Force
  Registrar $Nombre 'OK' 'Descarga completa con firma válida'
  return
 }
 try {
  $proc = Start-Process -FilePath $ruta -ArgumentList $Argumentos -Wait -PassThru
  try { $codigo = $proc.ExitCode } finally { $proc.Dispose() }
  if ($codigo -in @(3010,1641)) { $script:ReinicioPendiente = $true }
  if ($codigo -in @(0,3010,1641) -and (Test-Instalado $Patron)) { Registrar $Nombre 'OK' "Instalado (codigo $codigo)" }
  elseif ($codigo -in @(0,3010,1641)) { Registrar $Nombre 'AVISO' "Instalador finalizo ($codigo), pero no aparece en el registro; comprobar manualmente" }
  else { Registrar $Nombre 'FALLO' "Codigo $codigo" }
 } catch { Registrar $Nombre 'FALLO' "$_" }
 finally { Remove-Item -LiteralPath $ruta -Force -ErrorAction SilentlyContinue }
}
function Instalar-ChromeMsi {
 $url = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
 $ruta = Descargar-Seguro $url 'Google Chrome (MSI)' '.msi'
 if (-not $ruta) { return }
 if ($VerificarDescargas) {
  Remove-Item -LiteralPath $ruta -Force
  Registrar 'Google Chrome (MSI)' 'OK' 'Descarga completa con firma válida'
  return
 }
 try {
  $p = Start-Process (Join-Path $env:WINDIR 'System32\msiexec.exe') -ArgumentList "/i `"$ruta`" /qn /norestart" -Wait -PassThru
  try { $codigo = $p.ExitCode } finally { $p.Dispose() }
  if ($codigo -in @(3010,1641)) { $script:ReinicioPendiente = $true }
  if ($codigo -in @(0,3010,1641) -and ((Test-Instalado 'Google Chrome') -or (Test-Path "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe") -or (Test-Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"))) { Registrar 'Google Chrome' 'OK' 'MSI oficial firmado' }
  else { Registrar 'Google Chrome' 'FALLO' "MSI codigo $codigo" }
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
 if (-not $StartLimpio -and -not (Test-Path $copia -PathType Container)) { Registrar 'Restaurar configuracion' 'OMITIDO' 'No existe copia_config'; return }
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
 if (Test-Path -LiteralPath $tbOrigen -PathType Container) {
  try {
   $tb = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
   New-Item $tb -ItemType Directory -Force | Out-Null
   foreach ($item in Get-ChildItem -LiteralPath $tbOrigen -Force) {
    $dest = Join-Path $tb $item.Name
    if (-not (Test-Path $dest)) { Copy-Item -LiteralPath $item.FullName -Destination $dest -Recurse -ErrorAction Stop }
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
 if (-not $VerificarDescargas -and -not (Es-Admin)) {
  if ($Silencioso) { throw 'El modo silencioso requiere ejecutar como administrador en una sesion de usuario (no SYSTEM).' }
  Write-Host 'Solicitando permisos de administrador...'
  $argsElevados = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"'))
  if ($LimpiarEscritorio) { $argsElevados += '-LimpiarEscritorio' }
  if ($StartLimpio) { $argsElevados += '-StartLimpio' }
  if ($RunDir) { $argsElevados += @('-RunDir', ('"' + $script:LogDir + '"')) }
  Start-Process (Join-Path $PSHOME 'powershell.exe') -Verb RunAs -ArgumentList $argsElevados -ErrorAction Stop
  exit 0
 }
 if ([Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) { throw 'No ejecutar como SYSTEM: la configuracion de navegadores/escritorio se aplicaria al perfil incorrecto.' }
 $wingetDisponible = Test-Winget
 foreach ($p in $Programas) { Invocar-Winget $p.Nombre $p.Id $p.Patron }
 # DNIe primero, luego AutoFirma
 Instalar-Exe 'DNIe' $UrlDNIe 'DNIe|DNI electr|Tarjetas DNI' '/silent'
 # El middleware DNIe puede no registrarse con ese nombre; avisar y no declarar exito sin prueba.
 if (-not $VerificarDescargas -and -not (Test-Instalado 'DNIe|DNI electr|Tarjetas DNI')) { Write-Warning 'DNIe no confirmado. Revisar log, firma, codigo de salida y Panel de control > Programas.' }
 Invocar-Winget 'AutoFirma' 'SpanishGovernment.Autofirma' 'AutoFirma'
 Instalar-Exe 'aTube Catcher' $UrlATube 'aTube' '/S'
 if ($VerificarDescargas) {
  Instalar-ChromeMsi
  $xpi = Join-Path $script:LogDir 'video-downloadhelper.xpi'
  try {
   $ProgressPreference = 'SilentlyContinue'
   Invoke-WebRequest -Uri $ExtensionFirefox -UseBasicParsing -OutFile $xpi -TimeoutSec 60
   Add-Type -AssemblyName System.IO.Compression.FileSystem
   $archivo = [IO.Compression.ZipFile]::OpenRead($xpi)
   try { if (-not $archivo.GetEntry('manifest.json')) { throw 'XPI sin manifiesto' } }
   finally { $archivo.Dispose() }
   Registrar 'Extensión Firefox' 'OK' 'XPI descargado y legible'
  } catch { Registrar 'Extensión Firefox' 'FALLO' "$_" }
  finally { Remove-Item -LiteralPath $xpi -Force -ErrorAction SilentlyContinue }
  $crx = Join-Path $script:LogDir 'ublock-origin-lite.crx'
  try {
   $consulta = [uri]::EscapeDataString("id=$ExtensionChrome&uc")
   $url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=140.0.0.0&acceptformat=crx3&x=$consulta"
   Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $crx -TimeoutSec 60
   $archivo = [IO.File]::OpenRead($crx)
   try {
    $cabecera = New-Object byte[] 4
    if ($archivo.Read($cabecera, 0, 4) -ne 4 -or [Text.Encoding]::ASCII.GetString($cabecera) -ne 'Cr24') {
     throw 'La respuesta de Chrome Web Store no es un CRX.'
    }
   } finally { $archivo.Dispose() }
   Registrar 'Extensión Chrome' 'OK' 'CRX descargado y legible'
  } catch { Registrar 'Extensión Chrome' 'FALLO' "$_" }
  finally { Remove-Item -LiteralPath $crx -Force -ErrorAction SilentlyContinue }
 } else {
 Configurar-Chromium 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'Chrome' $ExtensionChrome
 Configurar-Chromium 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave' 'Brave' $null
 Configurar-Firefox
 Restaurar-Configuracion
 }
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
 if (-not $Silencioso -and -not $VerificarDescargas -and [Environment]::UserInteractive) { Read-Host 'Pulsa Intro para salir' | Out-Null }
}
if (@($script:Resultados | Where-Object { $_.Estado -eq 'FALLO' }).Count -gt 0) { exit 1 }
if (@($script:Resultados | Where-Object Estado -eq 'AVISO').Count) {
 if ($script:ReinicioPendiente) { exit 4 }
 exit 2
}
if ($script:ReinicioPendiente) { exit 3 }
exit 0

