FactoryBot.define do
  factory :protocol_exercise do
    association  :workout_protocol
    association  :exercise
    muscle_group { Faker::Lorem.word }
    sets          { rand(1..5) }
    min_repetitions { rand(5..10) }
    max_repetitions { rand(11..15) }
    day           { %w[Monday Tuesday Wednesday].sample }
    observation   { Faker::Lorem.sentence }
  end
end
