class CreateExercisesMachinesJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises_machines, id: false do |t|
      t.bigint :exercise_id, null: false
      t.bigint :machine_id, null: false
    end

    add_index :exercises_machines, :exercise_id
    add_index :exercises_machines, :machine_id
    add_index :exercises_machines, [:exercise_id, :machine_id], unique: true
  end
end
