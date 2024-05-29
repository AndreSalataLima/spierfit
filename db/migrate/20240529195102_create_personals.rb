class CreatePersonals < ActiveRecord::Migration[7.1]
  def change
    create_table :personals do |t|
      t.references :user, null: false, foreign_key: true
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

      t.timestamps
    end
  end
end
