class RemoveGymIdFromPersonals < ActiveRecord::Migration[7.1]
  def change
    remove_column :personals, :gym_id, :bigint
  end
end
