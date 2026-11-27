# Flujo de trabajo con Git

Guía práctica para el día a día. Si es tu primera vez con ramas, lee las secciones en orden.

## Ramas del proyecto

| Rama | Para qué sirve | ¿Se puede escribir directamente? |
|------|----------------|----------------------------------|
| `main` | Versión publicable y estable | **No**. Solo entra código mediante Pull Request |
| `dev` | Integración del trabajo del equipo | **No**. Solo entran PRs de ramas `feat/`, `fix/`… |
| `feat/…`, `fix/…`, `doc/…` | Trabajo diario de cada tarea | Sí, es tu rama |

Regla de oro: **nunca hagas commit ni push directamente a `main` ni a `dev`**.

```
feat/mi-tarea ──PR──> dev ──PR──> main
```

- Las tareas se integran en `dev` mediante PR.
- `dev` se integra en `main` mediante PR al cerrar un sprint o preparar una versión.

## Crear una rama nueva

1. Sitúate en `dev` y actualízala:

   ```powershell
   git switch dev
   git pull
   ```

2. Crea tu rama a partir de `dev`:

   ```powershell
   git switch -c feat/program-selector
   ```

3. Comprueba que estás en ella:

   ```powershell
   git status
   ```

### Cómo nombrar la rama

Formato: `prefijo/descripcion-corta`

| Prefijo | Cuándo usarlo | Ejemplo |
|---------|---------------|---------|
| `feat/` | Nueva funcionalidad | `feat/program-selector` |
| `fix/` | Corrección de un error | `fix/winget-not-found` |
| `doc/` | Documentación | `doc/git-workflow` |
| `chore/` | Mantenimiento, configuración, dependencias | `chore/update-gitignore` |
| `refactor/` | Reorganizar código sin cambiar su comportamiento | `refactor/installer-functions` |
| `test/` | Añadir o corregir pruebas | `test/catalog-validation` |
| `perf/` | Mejorar rendimiento | `perf/cleanup-speed` |

- Minúsculas, guiones en vez de espacios, sin tildes ni `ñ`.
- Corta y descriptiva, en inglés.
- Una rama = una tarea.

## Guardar cambios: stage y commit

El **stage** (o índice) es la bandeja donde eliges qué cambios entran en el próximo commit. Así puedes hacer commits atómicos aunque hayas tocado varios archivos.

```powershell
# Ver qué ha cambiado
git status

# Añadir solo lo que quieres commitear
git add ruta/al/archivo
git add otra/ruta

# Añadir todo (revisa antes con git status)
git add .

# Revisar lo que está preparado
git diff --staged

# Sacar un archivo del stage sin perder sus cambios
git restore --staged ruta/al/archivo
```

### Commits atómicos

Un commit debe ser **un solo cambio lógico** y dejar el proyecto funcionando:

- No mezcles una funcionalidad con un arreglo o con formateo de archivos.
- Si el mensaje te obliga a usar "y", probablemente sean dos commits.
- Mejor varios commits pequeños que uno gigante con veinte archivos.

### Mensaje del commit

Formato **Conventional Commits**, siempre en inglés y breve:

```
tipo(alcance): descripción en imperativo
```

- `tipo`: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`.
- `alcance`: opcional; la parte afectada (`web`, `script`, `catalog`…).
- Descripción en minúscula, sin punto final, como una orden ("add", no "added").

```powershell
git commit -m "feat(catalog): add Firefox to program list"
git commit -m "fix(script): handle missing winget"
git commit -m "docs(git): document branch workflow"
git commit -m "refactor(installer): split config functions"
git commit -m "chore: update gitignore"
```

Mensajes a evitar: `cambios`, `arreglos`, `wip`, `update`, `subida`.

## Subir la rama (push)

La primera vez, enlaza tu rama con el remoto:

```powershell
git push -u origin feat/program-selector
```

Las siguientes veces basta con:

```powershell
git push
```

Nunca hagas `git push` estando en `dev` o `main`: sube siempre tu propia rama.

## Pull Request (PR)

1. En GitHub, pulsa **Compare & pull request** para tu rama.
2. Base del PR: `dev` (no `main`).
3. Título con el mismo formato que los commits y descripción breve: qué cambia, por qué y cómo probarlo.
4. Otra persona revisa. Si pide cambios, haz commits nuevos en la misma rama y vuelve a hacer `push`.
5. **Merge** del PR. Usa **Merge commit** para conservar los commits atómicos; usa **Squash and merge** solo si tu rama tiene commits desordenados.
6. Borra la rama (botón de GitHub o instrucciones de abajo).

Al cerrar un sprint o preparar una versión: PR de `dev` hacia `main`, revisado igual que cualquier otro.

## Borrar una rama

Se borra **primero la remota y después la local**, una vez fusionado el PR:

```powershell
# 1. Vuelve a dev y actualízate
git switch dev
git pull

# 2. Borra la rama en GitHub
git push origin --delete feat/program-selector

# 3. Borra la rama local
git branch -d feat/program-selector

# 4. Limpia las referencias remotas obsoletas
git fetch --prune
```

- `git branch -d` se niega si la rama tiene commits sin fusionar; es una protección. Usa `-D` solo si estás seguro de que quieres descartarlos.
- No puedes borrar la rama en la que estás: cambia antes a `dev`.
- En GitHub puedes borrar la rama remota con el botón del PR; aun así hay que borrar la local.

## Mantenerse al día con `dev`

Antes de seguir trabajando en tu rama, trae los cambios de `dev`:

```powershell
git switch dev
git pull

git switch feat/program-selector
git merge dev
```

Si hay conflictos, Git marca los archivos: edítalos, guarda, haz `git add` de cada uno y termina con `git commit`. Para empezar, usa `merge`; `rebase` reescribe el historial y es más fácil equivocarse.

## Buenas prácticas (checklist)

- [ ] Actualiza `dev` antes de crear la rama.
- [ ] Una rama y un PR por tarea; PR pequeños y fáciles de revisar.
- [ ] Commits atómicos, en inglés y con el formato acordado.
- [ ] Revisa `git status` y `git diff --staged` antes de commitear.
- [ ] No subas secretos, datos personales ni binarios (ver `.gitignore` y decisión 16).
- [ ] No mezcles cambios no relacionados ni reformatees archivos enteros sin motivo.
- [ ] No hagas push directo a `main` ni a `dev`; todo pasa por PR.
- [ ] Borra la rama después del merge.
- [ ] Evita `--force` en ramas compartidas; si es imprescindible en tu propia rama, usa `--force-with-lease`.
- [ ] Ante la duda con algo destructivo (`reset --hard`, `push --force`, `rebase`), pregunta antes.

## Chuleta

```powershell
git switch dev                     # cambiar a dev
git pull                           # actualizar dev
git switch -c feat/mi-tarea        # crear rama desde dev
git status                         # ver estado
git add archivo                    # preparar cambios
git commit -m "feat(web): ..."     # commit atómico
git push -u origin feat/mi-tarea   # subir la rama (primera vez)
git push                           # subir cambios siguientes
git push origin --delete feat/mi-tarea  # borrar rama remota
git branch -d feat/mi-tarea        # borrar rama local
git fetch --prune                  # limpiar referencias remotas
```
