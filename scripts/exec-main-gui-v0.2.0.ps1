#requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:LOCALAPPDATA 'win4win\Registros'
$worker = Join-Path $PSScriptRoot 'exec-main-motorv0.2.0.ps1'
$powershell = Join-Path $PSHOME 'powershell.exe'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        $launch = '-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $PSCommandPath
        Start-Process -FilePath $powershell -Verb RunAs -ArgumentList $launch
    } catch {
        [void][Windows.Forms.MessageBox]::Show('Se necesitan permisos de administrador para instalar.', 'win4win')
    }
    return
}

$form = New-Object Windows.Forms.Form
$form.Text = 'win4win'
$form.ClientSize = New-Object Drawing.Size(540, 250)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.AutoScaleMode = 'Dpi'
$form.BackColor = [Drawing.Color]::FromArgb(246, 248, 252)
$form.ForeColor = [Drawing.Color]::FromArgb(23, 37, 61)
$form.Font = New-Object Drawing.Font('Segoe UI', 11)

function New-Label($caption, $top, $height, $size) {
    $control = New-Object Windows.Forms.Label
    $control.Text = $caption
    $control.SetBounds(28, $top, 484, $height)
    $control.Font = New-Object Drawing.Font('Segoe UI', $size)
    $form.Controls.Add($control)
    return $control
}

function New-Button($caption, $left, $width) {
    $control = New-Object Windows.Forms.Button
    $control.Text = $caption
    $control.SetBounds($left, 180, $width, 46)
    $form.Controls.Add($control)
    return $control
}

$title = New-Label 'win4win' 20 56 30
$status = New-Label 'Listo para instalar y configurar las aplicaciones.' 89 44 12
$bar = New-Object Windows.Forms.ProgressBar
$bar.SetBounds(28, 142, 484, 9)
$bar.AccessibleName = 'Progreso de la instalación'
$form.Controls.Add($bar)
$start = New-Button 'Iniciar instalación' 28 230
$start.FlatStyle = 'Flat'
$start.FlatAppearance.BorderSize = 0
$start.BackColor = [Drawing.Color]::FromArgb(35, 77, 163)
$start.ForeColor = [Drawing.Color]::White
$open = New-Button 'Abrir registros' 282 230
$form.AcceptButton = $start

$script:process = $null
$script:run = $null
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 750

$start.Add_Click({
    try {
        $script:run = Join-Path $root ('{0:yyyyMMdd_HHmmss}_{1}' -f (Get-Date), [guid]::NewGuid().ToString('N'))
        New-Item -Path $script:run -ItemType Directory -Force | Out-Null
        $argsWorker = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}" -Silencioso -RunDir "{1}"' -f $worker, $script:run
        $script:process = Start-Process -FilePath $powershell -ArgumentList $argsWorker -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $script:run 'salida.txt') -RedirectStandardError (Join-Path $script:run 'errores.txt')
        $start.Enabled = $false
        $bar.Value = 0
        $bar.Style = 'Marquee'
        $status.Text = 'Instalación en curso…'
        $timer.Start()
    } catch {
        $status.Text = 'No se pudo iniciar. Consulta los registros.'
        if ($script:run -and (Test-Path -LiteralPath $script:run)) {
            $_ | Out-String | Set-Content -LiteralPath (Join-Path $script:run 'inicio-error.txt') -Encoding UTF8
        }
    }
})

$timer.Add_Tick({
    if (-not $script:process.HasExited) { return }
    $timer.Stop()
    $code = $script:process.ExitCode
    $script:process.Dispose()
    $script:process = $null
    $bar.Style = 'Continuous'
    $bar.Value = 100
    $status.Text = switch ($code) {
        0 { 'Instalación completada.' }
        2 { 'Instalación completada con avisos. Consulta los registros.' }
        3 { 'Instalación completada. Reinicia Windows.' }
        4 { 'Instalación con avisos. Consulta los registros y reinicia Windows.' }
        default { 'La instalación terminó con errores. Consulta los registros.' }
    }
    $start.Enabled = $true
})

$open.Add_Click({
    try {
        $folder = if ($script:run -and (Test-Path -LiteralPath $script:run)) { $script:run } else { $root }
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Start-Process -FilePath (Join-Path $env:WINDIR 'explorer.exe') -ArgumentList ('"{0}"' -f $folder)
    } catch {
        [void][Windows.Forms.MessageBox]::Show('No se pudo abrir la carpeta de registros.', 'win4win')
    }
})

$form.Add_FormClosing({
    param($sender, $eventArgs)
    if ($script:process -and -not $script:process.HasExited) {
        $eventArgs.Cancel = $true
        $status.Text = 'Espera a que termine la instalación antes de cerrar.'
    }
})

try {
    [void]$form.ShowDialog()
} finally {
    $timer.Dispose()
    if ($script:process) { $script:process.Dispose() }
    $form.Dispose()
}


