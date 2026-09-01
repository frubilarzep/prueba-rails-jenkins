require "swagger_helper"

RSpec.describe "Tasks API", type: :request do
  path "/tasks" do
    get "Lista todas las tareas" do
      tags "Tasks"
      produces "application/json"

      response "200", "tareas encontradas" do
        schema type: :array, items: { "$ref" => "#/components/schemas/task" }

        before { create_list(:task, 2) }

        run_test!
      end
    end

    post "Crea una tarea" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              completed: { type: :boolean }
            },
            required: %w[title]
          }
        },
        required: %w[task]
      }

      response "201", "tarea creada" do
        schema "$ref" => "#/components/schemas/task"

        let(:payload) { { task: { title: "Nueva tarea", description: "Detalle" } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:payload) { { task: { title: "" } } }

        run_test!
      end
    end
  end

  path "/tasks/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Obtiene una tarea" do
      tags "Tasks"
      produces "application/json"

      response "200", "tarea encontrada" do
        schema "$ref" => "#/components/schemas/task"

        let(:id) { create(:task).id }

        run_test!
      end

      response "404", "tarea no encontrada" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Actualiza una tarea" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              completed: { type: :boolean }
            }
          }
        },
        required: %w[task]
      }

      response "200", "tarea actualizada" do
        schema "$ref" => "#/components/schemas/task"

        let(:id) { create(:task).id }
        let(:payload) { { task: { completed: true } } }

        run_test!
      end

      response "422", "parámetros inválidos" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:task).id }
        let(:payload) { { task: { title: "" } } }

        run_test!
      end
    end

    delete "Elimina una tarea" do
      tags "Tasks"

      response "204", "tarea eliminada" do
        let(:id) { create(:task).id }

        run_test!
      end
    end
  end
end
