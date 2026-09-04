Rswag::Ui.configure do |c|
  # OpenAPI documents listed in the Swagger UI selector. Paths are relative to
  # the rswag-api mount point (/api-docs).
  c.openapi_endpoint "/api-docs/v1/swagger.yaml", "API V1 Docs"
end
