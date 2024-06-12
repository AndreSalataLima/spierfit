class Exercise < ApplicationRecord
  has_many :exercise_sets, dependent: :nullify
  has_many :workouts, through: :exercise_sets
end
