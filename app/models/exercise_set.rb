class ExerciseSet < ApplicationRecord
  belongs_to :workout, optional: true
  belongs_to :exercise, optional: true
end
