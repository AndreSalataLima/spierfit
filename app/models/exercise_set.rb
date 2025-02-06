class ExerciseSet < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise
  belongs_to :machine, optional: true
  has_many :data_points


  validates :reps, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sets, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  
  before_create :initialize_reps_per_series

  private

  def initialize_reps_per_series
    self.reps_per_series ||= {}
  end
end
