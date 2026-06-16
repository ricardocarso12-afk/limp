# Instalación Android — T&B Custom Clean Mobile App

## 1. Instalar herramientas

- Flutter SDK
- Android Studio
- Android SDK
- Un emulador Android o un celular con depuración USB

## 2. Verificar Flutter

```bash
flutter doctor
```

Corrige cualquier error que marque Android toolchain.

## 3. Generar plataforma Android

Dentro de la carpeta del proyecto:

```bash
flutter create . --platforms=android
```

Después agrega los permisos de `docs/ANDROID_MANIFEST_PERMISOS.xml` en `android/app/src/main/AndroidManifest.xml`, arriba de `<application>`.

## 4. Instalar dependencias

```bash
flutter pub get
```

## 5. Ejecutar en celular

```bash
flutter run
```

## 6. Generar APK release

```bash
flutter build apk --release
```

## 7. Conectar con el sistema web

En la pantalla de Login coloca la URL base:

```text
https://tudominio.com/public/api.php
```

Luego inicia sesión con un usuario del sistema web.
