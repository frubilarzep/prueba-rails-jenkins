FactoryBot.define do
  factory :task do
    title { "Sample task" }
    description { "Sample task description" }
    completed { false }
  end
end
