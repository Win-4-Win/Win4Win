# Propuesta de planificación: sprint 01 y hoja de ruta

**Estado:** borrador para revisar con el equipo; no se han creado issues ni se ha iniciado el sprint.

## Capacidad y objetivo

- Equipo: 3 personas, aproximadamente 3 horas por persona y semana.
- Sprint: 2 semanas; capacidad teórica total de 18 horas. Reservar unas 4 horas para coordinación, revisión, imprevistos y cierre; planificar como máximo unas 14 horas de trabajo inicialmente.
- Fecha de entrega: sin confirmar; abril es una referencia aproximada, no un compromiso.
- Objetivo del sprint 01: acordar qué debe ofrecer la web, disponer de una base reproducible de pruebas y conocer el estado real del script antes de modificarlo.
- Las estimaciones son horas de esfuerzo de equipo, no tiempo de calendario. No incluyen instalaciones o descargas desatendidas; se revisarán tras el primer sprint.

## Historias propuestas para el sprint 01

### 1. Definir secciones y flujo de la web — 2 h

**Como visitante**, quiero saber qué hace Win4Win y cómo usarlo para decidir si me sirve.

Criterios de aceptación:
- Listar Inicio, Quiénes somos, Instrucciones y Preguntas frecuentes, además de Descargas y catálogo como propuesta.
- Esbozar el recorrido desde la explicación hasta la descarga y las instrucciones; indicar requisitos, advertencias y enlace al código revisable.
- Proponer páginas y navegación utilizables con teclado, en escritorio y en móvil.

### 2. Decidir arquitectura y stack de la primera web — 2 h

**Como equipo**, queremos elegir una arquitectura sencilla para construir y mantener la primera web.

Criterios de aceptación:
- Comparar páginas estáticas con una SPA, y JavaScript vanilla con TypeScript; registrar ventajas, inconvenientes y decisión del equipo.
- Partir de la decisión existente de HTML, CSS y JavaScript vanilla; no considerar TypeScript o un framework aprobados hasta que el equipo cambie esa decisión.
- Acordar cómo se servirán los ficheros versionados, sin generar scripts en la web ni exigir backend o base de datos en la v0.1.0.

### 3. Preparar una VM de Windows 11 para pruebas — 4 h

**Como integrante del equipo**, quiero restaurar un Windows de pruebas para repetir instalaciones sin afectar al equipo anfitrión.

Criterios de aceptación:
- Comprobar RAM, espacio, virtualización y disponibilidad de VirtualBox; anotar versión del anfitrión y de Windows invitado.
- Instalar Windows 11 en una VM con snapshot base, con medio oficial y licencia o evaluación válidos.
- Comprobar conexión, inicio de sesión y funcionamiento de `winget`; guardar un snapshot base y verificar que se puede restaurar.
- Documentar configuración, requisitos y recuperación; sin datos personales ni binarios en Git. No usar la VM para credenciales reales.

### 4. Revisar el prototipo del script y definir pruebas — 4 h

**Como integrante del equipo**, quiero conocer el comportamiento y los riesgos del script para poder mejorarlo y probarlo de forma segura.

Criterios de aceptación:
- Obtener del compañero la versión actual y contrastarla con [SCRIPTS.md](../SCRIPTS.md); en este checkout no aparecen los archivos `.ps1`/`.bat`.
- Enumerar pasos, dependencias, permisos, registros, mensajes y posibles acciones destructivas; no ejecutarlo hasta revisarlo.
- Preparar casos comprobables para instalación limpia, segunda ejecución, ausencia de `winget`, fallo de descarga o instalación y resumen de errores.
- Identificar diferencias con el catálogo de la v1, incluido DNIe fuera de alcance, y trasladarlas al backlog sin asumir que ya están corregidas.

### 5. Organizar el tablero y acordar la definición de hecho — 2 h

**Como equipo**, queremos visualizar las tareas y sus bloqueos para repartir el trabajo y revisar el avance.

Criterios de aceptación:
- Preparar en GitHub Projects las columnas Backlog, Listo, En curso, En revisión y Hecho, o su equivalente.
- Crear o anotar los cinco ítems de este sprint con estimación, responsable cuando se conozca, criterios y dependencias.
- Acordar un modo de registrar resultados, incidencias y revisión de cada sprint.

**Total estimado:** 14 h de trabajo de equipo; las asignaciones concretas están pendientes. La historia 4 depende de recibir el prototipo; si no llega, registrar el bloqueo y reducir el compromiso del sprint.

## Definición de hecho propuesta

- Criterios de aceptación cumplidos y evidencia enlazada en el ítem.
- Cambios en rama y PR revisada por otra persona, sin integrar directamente en `main`.
- Para cambios en el script: pruebas pertinentes en la VM y resultados registrados; para la web: pruebas funcionales, responsive y de accesibilidad aplicables. Las tareas solo de planificación no requieren ejecución en VM.
- Documentación directamente afectada actualizada; riesgos, fallos y tareas pendientes registrados.

## Hoja de ruta orientativa

Cada fila representa un sprint quincenal propuesto, no un compromiso cerrado. Priorizar y dividir de nuevo según capacidad real; no asumir que cada bloque cabe sin medirlo.

| Sprint | Objetivo | Entregable orientativo / dependencia |
|---|---|---|
| 01 | Alinear web, stack, pruebas y estado del prototipo | Secciones, decisión técnica, VM restaurable y lista inicial de pruebas. |
| 02 | Crear la base web y adaptar el script al alcance inicial | Estructura y navegación responsive; script revisado y catálogo priorizado. Depende de disponer del prototipo. |
| 03 | Obtener una instalación mínima reproducible | Instalación silenciosa de un subconjunto acordado y resultados en VM limpia; mensajes y errores claros. |
| 04 | Ampliar y verificar el catálogo de la v0.1.0 | Programas restantes verificados por lotes, licencia y fuentes oficiales, repetición e incidencias. Dividir si no cabe. |
| 05 | Preparar la primera entrega integrada | Descarga versionada, instrucciones, pruebas de extremo a extremo y revisión de accesibilidad. No publicar si faltan criterios o pruebas. |
| 06 | Configurar navegadores y entorno | Opciones seguras y verificables en VM; evitar restaurar datos personales. |
| 07 | Evaluar y construir automatizaciones adicionales | Actualización de programas, arranque, limpieza y optimización por tareas independientes; confirmar acciones destructivas y probar selectivamente. |
| 08 | Investigar instalación de Windows | Decidir alcance y mecanismo de instalación desatendida, requisitos y seguridad; ensayar en un disco virtual separado, no en el anfitrión. |
| 09 | Desarrollar y probar el flujo de instalación de Windows | Solo tras aprobar el diseño; puede requerir varios sprints. |
| 10 | Diseñar y probar la selección desde la web | Definir combinaciones factibles usando artefactos predefinidos y versionados, sin generar scripts al vuelo; implementación posterior según la decisión. |
| Posteriores | Completar selección, endurecer y publicar | Pruebas integrales, accesibilidad, seguridad, documentación, memoria y defensa. Reservar sprints adicionales según resultados. |

El orden y las versiones se contrastarán con [VERSIONES.md](../VERSIONES.md) en cada planificación. La selección de opciones puede multiplicar los artefactos necesarios: decidir sus límites antes de prometer combinaciones arbitrarias. Reservar tiempo durante todo el proyecto para documentación y memoria.

## Propuesta técnica para la VM

Usar **Oracle VirtualBox** para crear una VM Windows 11 con EFI y snapshots: permite probar aplicaciones de escritorio, reinicios y configuraciones reales y volver a un estado conocido. En un equipo con 16 GB de RAM es más cómodo; con 8 GB puede funcionar con 4 GB para el invitado y pocas aplicaciones en el anfitrión, pero hay que medir el rendimiento. Prever al menos 64 GB de disco virtual dinámico y espacio adicional en el anfitrión para snapshots; el consumo real crece con instalaciones y estados guardados.

Docker no reproduce adecuadamente un escritorio Windows 11 completo ni una instalación de Windows desde cero; sus contenedores Windows tienen limitaciones de imagen y compatibilidad. Puede servir para otras pruebas, pero no sustituye esta VM. La licencia de Windows del anfitrión no concede automáticamente una licencia al invitado: comprobar las condiciones aplicables o usar una evaluación oficial vigente.

Flujo: obtener el medio oficial, crear y configurar la VM, instalar Windows, preparar y comprobar `winget`, crear un snapshot base, ejecutar pruebas y guardar logs fuera de la VM antes de restaurar. Un snapshot no es una copia de seguridad. Usar cuentas y datos de prueba; si se necesitan pruebas sin red o de instalación del SO, mantener estados separados. No ejecutar pruebas destructivas sobre discos o carpetas del anfitrión.

Fuentes: [manual de Oracle VirtualBox](https://www.virtualbox.org/manual/), [snapshots de VirtualBox](https://www.virtualbox.org/manual/ch01.html#snapshots) y [compatibilidad de contenedores Windows](https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility).

## Decisiones aún pendientes

- Aprobar la hoja de ruta, fechas y responsables; estimar de nuevo tras el primer sprint.
- Confirmar SPA o páginas estáticas, JavaScript o TypeScript, y cualquier framework.
- Confirmar hardware concreto y condiciones de licencia del Windows invitado.
- Definir alcance exacto de la instalación de Windows, selección de programas, combinaciones y criterios de entrega del curso.
- Revisar con el compañero el comportamiento real del script antes de redactar tareas detalladas de refactorización.
