# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Prueba Rails Jenkins API',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          errors: {
            type: :object,
            properties: {
              errors: { type: :array, items: { type: :string } }
            },
            required: %w[errors]
          },
          task: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string, nullable: true },
              completed: { type: :boolean },
              cosa: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id title]
          },
          asignatura: {
            type: :object,
            properties: {
              id: { type: :integer },
              nombre: { type: :string },
              codigo: { type: :string },
              seccion: { type: :integer },
              semestre: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id nombre codigo seccion semestre]
          },
          assign: {
            type: :object,
            properties: {
              id: { type: :integer },
              titulo: { type: :string },
              fecha_inscripcion: { type: :string, format: 'date', nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id titulo]
          },
          person: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              rut: { type: :string },
              age: { type: :integer, nullable: true },
              address: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name rut]
          }
        }
      },
      servers: [
        # Relative URL so "Try it out" targets whichever host serves the docs
        # (localhost in development, the container host in the deploy).
        { url: '/' }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
