class Asignatura < ApplicationRecord
  validates :nombre, presence: true
  validates :codigo, presence: true, uniqueness: { scope: %i[seccion semestre] }
  validates :seccion, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :semestre, presence: true
end
