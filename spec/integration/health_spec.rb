require "swagger_helper"

RSpec.describe "Health API", type: :request do
  path "/health" do
    get "Estado de la aplicación (usado por el Health Check del deploy)" do
      tags "Health"
      produces "application/json"

      response "200", "la aplicación responde" do
        schema type: :object,
               properties: { status: { type: :string, enum: %w[ok] } },
               required: %w[status]

        run_test!
      end
    end
  end

  path "/up" do
    get "Health check de Rails (200 si la app arranca sin excepciones)" do
      tags "Health"
      produces "text/html"

      response "200", "la aplicación arrancó correctamente" do
        run_test!
      end
    end
  end
end
