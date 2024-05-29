class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string :name
      t.text :description
      t.string :muscle_group
      t.string :difficulty
      t.text :instructions
      t.text :variants
      t.text :equipment_needed
      t.text :contraindications
      t.text :benefits
      t.integer :duration_suggested
      t.integer :frequency_recommended
      t.text :progression_levels

      t.timestamps
    end
  end
end
