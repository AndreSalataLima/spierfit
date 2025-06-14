FactoryBot.define do
  factory :workout do
    association :user
    association :gym
    association :workout_protocol

    workout_type       { 'cardio' }
    goal               { 'Lose weight' }
    duration           { 60 }
    calories_burned    { 500 }
    intensity          { 'medium' }
    feedback           { 'Feeling good' }
    modifications      { '' }
    intensity_general  { 'moderate' }
    difficulty_perceived { 'medium' }
    performance_score  { 80 }
    auto_adjustments   { '{}' }
    completed          { false }
    protocol_day       { 'Day 1' }
  end
end
