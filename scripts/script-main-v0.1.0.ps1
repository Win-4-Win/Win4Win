# ============================================================
#  Instalador automatico + configuracion de navegadores
#  Windows 10/11 con winget
# ============================================================
#  -Silencioso : modo sin pausas ni avisos, pensado para ejecutarse solo
#                (por ejemplo desde una tarea programada tras instalar Windows).
#                Al terminar se elimina a si mismo.
# ============================================================
param([switch]$Silencioso)

# --- Auto-elevar a Administrador ---
$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin -and -not $Silencioso) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# --- Registro de lo que ocurre (util si algo falla) ---
$log = if ($Silencioso) { Join-Path $env:ProgramData "instalacion.log" } else { Join-Path $PSScriptRoot "instalacion.log" }
Start-Transcript -Path $log -Force | Out-Null

# --- En modo silencioso, esperar a que haya red y winget (recien instalado Windows tardan) ---
if ($Silencioso) {
    Write-Host "Esperando red y winget (hasta 20 minutos)..."
    $limite = (Get-Date).AddMinutes(20)
    $registrado = $false
    while ((Get-Date) -lt $limite) {
        $red = $false
        try { $red = (Invoke-WebRequest "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200 } catch { }
        if (-not (Get-Command winget -ErrorAction SilentlyContinue) -and -not $registrado) {
            # Intenta registrar App Installer (trae winget) para el usuario actual
            Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
            $registrado = $true
        }
        if ($red -and (Get-Command winget -ErrorAction SilentlyContinue)) { break }
        Start-Sleep -Seconds 15
    }
}

# --- Comprobar winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget no esta instalado. Instala 'App Installer' desde Microsoft Store y vuelve a ejecutar." -ForegroundColor Red
    Stop-Transcript | Out-Null
    if (-not $Silencioso) { pause }
    exit 1
}

# ================== CONFIGURACION ==================
$PaginaInicio = "https://www.google.com/"
$StartLimpio = $false  # $true = Inicio solo con apps ancladas (sin recomendados ni recientes)
$LimpiarEscritorio = $true   # $true = vaciar el Escritorio (a la Papelera) antes de restaurar la copia
$ExtensionChrome = "ddkjiahejlhfcafbddmgiahcphecmpfh"   # uBlock Origin Lite (solo Chrome)
$ExtensionFirefox = "https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper/latest.xpi"   # Video DownloadHelper (solo Firefox)
# ===================================================

$programas = @(
    @{ Nombre = "Mozilla Firefox";      Id = "Mozilla.Firefox" },
    @{ Nombre = "Google Chrome";        Id = "Google.Chrome" },
    @{ Nombre = "Brave";                Id = "Brave.Brave" },
    @{ Nombre = "K-Lite Codec Pack";    Id = "CodecGuide.K-LiteCodecPack.Standard" },
    @{ Nombre = "VLC";                  Id = "VideoLAN.VLC" },
    @{ Nombre = "WinRAR";               Id = "RARLab.WinRAR" },
    @{ Nombre = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit" },
    @{ Nombre = "PDFgear";              Id = "PDFgear.PDFgear" }
)

# aTube Catcher y DNIe se descargan de estos enlaces
$UrlATube = "https://opera.dsnetwb.com/files/aTube-Catcher-Setup-26.8.20-x64.exe"
$UrlDNIe = "https://www.dnielectronico.es/descargas/CSP_para_Sistemas_Windows/Windows_64_bits/Instalador_Tarjetas_DNIe_x64.exe"

$fallidos = @()

function Instalar-Id($nombre, $id) {
    Write-Host "`n>>> Instalando $nombre ..." -ForegroundColor Cyan
    # Errores de red de Windows (no se pudo conectar, DNS, tiempo agotado...): se reintenta hasta 3 veces
    $erroresRed = @(-2147012867, -2147012889, -2147012894, -2147012866, -2147012865)
    for ($intento = 1; $intento -le 3; $intento++) {
        winget install --id $id -e --source winget --silent `
            --accept-package-agreements --accept-source-agreements --disable-interactivity
        $codigo = $LASTEXITCODE
        if ($erroresRed -notcontains $codigo) { break }
        if ($intento -lt 3) {
            Write-Host "    Error de red. Reintentando en 15 segundos ($intento/3)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 15
        }
    }

    # Error -1978335215 = el hash del instalador no coincide con el del catalogo de winget
    # (pasa con Chrome cuando Google actualiza el instalador antes que winget).
    # Se instala entonces desde el MSI oficial de Google, que no depende de winget.
    if ($codigo -eq -1978335215 -and $id -eq "Google.Chrome") {
        Write-Host "    El hash no coincide. Instalando Chrome desde el MSI oficial de Google..." -ForegroundColor Yellow
        if (Instalar-ChromeMsi) { $codigo = 0 }
    }

    if ($codigo -ne 0 -and $codigo -ne -1978335189) {
        Write-Host "    [FALLO] $nombre (codigo $codigo)" -ForegroundColor Red
        $script:fallidos += $nombre
    } else {
        Write-Host "    [OK] $nombre" -ForegroundColor Green
    }
}

function Instalar-ChromeMsi {
    $msi = Descargar "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
    if (-not $msi) { return $false }
    $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
    Remove-Item $msi -Force -ErrorAction SilentlyContinue
    return (($p.ExitCode -eq 0) -or ($p.ExitCode -eq 3010))
}

function Test-Instalado($patron) {
    $claves = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*")
    $r = Get-ItemProperty $claves -ErrorAction SilentlyContinue |
         Where-Object { $_.DisplayName -match $patron }
    return [bool]$r
}

# Instala un .exe: prueba modos silenciosos y, si ninguno funciona,
# abre el asistente y pulsa "Acepto"/"Siguiente" automaticamente.
function Instalar-Auto($nombre, $ruta, $modos, $patron, $ayuda) {
    Write-Host "`n>>> Instalando $nombre ..." -ForegroundColor Cyan
    if (-not (Test-Path $ruta)) {
        Write-Host "    [FALLO] No se encuentra $ruta" -ForegroundColor Red
        $script:fallidos += "$nombre (falta $ruta)"
        return
    }
    if (Test-Instalado $patron) {
        Write-Host "    [OK] $nombre ya estaba instalado" -ForegroundColor Green
        return
    }

    # --- Fase 1: modos silenciosos (90 s maximo cada uno) ---
    foreach ($modo in $modos) {
        Write-Host "    Probando modo silencioso: $modo"
        $proc = Start-Process -FilePath $ruta -ArgumentList $modo -PassThru
        if (-not $proc.WaitForExit(90000)) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            continue
        }
        Start-Sleep -Seconds 3
        if (($proc.ExitCode -eq 0) -or ($proc.ExitCode -eq 3010) -or (Test-Instalado $patron)) {
            Write-Host "    [OK] $nombre instalado en modo silencioso ($modo)" -ForegroundColor Green
            return
        }
    }

    # --- Fase 2: automatizar el asistente ---
    Write-Host "    Sin modo silencioso. Automatizando el asistente (no toques el teclado)..." -ForegroundColor Yellow
    $wsh = New-Object -ComObject WScript.Shell
    $proc = Start-Process -FilePath $ruta -PassThru
    $limite = (Get-Date).AddMinutes(5)
    Start-Sleep -Seconds 5
    while (-not $proc.HasExited -and (Get-Date) -lt $limite) {
        [void]$wsh.AppActivate($proc.Id)
        Start-Sleep -Milliseconds 700
        $wsh.SendKeys("%a")        # Alt+A = "Acepto"
        Start-Sleep -Milliseconds 400
        $wsh.SendKeys("{ENTER}")   # Siguiente / Instalar / Finalizar
        Start-Sleep -Seconds 4
    }
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }

    Start-Sleep -Seconds 3
    if (Test-Instalado $patron) {
        Write-Host "    [OK] $nombre instalado automatizando el asistente" -ForegroundColor Green
    } else {
        Write-Host "    [FALLO] ${nombre}: no se pudo confirmar la instalacion" -ForegroundColor Red
        $script:fallidos += "$nombre ($ayuda)"
    }
}

function Descargar($url) {
    $destino = Join-Path $env:TEMP ([IO.Path]::GetFileName($url))
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $destino -UseBasicParsing
        return $destino
    } catch {
        Write-Host "    [FALLO] No se pudo descargar: $_" -ForegroundColor Red
        return $null
    }
}

# ================== 1) INSTALACION ==================
foreach ($p in $programas) { Instalar-Id $p.Nombre $p.Id }
# DNIe antes que AutoFirma (AutoFirma lo necesita para leer el DNI)
if (Test-Instalado "DNIe|DNI electr|Tarjetas DNI") {
    Write-Host "`n>>> DNIe ya estaba instalado (omitido)" -ForegroundColor Green
} else {
    $exeDNIe = Descargar $UrlDNIe
    if ($exeDNIe) {
        Instalar-Auto "DNIe" $exeDNIe @('/silent') "DNIe|DNI electr|Tarjetas DNI" "instalalo a mano desde $UrlDNIe"
        Remove-Item $exeDNIe -Force -ErrorAction SilentlyContinue
    } else {
        $fallidos += "DNIe (descarga: $UrlDNIe)"
    }
}
Instalar-Id "AutoFirma" "SpanishGovernment.Autofirma"

# aTube Catcher: si ya esta instalado no se descarga ni se instala
if (Test-Instalado "aTube") {
    Write-Host "`n>>> aTube Catcher ya estaba instalado (omitido)" -ForegroundColor Green
} else {
    $exeATube = Descargar $UrlATube
    if ($exeATube) {
        Instalar-Auto "aTube Catcher" $exeATube @('/S') "aTube" "instalalo a mano desde $UrlATube"
        Remove-Item $exeATube -Force -ErrorAction SilentlyContinue
    } else {
        $fallidos += "aTube Catcher (descarga: $UrlATube)"
    }
}

# ================== 2) CONFIGURACION DE NAVEGADORES ==================
Write-Host "`n=== Configurando navegadores ===" -ForegroundColor White

function Configurar-Chromium($rutaPolitica, $nombre, $extension) {
    Write-Host ">>> Configurando $nombre ..." -ForegroundColor Cyan
    New-Item -Path $rutaPolitica -Force | Out-Null

    Set-ItemProperty -Path $rutaPolitica -Name "HomepageLocation"     -Value $PaginaInicio -Type String
    Set-ItemProperty -Path $rutaPolitica -Name "HomepageIsNewTabPage" -Value 0 -Type DWord
    Set-ItemProperty -Path $rutaPolitica -Name "ShowHomeButton"       -Value 1 -Type DWord
    Set-ItemProperty -Path $rutaPolitica -Name "RestoreOnStartup"     -Value 4 -Type DWord
    $rutaStartup = "$rutaPolitica\RestoreOnStartupURLs"
    New-Item -Path $rutaStartup -Force | Out-Null
    Set-ItemProperty -Path $rutaStartup -Name "1" -Value $PaginaInicio -Type String

    if ($extension) {
        $rutaExt = "$rutaPolitica\ExtensionInstallForcelist"
        New-Item -Path $rutaExt -Force | Out-Null
        Set-ItemProperty -Path $rutaExt -Name "1" -Value "$extension;https://clients2.google.com/service/update2/crx" -Type String
    } else {
        # Sin extension: elimina la lista forzada de ejecuciones anteriores
        Remove-Item -Path "$rutaPolitica\ExtensionInstallForcelist" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "    [OK] $nombre" -ForegroundColor Green
}

# Chrome: pagina de inicio + uBlock Origin Lite
Configurar-Chromium "HKLM:\SOFTWARE\Policies\Google\Chrome" "Google Chrome" $ExtensionChrome
# Brave: solo pagina de inicio (sin extensiones)
Configurar-Chromium "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "Brave" $null

# Firefox: pagina de inicio + Video DownloadHelper
$rutaFirefox = $null
foreach ($r in @("C:\Program Files\Mozilla Firefox", "C:\Program Files (x86)\Mozilla Firefox")) {
    if (Test-Path $r) { $rutaFirefox = $r; break }
}
if ($rutaFirefox) {
    Write-Host ">>> Configurando Firefox ..." -ForegroundColor Cyan
    $carpeta = Join-Path $rutaFirefox "distribution"
    New-Item -Path $carpeta -ItemType Directory -Force | Out-Null
    $politicas = @{ policies = @{
        Homepage   = @{ URL = $PaginaInicio; Locked = $false; StartPage = "homepage" }
        Extensions = @{ Install = @($ExtensionFirefox) }
    } }
    $json = $politicas | ConvertTo-Json -Depth 6
    [IO.File]::WriteAllText((Join-Path $carpeta "policies.json"), $json, (New-Object Text.UTF8Encoding($false)))
    Write-Host "    [OK] Firefox" -ForegroundColor Green
} else {
    Write-Host ">>> Firefox no encontrado (omitido)" -ForegroundColor Yellow
}

# ================== 3) BARRA DE TAREAS, INICIO Y ESCRITORIO ==================
# Se restauran desde la carpeta "copia_config" (creada con copia_configuracion.ps1
# en el otro ordenador). Si la carpeta no existe, este paso se omite.
$copia = Join-Path $PSScriptRoot "copia_config"
if (Test-Path $copia) {
    Write-Host "`n=== Restaurando barra de tareas, inicio y escritorio ===" -ForegroundColor White
    try {
        # Escritorio
        if (Test-Path "$copia\Escritorio") {
            if ($LimpiarEscritorio) {
                Add-Type -AssemblyName Microsoft.VisualBasic
                $escritorioActual = [Environment]::GetFolderPath("Desktop")
                $aBorrar = Get-ChildItem -LiteralPath $escritorioActual -Force | Where-Object {
                    $r = $_.FullName
                    -not ($_.Name -ieq "desktop.ini" -or $_.Name -like "instalar_todo.*" -or
                          $_.Name -like "copia_config*" -or
                          $_.Name -ieq "instalacion.log" -or $r -eq $PSScriptRoot -or
                          $PSScriptRoot.StartsWith($r + "\", [StringComparison]::OrdinalIgnoreCase))
                }
                foreach ($item in $aBorrar) {
                    try {
                        if ($item.PSIsContainer) {
                            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($item.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        } else {
                            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($item.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        }
                    } catch {
                        Write-Host "    [AVISO] No se pudo borrar: $($item.Name)" -ForegroundColor Yellow
                    }
                }
                Write-Host "    [OK] Escritorio vaciado (enviado a la Papelera)" -ForegroundColor Green
            }
            Copy-Item "$copia\Escritorio\*" ([Environment]::GetFolderPath("Desktop")) -Recurse -Force
            Write-Host "    [OK] Escritorio" -ForegroundColor Green
        }
        # Barra de tareas: accesos anclados + registro
        if (Test-Path "$copia\TaskBar") {
            $tb = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
            New-Item -Path $tb -ItemType Directory -Force | Out-Null
            Copy-Item "$copia\TaskBar\*" $tb -Recurse -Force
        }
        if (Test-Path "$copia\taskbar.reg") {
            reg import "$copia\taskbar.reg" | Out-Null
            Write-Host "    [OK] Barra de tareas" -ForegroundColor Green
        }
        # Inicio (Windows 11)
        if (Test-Path "$copia\start2.bin") {
            $ls = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
            New-Item -Path $ls -ItemType Directory -Force | Out-Null
            Copy-Item "$copia\start2.bin" "$ls\start2.bin" -Force
            Write-Host "    [OK] Inicio" -ForegroundColor Green
        }
        # Ajustes del menu Inicio copiados del otro equipo (recomendados, recientes...)
        foreach ($f in @("advanced.reg", "start.reg")) {
            if (Test-Path "$copia\$f") { reg import "$copia\$f" 2>$null | Out-Null }
        }
        if (Test-Path "$copia\advanced.reg") { Write-Host "    [OK] Ajustes del menu Inicio" -ForegroundColor Green }

        # Inicio limpio: solo apps ancladas, sin recomendados ni recientes
        if ($StartLimpio) {
            $adv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty -Path $adv -Name "Start_Layout"            -Value 1 -Type DWord   # mas apps ancladas, menos recomendados
            Set-ItemProperty -Path $adv -Name "Start_TrackDocs"         -Value 0 -Type DWord   # no mostrar archivos recientes
            Set-ItemProperty -Path $adv -Name "Start_TrackProgs"        -Value 0 -Type DWord   # no mostrar apps mas usadas
            Set-ItemProperty -Path $adv -Name "Start_IrisRecommendations" -Value 0 -Type DWord # sin sugerencias y consejos
            $pol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
            New-Item -Path $pol -Force | Out-Null
            Set-ItemProperty -Path $pol -Name "HideRecentlyAddedApps" -Value 1 -Type DWord      # ocultar apps anadidas recientemente
            Write-Host "    [OK] Inicio limpio (sin recomendados ni recientes)" -ForegroundColor Green
        }
        # Reiniciar el Explorador para aplicar los cambios (Windows lo vuelve a abrir solo)
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "    [FALLO] Restaurando configuracion: $_" -ForegroundColor Red
        $fallidos += "Barra de tareas / Inicio / Escritorio"
    }
} else {
    Write-Host "`n(No hay carpeta copia_config: se omite barra de tareas, inicio y escritorio)" -ForegroundColor DarkGray
}

# ================== 4) BRAVE: abrir Google al iniciar (las politicas de inicio se ignoran en equipos no administrados) ==================
# Se usan preferencias iniciales, un primer arranque en segundo plano y el argumento en los accesos directos.
function Poner-UrlEnAccesos($exeNombre, $url) {
    $sitios = @(
        @{ Ruta = [Environment]::GetFolderPath("Desktop");          Recursivo = $false },
        @{ Ruta = [Environment]::GetFolderPath("CommonDesktopDirectory"); Recursivo = $false },
        @{ Ruta = [Environment]::GetFolderPath("Programs");         Recursivo = $true },
        @{ Ruta = [Environment]::GetFolderPath("CommonPrograms");   Recursivo = $true },
        @{ Ruta = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"; Recursivo = $false }
    )
    $wsh = New-Object -ComObject WScript.Shell
    $cambiados = 0
    foreach ($sitio in $sitios) {
        if (-not (Test-Path $sitio.Ruta)) { continue }
        $archivos = Get-ChildItem -LiteralPath $sitio.Ruta -Filter *.lnk -Recurse:$sitio.Recursivo -ErrorAction SilentlyContinue
        foreach ($archivo in $archivos) {
            try {
                $lnk = $wsh.CreateShortcut($archivo.FullName)
                if ($lnk.TargetPath -like "*\$exeNombre" -and $lnk.Arguments -notlike "*$url*") {
                    $lnk.Arguments = ($lnk.Arguments + " " + $url).Trim()
                    $lnk.Save()
                    $cambiados++
                }
            } catch { }
        }
    }
    Write-Host "    [OK] $exeNombre : $cambiados acceso(s) directo(s) abren $url" -ForegroundColor Green
}

# Ademas: preferencias iniciales del navegador (se aplican al crearse el perfil la primera vez).
# Este metodo no usa politicas, asi que no lo bloquea Windows. Solo vale si el navegador
# todavia no se ha abierto nunca en este equipo.
function Poner-PrefsIniciales($carpetas, $nombre, $url) {
    $app = $carpetas | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $app) { Write-Host "    [AVISO] $nombre no encontrado, sin preferencias iniciales" -ForegroundColor Yellow; return $null }
    $prefs = @{
        homepage = $url
        homepage_is_newtabpage = $false
        browser = @{ show_home_button = $true }
        session = @{ restore_on_startup = 4; startup_urls = @($url) }
    }
    $json = $prefs | ConvertTo-Json -Depth 6
    foreach ($archivo in @("initial_preferences", "master_preferences")) {
        [IO.File]::WriteAllText((Join-Path $app $archivo), $json, (New-Object Text.UTF8Encoding($false)))
    }
    Write-Host "    [OK] $nombre : preferencias iniciales escritas" -ForegroundColor Green
    return $app
}

# Abre el navegador una vez en segundo plano para que cree su perfil ya con esas preferencias,
# lo cierra y comprueba que Google ha quedado como pagina de inicio.
function Primer-Arranque($appDir, $exeNombre, $nombre, $carpetaPerfil, $url) {
    if (-not $appDir) { return }
    $exe = Join-Path $appDir $exeNombre
    $prefs = Join-Path $carpetaPerfil "Default\Preferences"
    if (Test-Path $prefs) {
        Write-Host "    [AVISO] $nombre ya tiene perfil: no se hace el primer arranque (las preferencias iniciales no se aplicaran)." -ForegroundColor Yellow
        return
    }
    Write-Host ">>> Primer arranque de $nombre en segundo plano ..." -ForegroundColor Cyan
    # Se lanza con explorer.exe para que se abra sin permisos de administrador
    Start-Process explorer.exe -ArgumentList "`"$exe`""
    Start-Sleep -Seconds 20
    Get-Process | Where-Object { $_.Path -eq $exe } | ForEach-Object { [void]$_.CloseMainWindow() }
    Start-Sleep -Seconds 5
    Get-Process | Where-Object { $_.Path -eq $exe } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # Comprobacion
    if (Test-Path $prefs) {
        try {
            $j = Get-Content $prefs -Raw | ConvertFrom-Json
            if (($j.homepage -eq $url) -or ($j.session.startup_urls -contains $url)) {
                Write-Host "    [OK] $nombre abre $url al iniciar" -ForegroundColor Green
            } else {
                Write-Host "    [AVISO] $nombre no aplico la pagina de inicio (queda el acceso directo como respaldo)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    [AVISO] No se pudo leer el perfil de $nombre" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    [AVISO] $nombre no creo el perfil" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Preferencias iniciales de Brave ===" -ForegroundColor White
$appBrave = Poner-PrefsIniciales @("C:\Program Files\BraveSoftware\Brave-Browser\Application",
                                   "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application",
                                   "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application") "Brave" $PaginaInicio
Primer-Arranque $appBrave  "brave.exe"  "Brave"  "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data" $PaginaInicio

Write-Host "`n=== Accesos directos de Brave ===" -ForegroundColor White
Poner-UrlEnAccesos "brave.exe"  $PaginaInicio

# ================== RESUMEN ==================
Write-Host "`n================ RESUMEN ================" -ForegroundColor White
if ($fallidos.Count -eq 0) {
    Write-Host "Todo se instalo correctamente." -ForegroundColor Green
} else {
    Write-Host "Estos programas hay que instalarlos a mano:" -ForegroundColor Yellow
    $fallidos | ForEach-Object { Write-Host "  - $_" }
    Write-Host "`nDescargas oficiales:"
    Write-Host "  AutoFirma:      https://firmaelectronica.gob.es/Home/Descargas.html"
    Write-Host "  DNIe:           $UrlDNIe"
    Write-Host "  aTube Catcher:  https://opera.dsnetwb.com/files/aTube-Catcher-Setup-26.8.20-x64.exe"
}
Write-Host "`nCierra y vuelve a abrir los navegadores para aplicar los cambios."
Write-Host "Registro guardado en: $log"
Stop-Transcript | Out-Null

if ($Silencioso) {
    # Autoeliminacion: borra la tarea programada, SetupComplete.cmd y la carpeta del script.
    # Se hace desde un cmd aparte que espera a que este script termine.
    Remove-Item "$env:WINDIR\Setup\Scripts\SetupComplete.cmd" -Force -ErrorAction SilentlyContinue
    $orden = "ping -n 11 127.0.0.1 >nul & schtasks /delete /tn InstalarTodo /f & rmdir /s /q `"$PSScriptRoot`""
    Start-Process cmd.exe -ArgumentList "/c $orden" -WindowStyle Hidden
} else {
    pause
}
