---
description: "Use when creating or editing HTML, CSS, or JavaScript. Covers accessible HTML, maintainable styles, and reliable JavaScript."
applyTo: "**/*.{html,css,js}"
---

# Buenas prácticas de front-end

- Nombra variables, funciones, clases, atributos `id`, clases CSS, propiedades personalizadas y demás identificadores en inglés; usa nombres breves, descriptivos y coherentes con el contexto.
- Prefiere código autodocumentado; evita abreviaturas crípticas y comentarios que repitan literalmente el código.
- Usa comentarios solo para explicar decisiones no obvias, contexto, limitaciones o comprobaciones necesarias. Los comentarios del código serán siempre en español.

## HTML y accesibilidad

- Usa HTML semántico: elementos como `main`, `nav`, `header`, `footer`, `section` y `button` según su propósito. No elijas elementos solo por su apariencia.
- Mantén una jerarquía de encabezados lógica y un único `h1` descriptivo por página.
- Asegura que todas las acciones se puedan realizar con teclado y que el foco sea visible y siga un orden lógico.
- Asocia cada control de formulario con una etiqueta visible; no uses el `placeholder` como sustituto de `label`.
- Añade texto alternativo útil a las imágenes informativas y `alt=""` a las decorativas.
- Comprueba el contraste, no comuniques información solo mediante color y respeta `prefers-reduced-motion`.
- Prefiere controles HTML nativos. Usa ARIA solo cuando HTML no proporcione la semántica necesaria y completa todos los estados accesibles relevantes.
- Los enlaces navegan; los botones ejecutan acciones. Proporciona nombres accesibles claros y únicos cuando el texto visible no baste.

## CSS

- Sigue la organización y las convenciones existentes; usa nombres de clases claros y consistentes.
- Prioriza diseños responsive y flexibles frente a dimensiones rígidas. Comprueba los tamaños de pantalla relevantes.
- Evita selectores demasiado específicos, duplicación innecesaria y `!important`; reutiliza variables CSS cuando aporten consistencia.
- No elimines indicadores de foco ni uses estilos que dificulten lectura, navegación o interacción.

## JavaScript

- Usa `const` por defecto y `let` solo cuando el valor deba reasignarse; evita `var` y el estado global innecesario.
- Mantén funciones enfocadas, pequeñas y con efectos secundarios claros. Reutiliza el patrón y las APIs del proyecto antes de introducir abstracciones o dependencias.
- Valida datos externos y de formularios en el límite de entrada. Para texto no confiable, usa APIs seguras como `textContent` en vez de interpolarlo en `innerHTML`.
- Gestiona errores y operaciones asíncronas explícitamente; no ocultes fallos con `catch` vacío ni presentes un fallo como éxito.
- Comprueba la interacción con teclado y estados de carga, vacío y error cuando sean pertinentes; actualiza o añade pruebas según las convenciones del proyecto.
