class AddRecordedAtToDataPoints < ActiveRecord::Migration[7.1]
  def change
    add_column :data_points, :recorded_at, :datetime
  end
end
