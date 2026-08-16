require "rails_helper"

RSpec.describe Task, type: :model do
  it "is valid with a title" do
    expect(build(:task)).to be_valid
  end

  it "is invalid without a title" do
    expect(build(:task, title: nil)).not_to be_valid
  end
end
