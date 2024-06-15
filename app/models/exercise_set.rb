class ExerciseSet < ApplicationRecord
  belongs_to :workout, optional: true
  belongs_to :exercise, optional: true
  belongs_to :machine, optional: true
  has_many :arduino_data, class_name: 'ArduinoDatum'

end
