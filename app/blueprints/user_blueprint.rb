# Public representation of a User. Deliberately leaves out password_digest
# and timestamps: only what the API contract documents in Swagger
# (components/schemas/user).
class UserBlueprint < ApplicationBlueprint
  identifier :id

  fields :email
end
