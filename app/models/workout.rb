class Workout < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :personal, optional: true
  belongs_to :gym, optional: true
  has_many :exercise_sets, dependent: :nullify
  has_many :exercises, through: :exercise_sets
end
