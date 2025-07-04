class CreatePersonals < ActiveRecord::Migration[7.1]
  def change
    create_table :personals do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest
      t.string :specialization
      t.text :availability
      t.text :bio
      t.string :rating
      t.string :languages
      t.string :emergency_contact
      t.integer :current_clients
      t.text :certifications
      t.text :photos
      t.text :plans
      t.text :achievements
      t.references :user, foreign_key: { optional: true }

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :personals, :email,                unique: true
    add_index :personals, :reset_password_token, unique: true
    # add_index :personals, :confirmation_token,   unique: true
    # add_index :personals, :unlock_token,         unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
  
end
