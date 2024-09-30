class AddInSeriesToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :in_series, :boolean, default: false
  end
end
