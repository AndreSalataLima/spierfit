require 'rails_helper'

RSpec.describe "Gyms API", type: :request do
  include Devise::Test::IntegrationHelpers  # 🔥 Adiciona suporte para `sign_in`

  let!(:gym) { Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123") }
  let!(:personal) { Personal.create!(name: "Treinador", email: "personal@example.com", password: "password123") }

  describe "GET /gyms" do
    it "retorna todas as academias" do
      get gyms_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(gym.name)
    end
  end

  describe "GET /gyms/new" do
    it "retorna o formulário de criação" do
      get new_gym_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /gyms" do
    it "cria uma nova academia com parâmetros válidos" do
      post gyms_path, params: { gym: { name: "Nova Academia", email: "nova@gym.com", password: "password123" } }
      expect(response).to have_http_status(:redirect) # Redireciona para show
      expect(Gym.last.name).to eq("Nova Academia")
    end

    it "não cria academia com parâmetros inválidos" do
      post gyms_path, params: { gym: { name: "", email: "nova@gym.com", password: "password123" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /gyms/:id" do
    before do
      sign_in gym  # 🔥 Agora `sign_in` vai funcionar
    end

    it "retorna os detalhes de uma academia" do
      get gym_path(gym)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(gym.name)
    end
  end

  describe "GET /gyms/:id/edit" do
    before do
      sign_in gym
    end

    it "retorna o formulário de edição" do
      get edit_gym_path(gym)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /gyms/:id" do
    before do
      sign_in gym
    end

    it "atualiza uma academia com parâmetros válidos" do
      patch gym_path(gym), params: { gym: { name: "Academia Atualizada" } }
      expect(response).to have_http_status(:redirect)
      expect(gym.reload.name).to eq("Academia Atualizada")
    end

    it "não atualiza academia com parâmetros inválidos" do
      patch gym_path(gym), params: { gym: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /gyms/:id" do
    before do
      sign_in gym
    end

    it "exclui uma academia" do
      expect {
        delete gym_path(gym)
      }.to change(Gym, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /gyms/:id/dashboard" do
    it "requere autenticação" do
      get dashboard_gym_path(gym)
      expect(response).to have_http_status(:redirect) # Devise redireciona se não estiver autenticado
    end
  end

  describe "POST /gyms/:id/link" do
    before do
      sign_in gym
    end

    it "vincula um personal à academia" do
      post link_gym_personal_path(gym_id: gym.id, id: personal.id)
      expect(response).to have_http_status(:ok)
      expect(gym.personals).to include(personal)
    end

    it "não vincula um personal que já está vinculado" do
      gym.personals << personal  # Já vincula antes do teste
      post link_gym_personal_path(gym_id: gym.id, id: personal.id)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
