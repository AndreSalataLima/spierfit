# spec/requests/workouts_spec.rb
require 'rails_helper'

RSpec.describe "Workouts", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:gym) { Gym.create!(name: "Test Gym", email: "gym@example.com", password: "password123") }
  let!(:user) { User.create!(name: "Test User", email: "user@example.com", password: "password123", gym_id: gym.id) }
  let!(:workout_protocol) do
    WorkoutProtocol.create!(name: "Test Protocol", user: user, gym_id: gym.id, execution_goal: 10)
  end
  let!(:workout) do
    Workout.create!(user: user, gym_id: gym.id, workout_protocol: workout_protocol)
  end

  before do
    sign_in user
  end

  describe "GET /workouts" do
    it "returns http success and lists workouts" do
      get workouts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Filtro por Semana, Mês e Ano")
    end
  end

  describe "GET /workouts/:id" do
    it "returns http success" do
      get workout_path(workout)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Workout Summary")
    end
  end

  describe "GET /workouts/new" do
    it "returns http success" do
      get new_workout_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Workout")
    end
  end

  describe "POST /workouts" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          workout: {
            workout_protocol_id: workout_protocol.id,
            intensity: "high",
            duration: 60,
            gym_id: gym.id,
            user_id: user.id
          }
        }
      end

      it "creates a new workout" do
        expect {
          post workouts_path, params: valid_params
        }.to change(Workout, :count).by(1)

        expect(response).to redirect_to(workout_path(Workout.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          workout: {
            workout_protocol_id: nil,  # Esse campo é obrigatório
            intensity: "high",         # Pode ser qualquer valor, já que não é validado
            duration: 60,
            gym_id: gym.id,
            user_id: user.id
          }
        }
      end

      it "does not create a workout" do
        expect {
          post workouts_path, params: invalid_params
        }.not_to change(Workout, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end


  describe "GET /workouts/:id/edit" do
    it "returns http success" do
      get edit_workout_path(workout)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Editing Workout")
    end
  end

  describe "PATCH /workouts/:id" do
    let(:update_params) { { workout: { intensity: "medium" } } }

    it "updates the workout" do
      patch workout_path(workout), params: update_params
      expect(response).to redirect_to(workout_path(workout))
      workout.reload
      expect(workout.intensity).to eq("medium")
    end
  end

  describe "DELETE /workouts/:id" do
    it "destroys the workout" do
      delete workout_path(workout)
      expect(response).to redirect_to(workouts_path)
      expect(Workout.exists?(workout.id)).to be_falsey
    end
  end

  describe "POST /workouts/:id/complete" do
    it "marks workout as completed" do
      post complete_workout_path(workout)
      expect(response).to redirect_to(workout_path(workout))
      workout.reload
      expect(workout.completed).to be_truthy
    end
  end
end
