# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_09_09_173939) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arduino_data", force: :cascade do |t|
    t.float "value"
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exercise_set_id"
    t.index ["exercise_set_id"], name: "index_arduino_data_on_exercise_set_id"
  end

  create_table "exercise_sets", force: :cascade do |t|
    t.bigint "workout_id"
    t.bigint "exercise_id"
    t.integer "reps"
    t.integer "sets"
    t.integer "weight"
    t.integer "duration"
    t.integer "rest_time"
    t.string "intensity"
    t.text "feedback"
    t.integer "max_reps"
    t.integer "average_force"
    t.string "effort_level"
    t.integer "energy_consumed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.bigint "machine_id"
    t.integer "current_series", default: 1
    t.jsonb "reps_per_series", default: {}
    t.boolean "series_completed", default: false
    t.float "power_in_watts"
    t.index ["exercise_id"], name: "index_exercise_sets_on_exercise_id"
    t.index ["machine_id"], name: "index_exercise_sets_on_machine_id"
    t.index ["workout_id"], name: "index_exercise_sets_on_workout_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "muscle_group"
    t.string "difficulty"
    t.text "instructions"
    t.text "variants"
    t.text "equipment_needed"
    t.text "contraindications"
    t.text "benefits"
    t.integer "duration_suggested"
    t.integer "frequency_recommended"
    t.text "progression_levels"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercises_machines", id: false, force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "machine_id", null: false
    t.index ["exercise_id", "machine_id"], name: "index_exercises_machines_on_exercise_id_and_machine_id", unique: true
    t.index ["exercise_id"], name: "index_exercises_machines_on_exercise_id"
    t.index ["machine_id"], name: "index_exercises_machines_on_machine_id"
  end

  create_table "gyms", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.text "contact_info"
    t.text "hours_of_operation"
    t.text "equipment_list"
    t.text "policies"
    t.text "subscriptions"
    t.text "photos"
    t.text "events"
    t.integer "capacity"
    t.text "safety_protocols"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_gyms_on_email", unique: true
    t.index ["reset_password_token"], name: "index_gyms_on_reset_password_token", unique: true
  end

  create_table "gyms_users", id: false, force: :cascade do |t|
    t.bigint "gym_id", null: false
    t.bigint "user_id", null: false
    t.index ["gym_id"], name: "index_gyms_users_on_gym_id"
    t.index ["user_id"], name: "index_gyms_users_on_user_id"
  end

  create_table "machines", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "compatible_exercises", default: [], array: true
    t.string "status", default: "ativo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "gym_id"
    t.index ["gym_id"], name: "index_machines_on_gym_id"
  end

  create_table "personals", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.string "specialization"
    t.text "availability"
    t.text "bio"
    t.string "rating"
    t.string "languages"
    t.string "emergency_contact"
    t.integer "current_clients"
    t.text "certifications"
    t.text "photos"
    t.text "plans"
    t.text "achievements"
    t.bigint "user_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_personals_on_email", unique: true
    t.index ["reset_password_token"], name: "index_personals_on_reset_password_token", unique: true
    t.index ["user_id"], name: "index_personals_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "address"
    t.string "status"
    t.date "date_of_birth"
    t.integer "height"
    t.integer "weight"
    t.bigint "gym_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gym_id"], name: "index_users_on_gym_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "personal_id"
    t.bigint "gym_id"
    t.string "workout_type"
    t.string "goal"
    t.integer "duration"
    t.integer "calories_burned"
    t.string "intensity"
    t.text "feedback"
    t.text "modifications"
    t.string "intensity_general"
    t.string "difficulty_perceived"
    t.integer "performance_score"
    t.text "auto_adjustments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.index ["gym_id"], name: "index_workouts_on_gym_id"
    t.index ["personal_id"], name: "index_workouts_on_personal_id"
    t.index ["user_id"], name: "index_workouts_on_user_id"
  end

  add_foreign_key "arduino_data", "exercise_sets"
  add_foreign_key "exercise_sets", "exercises"
  add_foreign_key "exercise_sets", "machines"
  add_foreign_key "exercise_sets", "workouts"
  add_foreign_key "machines", "gyms"
  add_foreign_key "personals", "users"
  add_foreign_key "users", "gyms"
  add_foreign_key "workouts", "gyms"
  add_foreign_key "workouts", "personals"
  add_foreign_key "workouts", "users"
end
