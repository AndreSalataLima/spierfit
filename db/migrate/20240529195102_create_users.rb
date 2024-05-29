class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :phone
      t.string :address
      t.string :status
      t.date :date_of_birth
      t.integer :height
      t.integer :weight
      t.references :gym, null: false, foreign_key: true
      # t.references :personal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
