# Include in any controller that needs a signed-in user.
#
#   before_action :authenticate_request!
#
# Reads the JWT from `Authorization: Bearer <token>`, and exposes the user it
# belongs to as `current_user`. Responds 401 when the token is missing,
# invalid, expired or points to a user that no longer exists.
module Authenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_request!
    @current_user = user_from_token
    render_unauthorized unless @current_user
  end

  def user_from_token
    payload = JsonWebToken.decode(bearer_token)
    return nil unless payload

    User.find_by(id: payload[:sub])
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)
    token if scheme&.casecmp?("Bearer")
  end

  def render_unauthorized
    render json: { errors: [ "No autorizado" ] }, status: :unauthorized
  end
end
