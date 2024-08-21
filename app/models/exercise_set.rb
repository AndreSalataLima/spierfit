# app/models/exercise_set.rb
class ExerciseSet < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise
  belongs_to :machine
  has_many :series, dependent: :destroy
  accepts_nested_attributes_for :series, allow_destroy: true
  has_many :arduino_data, class_name: 'ArduinoDatum'
end
