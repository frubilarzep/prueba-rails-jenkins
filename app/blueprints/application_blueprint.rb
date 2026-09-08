# Base class for every serializer in app/blueprints.
#
# A blueprint declares which fields of an object go out as JSON, so the
# models don't need to override `as_json` and controllers don't build hashes
# by hand. Usage from a controller:
#
#   render json: UserBlueprint.render_as_hash(user, root: :user)
#
# See docs/specs/SCRUM-13-blueprinter.md.
class ApplicationBlueprint < Blueprinter::Base
end
