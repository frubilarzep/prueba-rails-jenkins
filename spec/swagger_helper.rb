require "rails_helper"

RSpec.configure do |config|
  # Folder where the OpenAPI files are generated. rswag-api serves this same
  # folder at /api-docs (see config/initializers/rswag_api.rb).
  config.openapi_root = Rails.root.join("swagger").to_s

  # Run `bundle exec rake rswag:specs:swaggerize` to regenerate the documents
  # below from the specs in spec/integration.
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Prueba Rails Jenkins API",
        version: "v1",
        description: "API de ejemplo con autenticación JWT. " \
                     "Obtén un token en /auth/register o /auth/login y úsalo con el botón Authorize."
      },
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          errors: {
            type: :object,
            properties: {
              errors: { type: :array, items: { type: :string } }
            },
            required: %w[errors]
          },
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string, format: :email }
            },
            required: %w[id email]
          },
          session: {
            type: :object,
            properties: {
              token: { type: :string, description: "JWT firmado (HS256), expira en 24 horas" },
              user: { "$ref" => "#/components/schemas/user" }
            },
            required: %w[token user]
          }
        }
      },
      servers: [
        { url: "/", description: "Este servidor" }
      ]
    }
  }

  config.openapi_format = :yaml
end
