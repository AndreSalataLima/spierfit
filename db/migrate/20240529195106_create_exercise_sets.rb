class CreateExerciseSets < ActiveRecord::Migration[7.1]
  def change
    create_table :exercise_sets do |t|
      t.references :workout, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.integer :reps
      t.integer :sets
      t.integer :weight
      t.integer :duration
      t.integer :rest_time
      t.string :intensity
      t.text :feedback
      t.integer :max_reps
      t.integer :performance_score
      t.string :effort_level
      t.integer :energy_consumed

      t.timestamps
    end
  end
end
