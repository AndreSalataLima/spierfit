class AddMacAddressToDataPoints < ActiveRecord::Migration[7.1]
  def change
    add_column :data_points, :mac_address, :string
  end
end
