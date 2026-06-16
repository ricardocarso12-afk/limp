# Generar APK con GitHub Actions

Esta versión ya incluye un flujo automático para compilar la app sin instalar Flutter ni Android Studio en tu computadora.

## Requisitos

- Cuenta de GitHub.
- Repositorio nuevo, público o privado.
- Subir este proyecto completo al repositorio.

## Pasos

1. Crea un repositorio nuevo en GitHub.
2. Sube todo el contenido de la carpeta `tb_custom_clean_mobile`.
3. En GitHub entra a la pestaña **Actions**.
4. Selecciona **Build Android APK**.
5. Presiona **Run workflow**.
6. Espera a que termine.
7. Abre la ejecución terminada.
8. Baja hasta **Artifacts**.
9. Descarga:
   - `TB-Custom-Clean-debug-apk`
   - y, si se generó correctamente, `TB-Custom-Clean-release-apk`.

## APK recomendado para pruebas

Para instalar rápido en Android, usa:

```text
app-debug.apk
```

Este APK funciona para pruebas internas.

## APK release

El workflow también intenta generar:

```text
app-release.apk
```

Para publicar en Google Play se necesita firmar con una llave propia. Para instalar internamente, el debug APK es suficiente.

## Permisos incluidos

El workflow crea automáticamente los archivos Android y agrega permisos para:

- Internet.
- Cámara.
- Ubicación precisa.
- Ubicación aproximada.

## URL de API

La app debe conectarse a:

```text
https://tudominio.com/public/api.php
```

Puedes cambiarlo desde la pantalla de configuración de la app.
