require 'rails_helper'

RSpec.describe 'Api::V1::Workouts', type: :request do
  let!(:gym)     { create(:gym) }
  let!(:user)    { create(:user, gyms: [gym]) }
  let!(:workout) { create(:workout, user: user, gym: gym, workout_protocol: create(:workout_protocol, user: user, gym: gym)) }
  let(:base_path) { '/api/v1/workouts' }

  # -------------------------------------------------------------------
  # GET /index
  # -------------------------------------------------------------------
  describe 'GET /index' do
    it 'retorna workouts para usuário autenticado' do
      get base_path, headers: user.create_new_auth_token
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first['id']).to eq(workout.id)
    end

    it '401 se não autenticado' do
      get base_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # -------------------------------------------------------------------
  # GET /show
  # -------------------------------------------------------------------
  describe 'GET /show' do
    it 'retorna um workout específico' do
      get "#{base_path}/#{workout.id}", headers: user.create_new_auth_token
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(workout.id)
    end

    it '401 se não autenticado' do
      get "#{base_path}/#{workout.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # -------------------------------------------------------------------
  # POST /create
  # -------------------------------------------------------------------
  describe 'POST /create' do
    let!(:workout_protocol) { create(:workout_protocol, user: user, gym: gym) }

    let(:valid_params) do
      {
        workout_protocol_id: workout_protocol.id,
        protocol_day: 'Segunda-feira',
        goal: 'Hipertrofia',
        duration: 45,
        calories_burned: 400,
        intensity: 'Alta',
        completed: false
      }
    end

    it 'cria um workout' do
      expect {
        post base_path, params: valid_params, headers: user.create_new_auth_token
      }.to change(Workout, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it '401 se não autenticado' do
      post base_path, params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # -------------------------------------------------------------------
  # PATCH /update
  # -------------------------------------------------------------------
  describe 'PATCH /update' do
    it 'atualiza um workout existente' do
      patch "#{base_path}/#{workout.id}",
            params: { goal: 'New Goal' },
            headers: user.create_new_auth_token

      expect(response).to have_http_status(:ok)
      expect(workout.reload.goal).to eq('New Goal')
    end

    it '401 se não autenticado' do
      patch "#{base_path}/#{workout.id}", params: { goal: 'X' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
