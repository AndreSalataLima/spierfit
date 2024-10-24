class DropArduinoDataTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :arduino_data
  end
end
