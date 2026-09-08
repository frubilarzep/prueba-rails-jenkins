# SCRUM-13 — Serialización JSON con Blueprinter

Tarjeta: https://utem-team-web.atlassian.net/browse/SCRUM-13
Rama: `feature/blueprinter-serialization`

## Objetivo

Incorporar la gema [blueprinter](https://github.com/procore-oss/blueprinter)
como mecanismo único de serialización JSON de la API, reemplazando el
`as_json` sobrescrito en el modelo y los hashes armados a mano en los
controladores, sin cambiar el contrato documentado en Swagger.

## Alcance

Dentro del alcance:

- Gema `blueprinter` (~> 1.1) en el Gemfile.
- Directorio `app/blueprints/` con una clase base `ApplicationBlueprint` y
  un blueprint por recurso expuesto:
  - `UserBlueprint`: `id`, `email`.
  - `SessionBlueprint`: `token` + `user` (anidado con `UserBlueprint`).
- Value object `AuthSession` (`Data.define(:token, :user)`) que reemplaza el
  método privado `session_payload` del controlador.
- `AuthController` renderiza siempre a través de un blueprint.
- `User#as_json` desaparece: el modelo ya no decide qué campos son públicos.
- Inicializador `config/initializers/blueprinter.rb` con
  `sort_fields_by = :definition` para que el orden de las claves sea el
  declarado.

Fuera del alcance:

- Vistas (`view :extended`) o campos condicionales: no hay todavía más de
  una representación por recurso.
- Cambios en el contrato de `/auth/*` ni en `swagger/v1/swagger.yaml`.

## Contrato de la API

No cambia respecto a SCRUM-12. Los cuerpos siguen siendo:

| Endpoint              | Body                                              | Blueprint          |
| --------------------- | ------------------------------------------------- | ------------------ |
| `POST /auth/register` | `{ "token": "...", "user": { "id", "email" } }`   | `SessionBlueprint` |
| `POST /auth/login`    | `{ "token": "...", "user": { "id", "email" } }`   | `SessionBlueprint` |
| `GET /auth/me`        | `{ "user": { "id", "email" } }`                   | `UserBlueprint` con `root: :user` |

Los errores (`{ "errors": [...] }`) se mantienen como hashes literales por
ser un formato transversal y sin objeto de dominio detrás.

## Diseño

```
app/blueprints/application_blueprint.rb   base común (Blueprinter::Base)
app/blueprints/user_blueprint.rb          identifier :id, fields :email
app/blueprints/session_blueprint.rb       fields :token, association :user
app/models/auth_session.rb                AuthSession.for(user) firma el JWT
config/initializers/blueprinter.rb        sort_fields_by = :definition
```

Convención para nuevos recursos: crear `app/blueprints/<modelo>_blueprint.rb`
heredando de `ApplicationBlueprint` y renderizar desde el controlador con
`render json: MiBlueprint.render_as_hash(objeto)`. `render_as_hash` devuelve
un Hash (no un String), así que `render json:` sigue funcionando igual que
antes y se pueden mezclar claves extra si hiciera falta.

## Criterios de aceptación (tests)

Todo se valida con RSpec (`bundle exec rspec`), que también corre en Jenkins.

- `spec/blueprints/user_blueprint_spec.rb`: renderiza sólo `id` y `email`
  en ese orden, nunca `password_digest` ni timestamps, soporta `root:` y
  colecciones.
- `spec/blueprints/session_blueprint_spec.rb`: `token` decodificable con
  `sub` = id del usuario y `user` anidado con la forma de
  `components/schemas/session`.
- `spec/requests/auth_spec.rb` y `spec/integration/auth_spec.rb` (rswag)
  pasan sin modificaciones: el contrato no cambió.
- `bundle exec rake rswag:specs:swaggerize` no produce diff en
  `swagger/v1/swagger.yaml`.
- `rubocop`, `brakeman` y `bundler-audit` sin ofensas.

## Evidencia / cómo probar

```bash
bundle install
bin/rails server
# abrir http://localhost:3000/api-docs
```

1. Ejecutar `POST /auth/register` en Swagger UI: la respuesta debe traer
   exactamente `token` y `user: { id, email }`, sin `password_digest`.
2. Con el token en **Authorize**, `GET /auth/me` devuelve `{ "user": { id, email } }`.
3. En consola, `bin/rails runner 'puts UserBlueprint.render(User.first)'`
   imprime el JSON que sale por la API.
