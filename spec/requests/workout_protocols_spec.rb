# spec/requests/workout_protocols_spec.rb
require 'rails_helper'

RSpec.describe "WorkoutProtocols", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:gym) { Gym.create!(name: "Gym X", email: "gym@example.com", password: "password123") }
  let!(:user) { User.create!(name: "Test User", email: "user@example.com", password: "password123", gyms: [gym]) }
  let!(:personal) do
    personal = Personal.create!(name: "Test Personal", email: "personal@example.com", password: "password123")
    personal.gyms << gym
    personal
  end
  let!(:exercise) { Exercise.create!(name: "Push-up") }
  let!(:workout_protocol) { WorkoutProtocol.create!(name: "Test Protocol", user: user, gym: gym, execution_goal: 10) }

  before do
    workout_protocol.protocol_exercises.create!(
      exercise: exercise,
      muscle_group: "Peitoral",
      sets: 3,
      min_repetitions: 8,
      max_repetitions: 12,
      day: "Monday"
    )
  end

  describe "User-facing endpoints" do
    before { sign_in user }

    describe "GET /users/:user_id/workout_protocols" do
      it "lists user's workout protocols" do
        get user_workout_protocols_path(user)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Test Protocol")
      end
    end


    describe "Protocol creation flow" do
      before { get dashboard_user_path(user) }

      describe "GET /workout_protocols/new_for_user" do
        it "returns the new protocol form" do
          get new_for_user_workout_protocols_path
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Novo Protocolo")
        end
      end

      describe "POST /workout_protocols/create_for_user" do
        context "with valid parameters" do
          let(:valid_params) do
            {
              workout_protocol: {
                name: "User Protocol",
                execution_goal: 15,
                protocol_exercises_attributes: [{
                  exercise_id: exercise.id,
                  muscle_group: "Peitoral",
                  sets: 3,
                  min_repetitions: 8,
                  max_repetitions: 12,
                  day: "Monday"
                }]
              }
            }
          end

          it "creates a new protocol" do
            expect {
              post create_for_user_workout_protocols_path, params: valid_params
            }.to change(WorkoutProtocol, :count).by(1)

            expect(response).to redirect_to(user_workout_protocol_path(user, WorkoutProtocol.last))
            follow_redirect!
            expect(response.body).to include("Protocolo criado com sucesso (Aluno).")
          end
        end

        context "with invalid parameters" do
          let(:invalid_params) do
            { workout_protocol: { name: "", execution_goal: 0 } }
          end

          it "rejects invalid parameters" do
            expect {
              post create_for_user_workout_protocols_path, params: invalid_params
            }.not_to change(WorkoutProtocol, :count)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    describe "Protocol management" do
      describe "GET /users/:user_id/workout_protocols/:id/edit_for_user" do
        it "shows edit form" do
          get edit_for_user_user_workout_protocol_path(user, workout_protocol)
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Adicionar Exercício")
        end
      end

      describe "PATCH /users/:user_id/workout_protocols/:id/update_for_user" do
        let(:update_params) do
          {
            workout_protocol: {
              name: "Updated Protocol",
              execution_goal: 20
            }
          }
        end

        it "updates the protocol" do
          patch update_for_user_user_workout_protocol_path(user, workout_protocol), params: update_params

          expect(response).to redirect_to(show_for_user_user_workout_protocol_path(user, workout_protocol))
          workout_protocol.reload
          expect(workout_protocol.name).to eq("Updated Protocol")
          expect(workout_protocol.execution_goal).to eq(20)
        end
      end

      describe "DELETE /users/:user_id/workout_protocols/:id" do
        it "deletes the protocol" do
          delete user_workout_protocol_path(user, workout_protocol)

          expect(response).to redirect_to(user_workout_protocols_path(user))
          expect(WorkoutProtocol.exists?(workout_protocol.id)).to be_falsey
        end
      end
    end

    describe "GET /users/:user_id/workout_protocols/:id/day/:day" do
      it "shows day-specific exercises" do
        get day_user_workout_protocol_path(user, workout_protocol, day: "Monday")
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Monday")
        expect(response.body).to include("Push-up")
      end
    end
  end

  describe "Personal-facing endpoints" do
    before do
      sign_in personal
      post select_gym_personal_path(personal), params: { gym_id: gym.id }
    end

    describe "Protocol creation flow" do

      describe "GET /workout_protocols/new_for_personal" do
        it "returns the new protocol form" do
          get new_for_personal_workout_protocols_path
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Novo Protocolo")
        end
      end

      describe "POST /workout_protocols/create_for_personal" do
        context "with valid parameters" do
          let(:valid_params) do
            {
              workout_protocol: {
                name: "Personal Protocol",
                execution_goal: 20,
                user_id: user.id,
                protocol_exercises_attributes: [{
                  exercise_id: exercise.id,
                  muscle_group: "Peitoral",
                  sets: 4,
                  min_repetitions: 10,
                  max_repetitions: 15,
                  day: "Tuesday"
                }]
              }
            }
          end

          it "creates a new protocol" do
            expect {
              post create_for_personal_workout_protocols_path, params: valid_params
            }.to change(WorkoutProtocol, :count).by(1)

            expect(response).to redirect_to(prescribed_workouts_personal_path(personal))
            follow_redirect!
            expect(response.body).to include("Protocolo criado com sucesso (Personal).")
          end
        end
      end
    end

    describe "Protocol assignment" do
      describe "POST /personals/:personal_id/users/:user_id/workout_protocols/:id/assign_to_user" do
        it "assigns protocol to user" do
          expect {
            post assign_to_user_personal_user_workout_protocol_path(personal, user, workout_protocol)
          }.to change(user.workout_protocols, :count).by(1)

          expect(response).to redirect_to(prescribed_workouts_personal_path(personal))
          follow_redirect!
          expect(response.body).to include("Protocolo prescrito com sucesso.")
        end
      end

      describe "POST /workout_protocols/copy_protocol" do
        it "copies existing protocol" do
          expect {
            post copy_protocol_workout_protocols_path, params: {
              protocol_id: workout_protocol.id,
              user_id: user.id
            }
          }.to change(WorkoutProtocol, :count).by(1)

          copied_protocol = WorkoutProtocol.last
          expect(copied_protocol.name).to include("(Cópia)")
          expect(copied_protocol.user).to eq(user)
        end
      end
    end
  end
end
