class CreateProtocolExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :protocol_exercises do |t|
      t.references :workout_protocol, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.string :muscle_group
      t.integer :sets
      t.integer :repetitions
      t.string :day
      t.text :observation

      t.timestamps
    end
  end
end
