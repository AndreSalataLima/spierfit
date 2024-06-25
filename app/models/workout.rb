class Workout < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :personal, optional: true
  belongs_to :gym, optional: true
  has_many :exercise_sets
  has_many :exercises, through: :exercise_sets

  def total_distance
    exercise_sets.joins(:arduino_data).sum('arduino_data.value')
  end

  def total_duration
    exercise_sets.sum(:duration)
  end
  
end
