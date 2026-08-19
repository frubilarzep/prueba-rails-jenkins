require "rails_helper"

RSpec.describe Assign, type: :model do
  it "is valid with a titulo" do
    expect(build(:assign)).to be_valid
  end

  it "is invalid without a titulo" do
    expect(build(:assign, titulo: nil)).not_to be_valid
  end
end
