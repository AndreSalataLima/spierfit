class AddMacAddressToMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :machines, :mac_address, :string
  end
end
