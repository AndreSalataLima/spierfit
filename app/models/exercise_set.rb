class ExerciseSet < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise
  belongs_to :machine
  has_many :arduino_data, class_name: 'ArduinoDatum'

  before_create :initialize_reps_per_series

  private

  def initialize_reps_per_series
    self.reps_per_series ||= {}
  end
end
