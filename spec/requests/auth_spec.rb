require "rails_helper"

RSpec.describe "Auth", type: :request do
  let(:json) { JSON.parse(response.body) }

  describe "POST /auth/register" do
    let(:valid_params) do
      { user: { email: "ana@example.com", password: "secreto123", password_confirmation: "secreto123" } }
    end

    it "creates the user and returns a usable token" do
      expect { post "/auth/register", params: valid_params }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["user"]).to eq("id" => User.last.id, "email" => "ana@example.com")
      expect(JsonWebToken.decode(json["token"])[:sub]).to eq(User.last.id)
    end

    it "returns 422 when the email is already taken" do
      create(:user, email: "ana@example.com")

      post "/auth/register", params: valid_params

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to include("Email has already been taken")
    end

    it "returns 422 when the password is too short" do
      post "/auth/register", params: { user: { email: "ana@example.com", password: "corta" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to include("Password is too short (minimum is 8 characters)")
    end

    it "returns 422 when the confirmation does not match" do
      post "/auth/register", params: { user: { email: "ana@example.com", password: "secreto123", password_confirmation: "otra" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to include("Password confirmation doesn't match Password")
    end
  end

  describe "POST /auth/login" do
    let!(:user) { create(:user, email: "ana@example.com", password: "secreto123") }

    it "returns a token for valid credentials" do
      post "/auth/login", params: { email: "Ana@Example.com", password: "secreto123" }

      expect(response).to have_http_status(:ok)
      expect(json["user"]).to eq("id" => user.id, "email" => "ana@example.com")
      expect(JsonWebToken.decode(json["token"])[:sub]).to eq(user.id)
    end

    it "returns 401 for a wrong password" do
      post "/auth/login", params: { email: "ana@example.com", password: "incorrecta" }

      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("errors" => [ "Credenciales inválidas" ])
    end

    it "returns the same 401 for an unknown email" do
      post "/auth/login", params: { email: "nadie@example.com", password: "secreto123" }

      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("errors" => [ "Credenciales inválidas" ])
    end
  end

  describe "GET /auth/me" do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode({ sub: user.id }) }

    it "returns the current user for a valid bearer token" do
      get "/auth/me", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(json).to eq("user" => { "id" => user.id, "email" => user.email })
    end

    it "returns 401 without an Authorization header" do
      get "/auth/me"

      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("errors" => [ "No autorizado" ])
    end

    it "returns 401 for a non-Bearer scheme" do
      get "/auth/me", headers: { "Authorization" => "Basic #{token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for a malformed token" do
      get "/auth/me", headers: { "Authorization" => "Bearer basura" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for an expired token" do
      expired = JsonWebToken.encode({ sub: user.id }, exp: 1.minute.ago)

      get "/auth/me", headers: { "Authorization" => "Bearer #{expired}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 when the user no longer exists" do
      user.destroy!

      get "/auth/me", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
