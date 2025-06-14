FactoryBot.define do
  factory :exercise_set do
    association :workout
    association :exercise

    average_force     { 100 }
    energy_consumed   { 50 }
    sets              { 3 }
    reps_per_series   { { series1: 10, series2: 8, series3: 6 } }
    power_in_watts    { 200.5 }
    reps              { 10 }
    weight            { 20 }
    duration          { 30 }
    rest_time         { 60 }
    intensity         { 'hard' }
    feedback          { 'Tiring' }
    completed         { false }
    current_series    { 1 }
    series_completed  { false }
    in_series         { true }
  end
end
