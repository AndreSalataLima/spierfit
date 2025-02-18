require 'rails_helper'

RSpec.describe "ProtocolExercises API", type: :request do
  include Devise::Test::IntegrationHelpers  # 🔥 Inclui suporte para `sign_in`

  let!(:gym) { Gym.create!(name: "Gym X", email: "gym@example.com", password: "password123") }
  let!(:user) { User.create!(name: "Test User", email: "user@example.com", password: "password123") }
  let!(:personal) { Personal.create!(name: "Test Personal", email: "personal@example.com", password: "password123") }
  let!(:exercise) { Exercise.create!(name: "Supino", muscle_group: "Peito") }
  let!(:workout_protocol) { WorkoutProtocol.create!(name: "Treino A", user: user, gym_id: gym.id, execution_goal: 10) }

  before do
    sign_in user  # 🔥 Agora o método funciona corretamente
  end

  describe "GET /protocol_exercises/new" do
    it "retorna sucesso e renderiza o formulário de criação" do
      get new_protocol_exercise_path, params: { muscle_group: "Peito" }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Peito")  # Confirma que o muscle_group foi passado corretamente
    end
  end

  describe "POST /protocol_exercises" do
    context "com parâmetros válidos" do
      let(:valid_params) do
        {
          workout_protocol_id: workout_protocol.id,
          workout_protocol: {
            protocol_exercises_attributes: [
              {
                muscle_group: "Peito",
                exercise_id: exercise.id,
                sets: 3,
                min_repetitions: 8,
                max_repetitions: 12,
                day: 1,
                observation: "Executar com calma"
              }
            ]
          }
        }
      end


      it "cria um novo protocolo de exercício e retorna status 200" do
        expect {
          post protocol_exercises_path, params: valid_params, as: :json
        }.to change(ProtocolExercise, :count).by(1)

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["redirect_url"]).to be_present
      end
    end

    context "com parâmetros inválidos" do
      let(:invalid_params) do
        {
          workout_protocol_id: workout_protocol.id,
          workout_protocol: {
            protocol_exercises_attributes: [
              {
                muscle_group: "",
                exercise_id: nil,
                sets: 3,
                min_repetitions: 8,
                max_repetitions: 12,
                day: 1
              }
            ]
          }
        }
      end


      it "não cria um protocolo de exercício e retorna status 422" do
        expect {
          post protocol_exercises_path, params: invalid_params, as: :json
        }.not_to change(ProtocolExercise, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Exercise must exist", "Muscle group can't be blank")
      end
    end

    context "quando o usuário não está autenticado" do
      before do
        sign_out user  # 🔥 Agora testamos sem usuário logado
      end
      let(:valid_params) do
        {
          workout_protocol_id: workout_protocol.id,
          workout_protocol: {
            protocol_exercises_attributes: [
              {
                muscle_group: "Peito",
                exercise_id: exercise.id,
                sets: 3,
                min_repetitions: 8,
                max_repetitions: 12,
                day: 1,
                observation: "Executar com calma"
              }
            ]
          }
        }
      end



      it "retorna erro 401 Unauthorized" do
        post protocol_exercises_path, params: valid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Usuário não autenticado")
      end
    end
  end
end
