# Conexión API Mobile

La app usa los endpoints agregados en T&B Custom Clean Platform V1.8.

## Endpoints usados

- `mobile/ping`
- `mobile/login`
- `mobile/logout`
- `mobile/me`
- `mobile/product-types`
- `mobile/users/pickup`
- `mobile/products`
- `mobile/scan`
- `mobile/product-entry`
- `mobile/product-exit`
- `mobile/storage-alerts`
- `mobile/sync`

## Autenticación

La app guarda el token Bearer con `flutter_secure_storage`.

## Offline

Cuando una salida falla por conexión, se guarda en SQLite y después se sincroniza con `mobile/sync`.
