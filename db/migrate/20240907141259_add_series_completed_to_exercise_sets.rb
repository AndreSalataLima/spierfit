class AddSeriesCompletedToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :series_completed, :boolean, default: false
  end
end
