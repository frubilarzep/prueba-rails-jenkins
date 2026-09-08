Rails.application.routes.draw do
  # Swagger UI and the OpenAPI spec it serves, both under /api-docs
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Used by the deploy pipeline's Health Check stage. Returns a plain
  # JSON stub with no dependency checks (no DB, etc).
  get "health" => "health#show"

  # JWT authentication (see docs/specs/SCRUM-12-autenticacion-jwt-swagger.md)
  post "auth/register" => "auth#register"
  post "auth/login" => "auth#login"
  get "auth/me" => "auth#me"
end
