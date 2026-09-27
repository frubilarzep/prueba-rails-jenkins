require "rails_helper"

RSpec.describe "API docs", type: :request do
  describe "GET /api-docs" do
    it "serves the Swagger UI" do
      get "/api-docs/index.html"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("swagger-ui")
    end
  end

  describe "GET /api-docs/v1/swagger.yaml" do
    let(:document) { YAML.safe_load(response.body) }

    before { get "/api-docs/v1/swagger.yaml" }

    it "serves the OpenAPI document" do
      expect(response).to have_http_status(:ok)
      expect(document["openapi"]).to eq("3.0.1")
    end

    it "documents every API endpoint" do
      expect(document["paths"].keys).to contain_exactly(
        "/auth/register", "/auth/login", "/auth/me", "/health", "/up"
      )
    end

    it "includes method, parameters, responses and status codes" do
      register = document.dig("paths", "/auth/register", "post")

      expect(register.dig("requestBody", "content", "application/json", "schema")).to be_present
      expect(register["responses"].keys).to contain_exactly("201", "422")
    end
  end
end
