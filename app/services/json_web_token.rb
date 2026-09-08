# Encodes and decodes the JWTs used to authenticate API requests.
#
# Tokens are signed with HS256 using the app's secret_key_base and expire
# 24 hours after issue. `decode` returns nil for any invalid token (bad
# signature, expired, malformed) so callers only need a nil check.
module JsonWebToken
  ALGORITHM = "HS256".freeze
  DEFAULT_TTL = 24.hours

  module_function

  def encode(payload, exp: DEFAULT_TTL.from_now)
    now = Time.current.to_i
    JWT.encode(payload.merge(iat: now, exp: exp.to_i), secret, ALGORITHM)
  end

  def decode(token)
    return nil if token.blank?

    decoded, = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    decoded.with_indifferent_access
  rescue JWT::DecodeError
    nil
  end

  def secret
    Rails.application.secret_key_base
  end
end
