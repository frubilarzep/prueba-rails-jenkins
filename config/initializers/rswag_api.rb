Rswag::Api.configure do |c|
  # Folder where the OpenAPI files served by the /api-docs middleware live.
  # rswag-specs (see spec/swagger_helper.rb) generates them into the same folder.
  c.openapi_root = Rails.root.join("swagger").to_s
end
