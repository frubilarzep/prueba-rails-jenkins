FactoryBot.define do
  factory :person do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:rut) { |n| "#{10000000 + n}-#{n % 10}" }
    age { 30 }
    address { "123 Main St" }
  end
end
