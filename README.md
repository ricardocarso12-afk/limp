# T&B Custom Clean Mobile App V1.0 — Flutter

App móvil nativa Flutter para conectar con **T&B Custom Clean Platform V1.8 API Mobile**.

## Qué incluye

- Login con token Bearer.
- Configuración de URL API.
- Selector Español / English.
- Diseño visual T&B Custom Clean.
- Salida de producto por QR impreso.
- Código manual como respaldo.
- Registro de quién recogió.
- Fecha/hora automática desde servidor/app.
- Ubicación GPS donde se escaneó.
- Modo offline básico para salidas.
- Sincronización de salidas pendientes.
- Entrada de producto desde app.
- 5 fotos obligatorias por producto.
- Consulta de productos.
- Alertas de almacén por días.

## API requerida

Debes tener instalado el sistema web:

```text
T&B Custom Clean Platform V1.8 API Mobile o superior
```

Prueba la API con:

```text
https://tudominio.com/public/api.php?r=mobile/ping
```

Debe responder:

```json
{"ok": true}
```

## Cómo abrir el proyecto

1. Instala Flutter en tu computadora.
2. Abre esta carpeta en VS Code o Android Studio.
3. Genera las carpetas nativas de Android/iOS si no existen:

```bash
flutter create . --platforms=android,ios
```

4. Agrega los permisos indicados en `docs/ANDROID_MANIFEST_PERMISOS.xml` al archivo `android/app/src/main/AndroidManifest.xml`.
5. Ejecuta:

```bash
flutter pub get
flutter run
```

## Cómo generar APK

```bash
flutter build apk --release
```

El APK queda en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## URL API en la app

En Login o Configuración coloca:

```text
https://tudominio.com/public/api.php
```

No agregues `?r=` al final; la app lo agrega automáticamente.

## Permisos Android

Incluye permisos para:

- Internet
- Cámara
- Ubicación precisa
- Ubicación aproximada

## Notas

Este ZIP contiene el código fuente Flutter. Para generar APK necesitas Flutter/Android Studio instalado en la computadora; Hostinger no compila apps móviles.


## V1.0.1 - Auto Build APK con GitHub

Esta versión incluye GitHub Actions para generar APK automáticamente sin instalar Flutter ni Android Studio localmente.

Archivo principal:

```text
.github/workflows/build-apk.yml
```

Documentación:

```text
docs/GENERAR_APK_CON_GITHUB.md
docs/GITHUB_SUBIR_PROYECTO.md
```

Flujo recomendado:

1. Subir el proyecto a GitHub.
2. Entrar a Actions.
3. Ejecutar Build Android APK.
4. Descargar el APK desde Artifacts.
