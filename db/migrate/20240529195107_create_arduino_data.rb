class CreateArduinoData < ActiveRecord::Migration[7.1]
  def change
    create_table :arduino_data do |t|
      t.float :value
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
