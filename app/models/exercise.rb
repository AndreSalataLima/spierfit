class Exercise < ApplicationRecord
  has_many :exercise_sets
  has_and_belongs_to_many :machines

end
