# SCRUM-12 — Autenticación JWT documentada con Swagger

Tarjeta: https://utem-team-web.atlassian.net/browse/SCRUM-12
Rama: `feature/jwt-auth-swagger`

## Objetivo

Agregar a la API un protocolo de autenticación basado en JSON Web Tokens
(JWT), con usuarios persistidos en PostgreSQL, y exponer los endpoints en
Swagger UI (`/api-docs`) para poder probarlos desde el navegador.

## Alcance

Dentro del alcance:

- Modelo `User` con `email` único y contraseña hasheada con bcrypt
  (`has_secure_password`).
- Emisión y verificación de tokens JWT firmados con HS256 usando
  `Rails.application.secret_key_base`, con expiración de 24 horas.
- Endpoints públicos:
  - `POST /auth/register` crea un usuario y devuelve un token.
  - `POST /auth/login` valida credenciales y devuelve un token.
- Endpoint protegido:
  - `GET /auth/me` devuelve el usuario del token enviado en
    `Authorization: Bearer <token>`.
- Concern `Authenticable` reutilizable por cualquier controlador futuro
  (`before_action :authenticate_request!` y helper `current_user`).
- Documentación OpenAPI 3 generada con rswag y servida en `/api-docs`,
  con el esquema de seguridad `bearerAuth` para probar `GET /auth/me`
  desde Swagger UI.

Fuera del alcance:

- Refresh tokens, revocación o lista negra de tokens.
- Roles y permisos.
- Recuperación de contraseña y verificación de email.

## Contrato de la API

Todas las respuestas son JSON.

### `POST /auth/register`

Body:

```json
{ "user": { "email": "ana@example.com", "password": "secreto123", "password_confirmation": "secreto123" } }
```

| Código | Cuándo                                   | Body                                         |
| ------ | ---------------------------------------- | -------------------------------------------- |
| 201    | Usuario creado                           | `{ "token": "...", "user": { id, email } }`  |
| 422    | Email duplicado, inválido o password < 8 | `{ "errors": ["..."] }`                      |

### `POST /auth/login`

Body:

```json
{ "email": "ana@example.com", "password": "secreto123" }
```

| Código | Cuándo                         | Body                                        |
| ------ | ------------------------------ | ------------------------------------------- |
| 200    | Credenciales válidas           | `{ "token": "...", "user": { id, email } }` |
| 401    | Email inexistente o password incorrecta | `{ "errors": ["Credenciales inválidas"] }` |

Para no filtrar qué emails existen, ambos casos de 401 devuelven el mismo
mensaje.

### `GET /auth/me`

Header: `Authorization: Bearer <token>`

| Código | Cuándo                                             | Body                        |
| ------ | -------------------------------------------------- | --------------------------- |
| 200    | Token válido y usuario existente                   | `{ "user": { id, email } }` |
| 401    | Sin header, token malformado, expirado o firma inválida, o usuario borrado | `{ "errors": ["No autorizado"] }` |

### Token

- Algoritmo HS256, clave `Rails.application.secret_key_base`.
- Claims: `sub` (id del usuario), `iat`, `exp` (24 h desde la emisión).

## Diseño

```
app/models/user.rb                       has_secure_password, validaciones
app/services/json_web_token.rb           encode(payload) / decode(token)
app/controllers/concerns/authenticable.rb authenticate_request!, current_user
app/controllers/auth_controller.rb       register, login, me
config/initializers/rswag_api.rb         sirve swagger/ en /api-docs
config/initializers/rswag_ui.rb          Swagger UI en /api-docs
spec/swagger_helper.rb                   metadata OpenAPI + securitySchemes
swagger/v1/swagger.yaml                  generado por rswag:specs:swaggerize
```

`JsonWebToken.decode` devuelve `nil` ante cualquier `JWT::DecodeError`
(incluye expirado y firma inválida) para que el concern responda siempre 401
sin exponer detalles.

## Criterios de aceptación (tests)

Todo se valida con RSpec (`bundle exec rspec`), que también corre en Jenkins.

- `spec/models/user_spec.rb`: email requerido, único e insensible a
  mayúsculas; password mínimo 8 caracteres; `authenticate` funciona.
- `spec/services/json_web_token_spec.rb`: encode/decode ida y vuelta,
  token expirado devuelve `nil`, token con firma ajena devuelve `nil`.
- `spec/requests/auth_spec.rb`: los códigos de la tabla de contrato para
  register, login y me, incluyendo header ausente, token basura y token de
  un usuario eliminado.
- `spec/integration/auth_spec.rb` (rswag): mismos casos, y además genera
  `swagger/v1/swagger.yaml`. El YAML commiteado debe coincidir con el
  generado (`bundle exec rake rswag:specs:swaggerize`).
- `rubocop`, `brakeman` y `bundler-audit` sin ofensas.

## Evidencia / cómo probar

```bash
bin/rails db:create db:migrate
bin/rails server
# abrir http://localhost:3000/api-docs
```

1. En Swagger UI ejecutar `POST /auth/register` con un email y password.
2. Copiar el `token` de la respuesta, pulsar **Authorize** y pegarlo.
3. Ejecutar `GET /auth/me`: debe devolver 200 con el usuario.
4. Pulsar **Logout** en Authorize y repetir `GET /auth/me`: debe devolver 401.
