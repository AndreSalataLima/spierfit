class AddLastProcessedDataIdToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    add_column :exercise_sets, :last_processed_data_id, :integer
  end
end
