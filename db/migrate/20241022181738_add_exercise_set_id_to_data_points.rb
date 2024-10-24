class AddExerciseSetIdToDataPoints < ActiveRecord::Migration[7.1]
  def change
    add_column :data_points, :exercise_set_id, :bigint
    add_index :data_points, :exercise_set_id
    add_foreign_key :data_points, :exercise_sets
  end
end
