class AddWorkoutProtocolToWorkouts < ActiveRecord::Migration[7.1]
  def change
    add_reference :workouts, :workout_protocol, null: false, foreign_key: true
  end
end
