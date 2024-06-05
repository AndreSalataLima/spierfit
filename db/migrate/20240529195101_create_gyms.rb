class CreateGyms < ActiveRecord::Migration[7.1]
  def change
    create_table :gyms do |t|
      t.string :name, null: false
      t.string :location
      t.text :contact_info
      t.text :hours_of_operation
      t.text :equipment_list
      t.text :policies
      t.text :subscriptions
      t.text :photos, null: false
      t.text :events
      t.integer :capacity, null: false
      t.text :safety_protocols

      t.timestamps
    end
  end
end
