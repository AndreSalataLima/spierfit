class ArduinoDatum < ApplicationRecord
  def change
    create_table :arduino_data do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
