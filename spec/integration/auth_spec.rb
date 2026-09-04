require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  path "/auth/register" do
    post "Registra un usuario y devuelve un JWT" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, minLength: 8 },
              password_confirmation: { type: :string }
            },
            required: %w[email password]
          }
        },
        required: %w[user]
      }

      response "201", "usuario creado" do
        schema "$ref" => "#/components/schemas/session"

        let(:payload) { { user: { email: "ana@example.com", password: "secreto123", password_confirmation: "secreto123" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:payload) { { user: { email: "ana@example.com", password: "corta" } } }

        run_test!
      end
    end
  end

  path "/auth/login" do
    post "Inicia sesión y devuelve un JWT" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string }
        },
        required: %w[email password]
      }

      before { create(:user, email: "ana@example.com", password: "secreto123") }

      response "200", "credenciales válidas" do
        schema "$ref" => "#/components/schemas/session"

        let(:credentials) { { email: "ana@example.com", password: "secreto123" } }

        run_test!
      end

      response "401", "credenciales inválidas" do
        schema "$ref" => "#/components/schemas/errors"

        let(:credentials) { { email: "ana@example.com", password: "incorrecta" } }

        run_test!
      end
    end
  end

  path "/auth/me" do
    get "Devuelve el usuario autenticado" do
      tags "Auth"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:user) { create(:user) }

      response "200", "token válido" do
        schema type: :object,
               properties: { user: { "$ref" => "#/components/schemas/user" } },
               required: %w[user]

        let(:Authorization) { "Bearer #{JsonWebToken.encode({ sub: user.id })}" }

        run_test!
      end

      response "401", "token ausente, inválido o expirado" do
        schema "$ref" => "#/components/schemas/errors"

        let(:Authorization) { "Bearer token-invalido" }

        run_test!
      end
    end
  end
end
