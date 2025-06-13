FactoryBot.define do
  factory :workout_protocol do
    name            { "Protocolo #{Faker::Lorem.word}" }
    description     { Faker::Lorem.sentence }
    execution_goal  { rand(1..10) }
    association     :user
    association     :gym
  end
end
