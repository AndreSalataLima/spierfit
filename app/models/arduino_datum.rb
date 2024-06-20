class ArduinoDatum < ApplicationRecord
  belongs_to :exercise_set, optional: true, class_name: 'ExerciseSet'

end
