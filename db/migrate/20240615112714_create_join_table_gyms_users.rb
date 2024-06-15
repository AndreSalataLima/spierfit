class CreateJoinTableGymsUsers < ActiveRecord::Migration[6.0]
  def change
    create_join_table :gyms, :users do |t|
      t.index :gym_id
      t.index :user_id
    end
  end
end
