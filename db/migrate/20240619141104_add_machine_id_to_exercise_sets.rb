class AddMachineIdToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_reference :exercise_sets, :machine, foreign_key: true
  end
end
