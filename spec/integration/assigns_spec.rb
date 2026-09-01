require "swagger_helper"

RSpec.describe "Assigns API", type: :request do
  path "/assigns" do
    get "Lista todos los assigns" do
      tags "Assigns"
      produces "application/json"

      response "200", "assigns encontrados" do
        schema type: :array, items: { "$ref" => "#/components/schemas/assign" }

        before { create_list(:assign, 2) }

        run_test!
      end
    end

    post "Crea un assign" do
      tags "Assigns"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          assign: {
            type: :object,
            properties: {
              titulo: { type: :string },
              fecha_inscripcion: { type: :string, format: :date }
            },
            required: %w[titulo]
          }
        },
        required: %w[assign]
      }

      response "201", "assign creado" do
        schema "$ref" => "#/components/schemas/assign"

        let(:payload) { { assign: { titulo: "Inscripción 2026", fecha_inscripcion: "2026-09-01" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:payload) { { assign: { titulo: "" } } }

        run_test!
      end
    end
  end

  path "/assigns/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Obtiene un assign" do
      tags "Assigns"
      produces "application/json"

      response "200", "assign encontrado" do
        schema "$ref" => "#/components/schemas/assign"

        let(:id) { create(:assign).id }

        run_test!
      end

      response "404", "assign no encontrado" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Actualiza un assign" do
      tags "Assigns"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          assign: {
            type: :object,
            properties: {
              titulo: { type: :string },
              fecha_inscripcion: { type: :string, format: :date }
            }
          }
        },
        required: %w[assign]
      }

      response "200", "assign actualizado" do
        schema "$ref" => "#/components/schemas/assign"

        let(:id) { create(:assign).id }
        let(:payload) { { assign: { titulo: "Inscripción actualizada" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:assign).id }
        let(:payload) { { assign: { titulo: "" } } }

        run_test!
      end
    end

    delete "Elimina un assign" do
      tags "Assigns"

      response "204", "assign eliminado" do
        let(:id) { create(:assign).id }

        run_test!
      end
    end
  end
end
