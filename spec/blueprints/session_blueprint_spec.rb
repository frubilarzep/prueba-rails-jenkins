require "rails_helper"

RSpec.describe SessionBlueprint do
  let(:user) { create(:user, email: "ana@example.com") }
  let(:session) { AuthSession.for(user) }

  it "renders the token and the user through UserBlueprint" do
    payload = described_class.render_as_hash(session)

    expect(payload.keys).to eq(%i[token user])
    expect(payload[:user]).to eq(id: user.id, email: "ana@example.com")
    expect(JsonWebToken.decode(payload[:token])[:sub]).to eq(user.id)
  end

  it "matches the shape documented as components/schemas/session" do
    json = JSON.parse(described_class.render(session))

    expect(json).to match("token" => a_kind_of(String), "user" => { "id" => user.id, "email" => "ana@example.com" })
  end
end
