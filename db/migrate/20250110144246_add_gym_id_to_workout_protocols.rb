class AddGymIdToWorkoutProtocols < ActiveRecord::Migration[7.1]
  def change
    add_column :workout_protocols, :gym_id, :integer
    add_foreign_key :workout_protocols, :gyms
    add_index :workout_protocols, :gym_id
  end
end
