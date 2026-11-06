---
name: anadir-programa-catalogo
description: "Use when se quiere añadir, quitar o evaluar un programa del catálogo de instalación: buscar ID de winget, licencia, instalación silenciosa, configuración, extensiones, actualizar docs/CATALOGO.md y el script."
---

# Añadir un programa al catálogo

1. Busca el ID: `winget search "<nombre>"` y `winget show --id <ID>` (comprobar editor oficial).
2. Verifica **licencia** (gratuito, open source, de pago) y fuente oficial. Si requiere licencia de pago, anótalo; no se incluyen cracks ni activadores.
3. Determina el método: `winget` (preferido), instalador `.exe/.msi` con parámetro silencioso, o manual. Anota el parámetro silent.
4. Añade una fila a [docs/CATALOGO.md](../../../docs/CATALOGO.md): categoría, programa, ID, configuración/extras.
5. Si se pide, añádelo a la lista `$programas` de `script/instalar_todo.ps1` (ver skill `script-powershell-instalador`).
6. Si es una herramienta nueva o poco conocida, revisa estabilidad, actividad del repositorio y riesgos antes de proponerla.
7. Registra el cambio con la skill `registrar-hito`.
