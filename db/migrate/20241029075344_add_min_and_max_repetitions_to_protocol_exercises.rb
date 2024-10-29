class AddMinAndMaxRepetitionsToProtocolExercises < ActiveRecord::Migration[7.1]
  def change
    add_column :protocol_exercises, :min_repetitions, :integer
    add_column :protocol_exercises, :max_repetitions, :integer
  end
end
