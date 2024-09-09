class RenamePerformanceScoreAndAddPowerInWattsToExerciseSets < ActiveRecord::Migration[7.1]
  def change
    # Renomear a coluna performance_score para average_force
    rename_column :exercise_sets, :performance_score, :average_force

    # Adicionar uma nova coluna para potência (em watts)
    add_column :exercise_sets, :power_in_watts, :float
  end
end
