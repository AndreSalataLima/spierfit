class AddWeightChangesToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :weight_changes, :json, default: []
  end
end
