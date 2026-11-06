# Versionado y hoja de ruta

Se usa **Versionado Semántico** (`MAYOR.MENOR.PARCHE`) con `0.x` mientras el producto no esté listo para producción real.

- `0.MENOR.0`: nueva funcionalidad.
- `0.x.PARCHE`: correcciones sin funcionalidad nueva.
- `1.0.0`: primera versión estable y desplegada (fases 1 y 2 completas y probadas).
- Etiquetas Git: `v0.1.0`, `v0.2.0`… (una release por versión).

## Hoja de ruta propuesta

| Versión | Contenido | Fase |
|---------|-----------|------|
| **v0.1.0** | Web estática (HTML/CSS/JS) con un único descargable `.ps1` + `.bat` que instala los programas del catálogo sobre un Windows 11 ya instalado. | 1 |
| v0.2.0 | Configuración de navegadores y entorno (barra de tareas, Inicio, escritorio) integrada. | 1 |
| v0.3.0 | Actualizar (upgrade) los programas ya instalados, evitar que los programas se inicien con Windows (salvo antivirus y los necesarios), limpieza con las categorías del Liberador de espacio en disco de Windows y optimización de disco. | 2 |
| v0.4.0 | Instalación de Windows 11 desatendida (USB/ISO). | 2 |
| v0.5.0 | La web permite elegir programas/ajustes (catálogo en JSON). | 3 |
| v1.0.0 | Estable y desplegada. | — |

Orden y contenido sujetos a cambios en la planificación de cada sprint.
