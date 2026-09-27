# SCRUM-14 — Swagger/OpenAPI en /api-docs

Tarjeta: https://utem-team-web.atlassian.net/browse/SCRUM-14
Rama: `feature/api-docs`

## Objetivo

Documentar y visualizar todos los endpoints de la API con Swagger/OpenAPI,
accesible en `/api-docs`.

## Punto de partida

La integración base ya existe desde SCRUM-12 (rswag 2.17):

- `rswag-ui` y `rswag-api` montados en `/api-docs` (`config/routes.rb`).
- `spec/swagger_helper.rb` define el documento `v1/swagger.yaml`.
- `spec/integration/auth_spec.rb` documenta `/auth/register`, `/auth/login`
  y `/auth/me`.

Faltaba documentar `/health` y `/up`, y no había un test que verificara que
`/api-docs` sirve la UI y el documento con todos los endpoints.

## Alcance

Dentro del alcance:

- `spec/integration/health_spec.rb` (rswag): documenta `GET /health`
  (`{ "status": "ok" }`) y `GET /up` bajo el tag **Health**.
- `swagger/v1/swagger.yaml` regenerado con esos paths.
- `spec/requests/api_docs_spec.rb`: `/api-docs` sirve Swagger UI, el YAML es
  OpenAPI 3.0.1, contiene exactamente los endpoints de `config/routes.rb` e
  incluye request body, respuestas y códigos de estado.

Fuera del alcance:

- Cambios en controladores o en el contrato de la API: la implementación no
  toca el comportamiento actual.

## Endpoints documentados

| Método | Path             | Tag    | Respuestas     | Auth   |
| ------ | ---------------- | ------ | -------------- | ------ |
| POST   | `/auth/register` | Auth   | 201, 422       | —      |
| POST   | `/auth/login`    | Auth   | 200, 401       | —      |
| GET    | `/auth/me`       | Auth   | 200, 401       | Bearer |
| GET    | `/health`        | Health | 200            | —      |
| GET    | `/up`            | Health | 200            | —      |

Convención: todo endpoint nuevo se agrega con su spec en `spec/integration/`
y se agrega a la lista de `spec/requests/api_docs_spec.rb`; ese test falla
si una ruta queda sin documentar en el YAML.

## Criterios de aceptación (tests)

- `spec/integration/health_spec.rb` y `spec/integration/auth_spec.rb`
  (rswag) pasan y generan `swagger/v1/swagger.yaml`. El YAML commiteado debe
  coincidir con el generado (`bundle exec rake rswag:specs:swaggerize`).
- `spec/requests/api_docs_spec.rb` pasa.
- Los tests existentes siguen verdes; `rubocop`, `brakeman` y
  `bundler-audit` sin ofensas.

## Evidencia / cómo probar

```bash
bin/rails db:create db:migrate
bin/rails server
# abrir http://localhost:3000/api-docs
```

1. Verificar que Swagger UI carga y lista los tags **Auth** y **Health**.
2. Expandir cada endpoint: método, parámetros, respuestas y códigos.
3. **Try it out** en `GET /health`: debe devolver 200 con
   `{ "status": "ok" }`.
