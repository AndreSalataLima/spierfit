require 'rails_helper'

RSpec.describe "Users API", type: :request do
  include Devise::Test::IntegrationHelpers # Permite `sign_in` e `sign_out`

  let!(:gym) { Gym.create!(name: "Gym X", email: "gym@example.com", password: "password123") }
  let!(:user) { User.create!(name: "Test User", email: "user@example.com", password: "password123", gyms: [gym]) }
  let!(:other_user) { User.create!(name: "Other User", email: "other@example.com", password: "password123") }

  before do
    sign_in user
  end

  describe "GET /users" do
    it "lista todos os usuários" do
      get users_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Test User")
      expect(response.body).to include("Other User")
    end
  end

  describe "GET /users/:id" do
    it "exibe os detalhes de um usuário" do
      get user_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Test User")
    end
  end

  describe "GET /users/new" do
    it "retorna o formulário de criação" do
      get new_user_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("New User")
    end
  end

  describe "POST /users" do
    context "com parâmetros válidos" do
      let(:valid_params) do
        {
          user: {
            name: "Novo Usuário",
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "cria um novo usuário" do
        expect {
          post users_path, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(users_path)
        follow_redirect!
        expect(response.body).to include("User criado com sucesso!")

      end
    end

    context "com parâmetros inválidos" do
      let(:invalid_params) do
        {
          user: {
            name: "",
            email: "invalidemail",
            password: "123",
            password_confirmation: "456"
          }
        }
      end

      it "não cria um usuário e retorna erro" do
        expect {
          post users_path, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /users/:id/edit" do
    it "retorna o formulário de edição" do
      get edit_user_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Editar Test User")
    end
  end

  describe "PATCH /users/:id" do
    context "com parâmetros válidos" do
      let(:update_params) do
        {
          user: {
            name: "User Atualizado",
            email: "updated@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "atualiza o usuário" do
        patch user_path(user), params: update_params

        expect(response).to redirect_to(user_path(user))
        follow_redirect!
        expect(response.body).to include("Perfil atualizado com sucesso.")
        user.reload
        expect(user.name).to eq("User Atualizado")
        response.body
      end
    end

    context "com parâmetros inválidos" do
      let(:invalid_update_params) do
        {
          user: {
            name: "",
            email: "invalidemail",
            password: "", # Simulate missing password
            password_confirmation: ""
          }
        }
      end

      it "não atualiza o usuário e retorna erro" do
        patch user_path(user), params: invalid_update_params

        # Expect redirect to edit page due to missing password
        expect(response).to redirect_to(edit_user_path(user))
        follow_redirect!
        expect(flash[:alert]).to eq("A senha é necessária para confirmar as alterações.")

        user.reload
        expect(user.name).not_to eq("")
      end
    end
  end

  describe "DELETE /users/:id" do
    it "exclui um usuário" do
      expect {
        delete user_path(other_user)
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(users_path)
      follow_redirect!
      expect(response.body).to include("User excluído com sucesso!")
    end
  end

  describe "GET /users/dashboard" do
    it "carrega o dashboard do usuário" do
      get dashboard_user_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Meu Progresso") # From the progress card
      expect(response.body).to include("Iniciar Treino") # From the training card
      expect(response.body).to include("Histórico de Treino") # From the history card
    end
  end

  describe "GET /users/search" do
    before do
      sign_in user
    end

    it "busca usuários pelo nome" do
      get search_users_path, params: { query: "Test" }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first["name"]).to eq("Test User")
    end
  end

  describe "GET /users/:id/prescribed_workouts" do
    let!(:workout_protocol) { WorkoutProtocol.create!(name: "Treino A", user: user, gym_id: gym.id, execution_goal: 10) }

    it "lista os treinos prescritos para o usuário" do
      get prescribed_workouts_user_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Treino A")
    end
  end
end
