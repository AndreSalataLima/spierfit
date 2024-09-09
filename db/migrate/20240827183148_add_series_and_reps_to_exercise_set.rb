class AddSeriesAndRepsToExerciseSet < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :current_series, :integer, default: 1
    add_column :exercise_sets, :reps_per_series, :jsonb, default: {}
  end
end
