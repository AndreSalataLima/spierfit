class Workout < ApplicationRecord
  belongs_to :user
  belongs_to :personal, optional: true
  belongs_to :gym, optional: true
  has_many :exercise_sets
  has_many :exercises, through: :exercise_sets
end
