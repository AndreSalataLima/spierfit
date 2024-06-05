class ChangeForeignKeyOnUsersAndWorkouts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :gym_id, true
    change_column_null :workouts, :gym_id, true

    remove_foreign_key :users, :gyms
    add_foreign_key :users, :gyms, on_delete: :nullify

    remove_foreign_key :users, :personals
    add_foreign_key :users, :personals, on_delete: :nullify

    remove_foreign_key :workouts, :gyms
    add_foreign_key :workouts, :gyms, on_delete: :nullify
  end
end
