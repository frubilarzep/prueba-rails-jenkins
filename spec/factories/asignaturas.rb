FactoryBot.define do
  factory :asignatura do
    sequence(:nombre) { |n| "Asignatura #{n}" }
    sequence(:codigo) { |n| "ASI-#{100 + n}" }
    seccion { 1 }
    semestre { "2026-2" }
  end
end
