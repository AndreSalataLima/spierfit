class AddProtocolDayToWorkouts < ActiveRecord::Migration[7.1]
  def change
    add_column :workouts, :protocol_day, :string
  end
end
