class CreateGymsPersonalsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :gyms, :personals do |t|
      t.index [:gym_id, :personal_id], unique: true
      t.index [:personal_id, :gym_id]
    end
  end
end
