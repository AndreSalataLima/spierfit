class AddMissingColumnsToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    # Check if the columns exist before adding them
    add_column :exercise_sets, :reps, :integer unless column_exists?(:exercise_sets, :reps)
    add_column :exercise_sets, :sets, :integer unless column_exists?(:exercise_sets, :sets)
    add_column :exercise_sets, :weight, :integer unless column_exists?(:exercise_sets, :weight)
    add_column :exercise_sets, :duration, :integer unless column_exists?(:exercise_sets, :duration)
    add_column :exercise_sets, :rest_time, :integer unless column_exists?(:exercise_sets, :rest_time)
    add_column :exercise_sets, :intensity, :string unless column_exists?(:exercise_sets, :intensity)
    add_column :exercise_sets, :feedback, :text unless column_exists?(:exercise_sets, :feedback)
    add_column :exercise_sets, :max_reps, :integer unless column_exists?(:exercise_sets, :max_reps)
    add_column :exercise_sets, :effort_level, :string unless column_exists?(:exercise_sets, :effort_level)
    add_column :exercise_sets, :current_series, :integer, default: 1 unless column_exists?(:exercise_sets, :current_series)
    add_column :exercise_sets, :series_completed, :boolean, default: false unless column_exists?(:exercise_sets, :series_completed)
  end
end
