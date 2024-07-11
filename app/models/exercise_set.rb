class ExerciseSet < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise
  belongs_to :machine
  has_many :arduino_data, class_name: 'ArduinoDatum'
end
