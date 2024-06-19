class Exercise < ApplicationRecord
  has_and_belongs_to_many :machines
  has_many :exercise_sets

end
