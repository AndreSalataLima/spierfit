class CreateMachines < ActiveRecord::Migration[7.1]
  def change
    create_table :machines do |t|
      t.string :name, null: false
      t.text :description
      t.text :compatible_exercises, array: true, default: []
      t.string :status, default: "active"
      t.timestamps
      t.references :gym, foreign_key: { optional: true }
    end
  end
end
