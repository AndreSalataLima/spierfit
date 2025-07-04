class WorkoutProtocol < ApplicationRecord
  belongs_to :user
  belongs_to :personal, optional: true
  belongs_to :gym

  has_many :protocol_exercises, dependent: :destroy
  has_many :workouts, dependent: :nullify

  accepts_nested_attributes_for :protocol_exercises, allow_destroy: true#, reject_if: proc { |attributes| attributes['exercise_id'].blank? }

  validates :name, presence: true
  validates :execution_goal, numericality: { only_integer: true, greater_than: 0 }
end
