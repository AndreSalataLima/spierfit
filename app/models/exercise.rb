class Exercise < ApplicationRecord
  has_many :exercise_sets
  has_many :workouts, through: :exercise_sets
end
