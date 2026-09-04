# prueba-rails-jenkins

Rails API (Rails 8.1, Ruby 3.3.7, PostgreSQL) con un pipeline de CI/CD en
Jenkins que despliega a un droplet Ubuntu ya montado (Docker + Nginx + Jenkins
+ Postgres). El proyecto parte desde un esqueleto vacío: solo incluye el
endpoint `GET /health` que usa el stage de Health Check del pipeline.

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

Endpoints:

- `GET /health` → `200 {"status":"ok"}` (stub, sin lógica ni dependencias)
- `GET /up` → health check por defecto de Rails

## Tests, lint y seguridad

```bash
bundle exec rspec
bundle exec rubocop
bin/brakeman --no-pager
bin/bundler-audit
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
está activo). Los stages de build y test corren dentro de un container
`ruby:3.3.7-slim` conectado a la red Docker `course-net`:

1. **Checkout**
2. **Install deps** — `bundle install`
3. **Test** — `bin/rails db:schema:load` + `rspec` contra la DB de test
4. **Lint** — `rubocop`
5. **Security scan** — `brakeman` + `bundler-audit`
6. **Build image** — `docker build -t sandbox-cicd .`

Los siguientes stages solo corren en la rama `production`:

7. **Deploy** — levanta el container `sandbox-cicd` en la red Docker externa
   `course-net`, publicado solo en `127.0.0.1:4099` (puerto interno 3000, sin
   exponerlo públicamente ni dominio/HTTPS).
8. **Migrate** — no-op: este sandbox no tiene base de datos provisionada.
9. **Health Check** — `curl -f http://127.0.0.1:4099/health`

### Credenciales requeridas en Jenkins

| Id                              | Tipo        | Uso                                                   |
|---------------------------------|-------------|-------------------------------------------------------|
| `sandbox-cicd-test-db-url`      | Secret text | `DATABASE_URL` de la DB de test usada por el stage Test |
| `sandbox-cicd-rails-master-key` | Secret text | Contenido de `config/master.key` para el stage Deploy  |

Sin esas credenciales el pipeline falla.
