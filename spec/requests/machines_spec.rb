require 'rails_helper'

RSpec.describe "Machines API", type: :request do
  include Devise::Test::IntegrationHelpers

  # Se for preciso autenticar um gym
  let!(:gym) { Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123") }

  # Se for preciso um user (ex.: para user_index)
  let!(:user) { User.create!(name: "Usuário", email: "user@example.com", password: "password123") }

  before do
    # Se o controller exige `current_gym` para algumas ações,
    # você pode simular o login do gym:
    sign_in gym
  end

  let!(:machine) { Machine.create!(name: "Leg Press", gym: gym, mac_address: "AA:BB:CC:DD:EE:FF") }

  describe "GET /machines" do
    it "lista as máquinas da academia atual" do
      get machines_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Leg Press")
    end
  end

  describe "GET /machines/:id" do
    it "mostra os detalhes de uma máquina" do
      get machine_path(machine)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Leg Press")
    end
  end

  describe "GET /machines/new" do
    it "retorna o formulário de criação" do
      get new_machine_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /machines" do
    it "cria uma máquina com parâmetros válidos" do
      expect {
        post machines_path, params: {
          machine: {
            name: "Supino Máquina",
            mac_address: "11:22:33:44:55:66",
            status: "ativo"
          }
        }
      }.to change(Machine, :count).by(1)

      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include("Supino Máquina")
    end

    it "não cria uma máquina com parâmetros inválidos" do
      expect {
        post machines_path, params: {
          machine: { name: "" }
        }
      }.to_not change(Machine, :count)

      # Se o controller usa `render :new, status: :unprocessable_entity`
      # teremos:
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /machines/:id/edit" do
    it "retorna o formulário de edição" do
      get edit_machine_path(machine)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Leg Press")
    end
  end

  describe "PATCH /machines/:id" do
    before do
      sign_in gym  # 🔥 Certifica que o gym está autenticado
    end
    
    it "atualiza uma máquina com parâmetros válidos" do
      patch machine_path(machine), params: { machine: { name: "Leg Press 2.0" } }
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(machine.reload.name).to eq("Leg Press 2.0")
    end


    it "não atualiza a máquina com parâmetros inválidos" do
      patch machine_path(machine), params: { machine: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)  # Espera 422
    end
  end

  describe "DELETE /machines/:id" do
    it "exclui uma máquina" do
      expect {
        delete machine_path(machine)
      }.to change(Machine, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /machines/user_index" do
    it "lista máquinas para o usuário atual" do
      sign_in user
      get user_index_machines_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /machines/:id/toggle_status" do
    it "alterna o status da máquina" do
      patch toggle_status_machine_path(machine)
      expect(response).to have_http_status(:redirect)
      expect(machine.reload.status).to eq("inativo")
    end
  end


end
