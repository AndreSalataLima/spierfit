class AddMissingColumnsToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :reps, :integer
    add_column :exercise_sets, :sets, :integer
    add_column :exercise_sets, :weight, :integer
    add_column :exercise_sets, :duration, :integer
    add_column :exercise_sets, :rest_time, :integer
    add_column :exercise_sets, :intensity, :string
    add_column :exercise_sets, :feedback, :text
    add_column :exercise_sets, :max_reps, :integer
    add_column :exercise_sets, :effort_level, :string
    add_column :exercise_sets, :current_series, :integer, default: 1
    add_column :exercise_sets, :series_completed, :boolean, default: false
  end
end
