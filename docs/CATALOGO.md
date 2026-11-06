# Catálogo de programas (fase inicial)

IDs de `winget` usados en el prototipo (`script/instalar_todo.ps1`). AutoFirma se instala por nombre y aTube Catcher por instalador `.exe` descargado. El DNIe queda fuera de la v1. Ver [SCRIPTS.md](SCRIPTS.md).

| Categoría | Programa | ID winget (a verificar) | Configuración / extras |
|-----------|----------|-------------------------|------------------------|
| SO | Windows 11 | — | Instalación desatendida (fase posterior). |
| Navegador | Firefox | `Mozilla.Firefox` | Extensión Video DownloadHelper. |
| Navegador | Chrome | `Google.Chrome` | Extensión uBlock Origin Lite. |
| Navegador | Brave | `Brave.Brave` | — |
| Multimedia | K-Lite Codec Pack | `CodecGuide.K-LiteCodecPack.Standard` | — |
| Multimedia | VLC | `VideoLAN.VLC` | — |
| Multimedia | ATube Catcher | Sin verificar (posible descarga directa) | Revisar fuente oficial y licencia. |
| Utilidades | WinRAR | `RARLab.WinRAR` | Licencia propia (shareware). |
| PDF | Adobe Acrobat Reader | `Adobe.Acrobat.Reader.64-bit` | — |
| PDF | PDFgear | `PDFgear.PDFgear` | Gratuito. |
| Ofimática | LibreOffice | `TheDocumentFoundation.LibreOffice` (a verificar) | Sustituye a Office (decisión 12). |
| Administración ES | AutoFirma | Sin verificar (descarga oficial) | Requiere Java/certificados. |

## Fuera de la v1
- **Controladores DNIe:** excluidos de la primera versión porque requieren un `.exe` descargado previamente. Se reincorporarán cuando haya descarga automática desde la fuente oficial con comprobación de hash.

## Futuro
- Valorar alternativas gratuitas de código abierto (p. ej. LibreOffice en lugar de Office, 7-Zip en lugar de WinRAR). Pendiente de decidir.
- ArtCraft ([getartcraft.com](https://getartcraft.com), código en `github.com/storytold/artcraft`): según su web, es open source y gratuito, con dos productos: **ArtCraft Studio** (IA generativa de imagen/vídeo, de escritorio o web) y **Crafting Apps** (13 apps nativas de edición de imagen, ilustración vectorial, vídeo, maquetación, audio…) instaladas mediante **ArtCraft Launcher**. Pendiente de verificar: licencia exacta en el repositorio, si está en `winget`, instalación silenciosa, estabilidad y que los modelos de IA no requieran pago (el uso de modelos externos podría tener coste).
