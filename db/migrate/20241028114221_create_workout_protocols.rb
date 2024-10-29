class CreateWorkoutProtocols < ActiveRecord::Migration[7.1]
  def change
    create_table :workout_protocols do |t|
      t.string :name
      t.text :description
      t.integer :execution_goal
      t.references :user, null: false, foreign_key: true
      t.references :personal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
