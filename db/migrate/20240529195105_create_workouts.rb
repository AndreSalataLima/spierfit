class CreateWorkouts < ActiveRecord::Migration[7.1]
  def change
    create_table :workouts do |t|
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      t.references :personal, null: true, foreign_key: { on_delete: :nullify }
      t.references :gym, null: true, foreign_key: { on_delete: :nullify }
      t.string :workout_type
      t.string :goal
      t.integer :duration
      t.integer :calories_burned
      t.string :intensity
      t.text :feedback
      t.text :modifications
      t.string :intensity_general
      t.string :difficulty_perceived
      t.integer :performance_score
      t.text :auto_adjustments

      t.timestamps
    end
  end
end
