class FixPersonalIdForeignKeyInWorkoutProtocols < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :workout_protocols, column: :personal_id rescue nil

    add_foreign_key :workout_protocols, :users, column: :personal_id
  end
end
