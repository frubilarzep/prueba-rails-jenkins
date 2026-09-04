require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with an email and a password of at least 8 characters" do
    expect(build(:user)).to be_valid
  end

  it "requires an email" do
    user = build(:user, email: "")
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "rejects a malformed email" do
    expect(build(:user, email: "no-es-un-email")).not_to be_valid
  end

  it "normalizes the email to lowercase and strips whitespace" do
    user = create(:user, email: "  Ana@Example.COM ")
    expect(user.email).to eq("ana@example.com")
  end

  it "enforces a unique email regardless of case" do
    create(:user, email: "ana@example.com")
    expect(build(:user, email: "ANA@example.com")).not_to be_valid
  end

  it "requires a password of at least 8 characters" do
    user = build(:user, password: "corta")
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
  end

  it "authenticates with the right password and rejects the wrong one" do
    user = create(:user, password: "secreto123")
    expect(user.authenticate("secreto123")).to eq(user)
    expect(user.authenticate("otra")).to be(false)
  end

  it "only exposes id and email as JSON" do
    user = create(:user)
    expect(user.as_json.keys).to contain_exactly("id", "email")
  end
end
