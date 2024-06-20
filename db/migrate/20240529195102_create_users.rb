class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :phone
      t.string :address
      t.string :status
      t.date :date_of_birth
      t.integer :height
      t.integer :weight
      t.references :gym, foreign_key: { optional: true }

      t.timestamps
    end
  end
end
