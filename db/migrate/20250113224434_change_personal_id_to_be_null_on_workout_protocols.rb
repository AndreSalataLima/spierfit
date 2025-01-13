class ChangePersonalIdToBeNullOnWorkoutProtocols < ActiveRecord::Migration[7.1]
  def change
    change_column_null :workout_protocols, :personal_id, true
  end
end
