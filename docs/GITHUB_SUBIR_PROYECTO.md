# Cómo subir el proyecto a GitHub

## Forma rápida desde la web

1. Entra a GitHub.
2. Crea un repositorio nuevo.
3. Presiona **Add file** > **Upload files**.
4. Arrastra todos los archivos de la carpeta `tb_custom_clean_mobile`.
5. Presiona **Commit changes**.
6. Entra a **Actions** y ejecuta **Build Android APK**.

## Forma con Git en Windows

```bash
git init
git add .
git commit -m "T&B Custom Clean Mobile App"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
git push -u origin main
```

Después entra a **Actions** y ejecuta el workflow.
