class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      # t.string :email, null: false
      # t.string :password_digest
      t.string :phone
      t.string :address
      t.string :status
      t.date :date_of_birth
      t.integer :height
      t.integer :weight
      t.references :gym, foreign_key: { on_delete: :nullify }
      # t.string :encrypted_password, default: "", null: false
      # t.string :reset_password_token
      # t.datetime :reset_password_sent_at
      # t.datetime :remember_created_at

      t.timestamps
    end

    # add_index :users, :email, unique: true
    # add_index :users, :reset_password_token, unique: true
  end
end
