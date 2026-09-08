class AuthController < ApplicationController
  include Authenticable

  before_action :authenticate_request!, only: :me

  # POST /auth/register
  def register
    user = User.new(register_params)

    if user.save
      render json: session_payload(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  # POST /auth/login
  def login
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password].to_s)
      render json: session_payload(user), status: :ok
    else
      render json: { errors: [ "Credenciales inválidas" ] }, status: :unauthorized
    end
  end

  # GET /auth/me
  def me
    render json: { user: current_user }, status: :ok
  end

  private

  def register_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def session_payload(user)
    { token: JsonWebToken.encode({ sub: user.id }), user: user }
  end
end
