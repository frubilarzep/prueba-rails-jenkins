require "rails_helper"

RSpec.describe Person, type: :model do
  it "is valid with a name and rut" do
    expect(build(:person)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:person, name: nil)).not_to be_valid
  end

  it "is invalid without a rut" do
    expect(build(:person, rut: nil)).not_to be_valid
  end

  it "is invalid with a duplicate rut" do
    create(:person, rut: "11111111-1")

    expect(build(:person, rut: "11111111-1")).not_to be_valid
  end

  it "is invalid with a negative age" do
    expect(build(:person, age: -1)).not_to be_valid
  end
end
