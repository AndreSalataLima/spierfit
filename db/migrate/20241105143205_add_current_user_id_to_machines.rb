class AddCurrentUserIdToMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :machines, :current_user_id, :integer
  end
end
