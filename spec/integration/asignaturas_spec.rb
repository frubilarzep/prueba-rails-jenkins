require "swagger_helper"

RSpec.describe "Asignaturas API", type: :request do
  path "/asignaturas" do
    get "Lista todas las asignaturas" do
      tags "Asignaturas"
      produces "application/json"

      response "200", "asignaturas encontradas" do
        schema type: :array, items: { "$ref" => "#/components/schemas/asignatura" }

        before { create_list(:asignatura, 2) }

        run_test!
      end
    end

    post "Crea una asignatura" do
      tags "Asignaturas"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          asignatura: {
            type: :object,
            properties: {
              nombre: { type: :string },
              codigo: { type: :string },
              seccion: { type: :integer },
              semestre: { type: :string }
            },
            required: %w[nombre codigo seccion semestre]
          }
        },
        required: %w[asignatura]
      }

      response "201", "asignatura creada" do
        schema "$ref" => "#/components/schemas/asignatura"

        let(:payload) do
          { asignatura: { nombre: "Cálculo I", codigo: "MAT-101", seccion: 1, semestre: "2026-2" } }
        end

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:payload) { { asignatura: { nombre: "" } } }

        run_test!
      end
    end
  end

  path "/asignaturas/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Obtiene una asignatura" do
      tags "Asignaturas"
      produces "application/json"

      response "200", "asignatura encontrada" do
        schema "$ref" => "#/components/schemas/asignatura"

        let(:id) { create(:asignatura).id }

        run_test!
      end

      response "404", "asignatura no encontrada" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Actualiza una asignatura" do
      tags "Asignaturas"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          asignatura: {
            type: :object,
            properties: {
              nombre: { type: :string },
              codigo: { type: :string },
              seccion: { type: :integer },
              semestre: { type: :string }
            }
          }
        },
        required: %w[asignatura]
      }

      response "200", "asignatura actualizada" do
        schema "$ref" => "#/components/schemas/asignatura"

        let(:id) { create(:asignatura).id }
        let(:payload) { { asignatura: { nombre: "Cálculo II" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:asignatura).id }
        let(:payload) { { asignatura: { nombre: "" } } }

        run_test!
      end
    end

    delete "Elimina una asignatura" do
      tags "Asignaturas"

      response "204", "asignatura eliminada" do
        let(:id) { create(:asignatura).id }

        run_test!
      end
    end
  end
end
