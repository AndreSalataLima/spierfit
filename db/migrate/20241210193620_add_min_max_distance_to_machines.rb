class AddMinMaxDistanceToMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :machines, :min_distance, :integer
    add_column :machines, :max_distance, :integer
  end
end
