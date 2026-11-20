INSTALADOR WINDOWS 10/11 - VERSION v0.1.1

1. Extrae el ZIP en una carpeta local.
2. Ejecuta instalar_todo.bat (solicitara administrador).
3. Para modo automatico, inicia sesion con el usuario final y ejecuta:
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\exec-main-v0.1.1.ps1 -Silencioso
   La tarea debe ejecutarse elevada, en contexto de usuario, NO como SYSTEM.
4. Logs y resumen CSV: C:\ProgramData\InstalarTodo
5. Para restaurar escritorio, agrega una carpeta copia_config\Escritorio junto al script.

SEGURIDAD / LIMITACIONES

- No borra el escritorio ni sobrescribe archivos existentes. Genera respaldo previo.
- No se autoelimina ni elimina tareas programadas o SetupComplete.cmd.
- No importa automaticamente .reg ni start2.bin por riesgo de incompatibilidad.
- No automatiza clics en instaladores. DNIe usa /silent; aTube Catcher usa /S.
  Estos parametros no estan verificados en Windows; si no funcionan, revisar el log.
- Los EXE/MSI descargados deben tener firma Authenticode valida; si no, se omiten.
  Una firma valida no garantiza por si sola la confiabilidad del proveedor.
- La URL de aTube Catcher se conserva del script original, sin verificar su vigencia.
- Las politicas de navegador pueden no aplicarse en equipos no administrados.
- No se ha ejecutado en Windows ni comprobado la instalacion real de programas.
