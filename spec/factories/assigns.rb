FactoryBot.define do
  factory :assign do
    titulo { "Sample assign" }
    fecha_inscripcion { Date.current }
  end
end
