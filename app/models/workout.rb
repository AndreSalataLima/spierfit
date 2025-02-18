class Workout < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :personal, optional: true
  belongs_to :gym, optional: true
  has_many :exercise_sets
  has_many :exercises, through: :exercise_sets
  belongs_to :workout_protocol, optional: true

  def total_distance
    exercise_sets.joins(:data_points).sum('data_points.value')
  end

  def total_duration
    exercise_sets.sum(:duration)
  end

  validates :workout_protocol_id, presence: true

end
