# Response body of POST /auth/register and POST /auth/login
# (components/schemas/session in Swagger): the signed JWT plus the user it
# belongs to, rendered with UserBlueprint.
class SessionBlueprint < ApplicationBlueprint
  fields :token

  association :user, blueprint: UserBlueprint
end
