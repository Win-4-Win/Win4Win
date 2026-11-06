---
name: script-powershell-instalador
description: "Use when se crea o modifica un script PowerShell/bat del instalador de Windows 11: winget, instalación silenciosa, configuración de programas, drivers, Windows Update, limpieza, arranque, políticas de navegador, idempotencia, logs, seguridad."
---

# Scripts del instalador

Antes de editar, lee [docs/SCRIPTS.md](../../../docs/SCRIPTS.md) y `script/instalar_todo.ps1` y sigue su estilo.

## Orden de fases (buenas prácticas)
Instalar/actualizar programas (`winget upgrade`) → configurar programas → personalizar entorno → arranque, limpieza y optimización de disco. Drivers y Windows Update quedan fuera del alcance (los gestiona Windows).

## Reglas
- Auto-elevar a administrador y registrar con `Start-Transcript`.
- **Idempotente**: se puede ejecutar dos veces sin romper nada (comprobar si ya está instalado).
- Preferir `winget --id <ID> -e --silent --accept-package-agreements --accept-source-agreements`; verificar el ID con `winget search` antes de usarlo.
- Descargas solo de fuentes oficiales por HTTPS; verificar hash si es posible. Sin secretos ni rutas personales en el código.
- Configuración de navegadores mediante políticas (registro / `policies.json`), no tocando perfiles.
- Acciones destructivas (vaciar escritorio, borrar archivos) con confirmación y opción de desactivarlas.
- Recoger fallos en una lista y mostrar un resumen final; un fallo no debe abortar todo.
- No incluir activadores ni cracks (ver AGENTS.md).
- Probar en una máquina virtual de Windows 11, nunca directamente en un equipo real.
- Al terminar, actualizar `docs/SCRIPTS.md` (estado frente al alcance) y usar la skill `registrar-hito`.
