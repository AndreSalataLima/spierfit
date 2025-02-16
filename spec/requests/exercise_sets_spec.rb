require 'rails_helper'

RSpec.describe "ExerciseSets API", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:user) { User.create!(name: "Usuário Teste", email: "user@example.com", password: "password123") }
  let!(:gym) { Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123") }
  let!(:machine) { Machine.create!(name: "Máquina 1", gym: gym, mac_address: "FF:FF:FF:FF:FF:FF", min_distance: 40) }
  let!(:exercise) { Exercise.create!(name: "Supino Reto") }
  let!(:workout) { Workout.create!(user: user) }
  let!(:exercise_set) do
    ExerciseSet.create!(
      workout: workout,
      exercise: exercise,
      machine: machine,    # 🔥 Evita nil machine
      reps: 10,
      sets: 3
    )
  end

  before do
    sign_in user
  end

  describe "GET /exercise_sets/:id" do
    it "retorna os detalhes de um exercise_set" do
      get exercise_set_path(exercise_set)
      expect(response).to have_http_status(:success)
      # Você pode testar o conteúdo do body se quiser
      expect(response.body).to include("Supino Reto")
    end
  end

  describe "PATCH /exercise_sets/:id" do
    it "atualiza um exercise_set com parâmetros válidos" do
      patch exercise_set_path(exercise_set), params: { exercise_set: { reps: 12 } }
      expect(response).to have_http_status(:redirect)
      expect(exercise_set.reload.reps).to eq(12)
    end

    it "não atualiza exercise_set com parâmetros inválidos" do
      patch exercise_set_path(exercise_set), params: { exercise_set: { reps: -5 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /exercise_sets/:id" do
    it "exclui um exercise_set" do
      expect {
        delete exercise_set_path(exercise_set)
      }.to change(ExerciseSet, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH /exercise_sets/:id/update_weight" do
    it "atualiza o peso do exercício" do
      patch update_weight_exercise_set_path(exercise_set), params: { exercise_set: { weight: 100 } }
      expect(response).to have_http_status(:success)
      expect(exercise_set.reload.weight).to eq(100)
    end
  end

  describe "PATCH /exercise_sets/:id/update_rest_time" do
    it "atualiza o tempo de descanso" do
      patch update_rest_time_exercise_set_path(exercise_set), params: { rest_time: 60 }
      expect(response).to have_http_status(:success)
      expect(exercise_set.reload.rest_time).to eq(60)
    end
  end

  describe "PATCH /exercise_sets/:id/complete" do
    it "marca um exercise_set como completo" do
      patch complete_exercise_set_path(exercise_set)
      expect(response).to have_http_status(:redirect)
      expect(exercise_set.reload.completed).to be true
    end
  end
end
