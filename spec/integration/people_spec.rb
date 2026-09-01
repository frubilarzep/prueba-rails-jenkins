require "swagger_helper"

RSpec.describe "People API", type: :request do
  path "/people" do
    get "Lista todas las personas" do
      tags "People"
      produces "application/json"

      response "200", "personas encontradas" do
        schema type: :array, items: { "$ref" => "#/components/schemas/person" }

        before { create_list(:person, 2) }

        run_test!
      end
    end

    post "Crea una persona" do
      tags "People"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          person: {
            type: :object,
            properties: {
              name: { type: :string },
              rut: { type: :string },
              age: { type: :integer },
              address: { type: :string }
            },
            required: %w[name rut]
          }
        },
        required: %w[person]
      }

      response "201", "persona creada" do
        schema "$ref" => "#/components/schemas/person"

        let(:payload) { { person: { name: "Juana Pérez", rut: "12345678-9", age: 30, address: "Av. Siempre Viva 742" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:payload) { { person: { name: "" } } }

        run_test!
      end
    end
  end

  path "/people/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Obtiene una persona" do
      tags "People"
      produces "application/json"

      response "200", "persona encontrada" do
        schema "$ref" => "#/components/schemas/person"

        let(:id) { create(:person).id }

        run_test!
      end

      response "404", "persona no encontrada" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Actualiza una persona" do
      tags "People"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          person: {
            type: :object,
            properties: {
              name: { type: :string },
              rut: { type: :string },
              age: { type: :integer },
              address: { type: :string }
            }
          }
        },
        required: %w[person]
      }

      response "200", "persona actualizada" do
        schema "$ref" => "#/components/schemas/person"

        let(:id) { create(:person).id }
        let(:payload) { { person: { age: 31 } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:person).id }
        let(:payload) { { person: { name: "" } } }

        run_test!
      end
    end

    delete "Elimina una persona" do
      tags "People"

      response "204", "persona eliminada" do
        let(:id) { create(:person).id }

        run_test!
      end
    end
  end
end
