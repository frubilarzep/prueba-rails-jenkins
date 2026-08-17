# prueba-rails-jenkins

Sandbox Rails API para validar un pipeline de CI/CD (Jenkins) contra una
infraestructura ya montada en un droplet Ubuntu (Docker + Nginx + Jenkins +
Postgres). No es una aplicación real de un equipo, solo sirve para probar que
el flujo completo (checkout → test → lint → build → deploy → health check)
funciona de punta a punta.

Incluye un modelo de ejemplo (`Task`) con su controller REST, y un endpoint
`GET /health` pensado exclusivamente para el stage de Health Check del
pipeline.

## Requisitos

- Ruby 3.3.7 (ver `.ruby-version`)
- PostgreSQL corriendo localmente
- Bundler

## Correr en local

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

La app queda disponible en `http://localhost:3000`.

Endpoints principales:

- `GET /health` → `200 {"status":"ok"}` (stub, sin lógica ni dependencias)
- `GET /up` → health check por defecto de Rails
- `GET|POST /tasks`, `GET|PATCH|DELETE /tasks/:id` → CRUD de ejemplo

## Tests y lint

```bash
bundle exec rspec
bundle exec rubocop
```

## Docker

```bash
docker build -t sandbox-cicd .
docker run -d --name sandbox-cicd -p 3000:3000 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=<contenido de config/master.key> \
  sandbox-cicd
```

El container escucha en el puerto **3000**.

## Pipeline (Jenkins)

El `Jenkinsfile` en la raíz define un Multibranch Pipeline liviano (el
servidor Jenkins corre con `executors=1`, por lo que `disableConcurrentBuilds()`
está activo):

1. **Checkout**
2. **Install deps** — `bundle install`
3. **Test** — prepara la DB de test y corre `rspec`
4. **Lint** — `rubocop`
5. **Build image** — `docker build -t sandbox-cicd .`

Los siguientes stages solo corren en la rama `production`:

6. **Deploy** — levanta el container `sandbox-cicd` en la red Docker externa
   `course-net`, publicado solo en `127.0.0.1:4099` (puerto interno 3000, sin
   exponerlo públicamente ni dominio/HTTPS).
7. **Migrate** — no-op: este sandbox no tiene base de datos provisionada.
8. **Health Check** — `curl -f http://127.0.0.1:4099/health`

### Credencial requerida en Jenkins

El stage **Deploy** espera una credencial de tipo *Secret text* con el id
`sandbox-cicd-rails-master-key`, cuyo valor sea el contenido de
`config/master.key` (no está versionado). Sin esa credencial el deploy falla.
