class AddCompletedToExerciseSetsAndWorkouts < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :completed, :boolean, default: false
    add_column :workouts, :completed, :boolean, default: false
  end
end
