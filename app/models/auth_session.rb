# Value object handed to SessionBlueprint after a successful register/login.
# It is not persisted; the token itself carries everything the API needs.
AuthSession = Data.define(:token, :user) do
  def self.for(user)
    new(token: JsonWebToken.encode({ sub: user.id }), user: user)
  end
end
