require 'rails_helper'

RSpec.describe "Exercises API", type: :request do
  let!(:exercise) { Exercise.create!(name: "Supino Reto", description: "Exercício para peitoral.") }

  describe "GET /exercises" do
    it "retorna todas os exercícios" do
      get exercises_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Supino Reto")
    end
  end

  describe "GET /exercises/:id" do
    it "retorna os detalhes de um exercício" do
      get exercise_path(exercise), as: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Supino Reto")
    end
  end

  describe "POST /exercises" do
    it "cria um novo exercício com parâmetros válidos" do
      expect {
        post exercises_path, params: { exercise: { name: "Agachamento", description: "Exercício para pernas." } }
      }.to change(Exercise, :count).by(1)

      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Agachamento")
    end

    it "não cria um exercício com parâmetros inválidos" do
      expect {
        post exercises_path, params: { exercise: { name: "" } }
      }.to_not change(Exercise, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /exercises/:id" do
    it "atualiza um exercício com parâmetros válidos" do
      patch exercise_path(exercise), params: { exercise: { name: "Supino Inclinado" } }
      expect(response).to have_http_status(:redirect)
      expect(exercise.reload.name).to eq("Supino Inclinado")
    end

    it "não atualiza um exercício com parâmetros inválidos" do
      patch exercise_path(exercise), params: { exercise: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /exercises/:id" do
    it "exclui um exercício" do
      expect {
        delete exercise_path(exercise)
      }.to change(Exercise, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end
end
