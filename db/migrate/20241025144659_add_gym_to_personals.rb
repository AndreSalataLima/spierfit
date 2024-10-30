class AddGymToPersonals < ActiveRecord::Migration[7.1]
  def change
    add_reference :personals, :gym, null: false, foreign_key: true
  end
end
