class ProtocolExercise < ApplicationRecord
  belongs_to :workout_protocol
  belongs_to :exercise

  validates :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, presence: true
  validates :sets, :min_repetitions, :max_repetitions, numericality: { only_integer: true, greater_than: 0 }
  validates :exercise_id, presence: true
end
