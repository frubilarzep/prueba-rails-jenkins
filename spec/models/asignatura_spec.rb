require "rails_helper"

RSpec.describe Asignatura, type: :model do
  it "is valid with nombre, codigo, seccion and semestre" do
    expect(build(:asignatura)).to be_valid
  end

  it "is invalid without a nombre" do
    expect(build(:asignatura, nombre: nil)).not_to be_valid
  end

  it "is invalid without a codigo" do
    expect(build(:asignatura, codigo: nil)).not_to be_valid
  end

  it "is invalid without a seccion" do
    expect(build(:asignatura, seccion: nil)).not_to be_valid
  end

  it "is invalid with a seccion that is not a positive integer" do
    expect(build(:asignatura, seccion: 0)).not_to be_valid
    expect(build(:asignatura, seccion: -1)).not_to be_valid
  end

  it "is invalid without a semestre" do
    expect(build(:asignatura, semestre: nil)).not_to be_valid
  end

  it "is invalid with a duplicate codigo in the same seccion and semestre" do
    create(:asignatura, codigo: "ASI-999", seccion: 1, semestre: "2026-2")

    expect(build(:asignatura, codigo: "ASI-999", seccion: 1, semestre: "2026-2")).not_to be_valid
  end

  it "is valid with the same codigo in a different seccion" do
    create(:asignatura, codigo: "ASI-999", seccion: 1, semestre: "2026-2")

    expect(build(:asignatura, codigo: "ASI-999", seccion: 2, semestre: "2026-2")).to be_valid
  end
end
