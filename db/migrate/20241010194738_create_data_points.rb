class CreateDataPoints < ActiveRecord::Migration[7.1]
  def change
    create_table :data_points do |t|
      t.integer :value

      t.timestamps
    end
  end
end
