require "rails_helper"

RSpec.describe UserBlueprint do
  let(:user) { create(:user, email: "ana@example.com") }

  it "renders only id and email, in that order" do
    expect(described_class.render_as_hash(user)).to eq(id: user.id, email: "ana@example.com")
  end

  it "never leaks the password digest or timestamps" do
    expect(described_class.render_as_json(user).keys).to contain_exactly("id", "email")
  end

  it "wraps the payload when a root is given" do
    expect(described_class.render_as_hash(user, root: :user)).to eq(user: { id: user.id, email: "ana@example.com" })
  end

  it "renders collections as arrays" do
    other = create(:user, email: "bea@example.com")

    expect(described_class.render_as_hash([ user, other ]).pluck(:email)).to eq(%w[ana@example.com bea@example.com])
  end
end
