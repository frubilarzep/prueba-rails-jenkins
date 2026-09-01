class Person < ApplicationRecord
  validates :name, presence: true
  validates :rut, presence: true, uniqueness: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
