require 'rails_helper'

RSpec.describe 'Api::V1::ProtocolExercises', type: :request do
  let!(:user)     { create(:user) }
  let!(:gym)      { create(:gym) }
  let!(:exercise) { create(:exercise) }
  let!(:protocol) { create(:workout_protocol, user: user, gym: gym) }
  let(:base_path) { "/api/v1/workout_protocols/#{protocol.id}/protocol_exercises" }

  # -------------------------------------------------------------------
  # GET /index
  # -------------------------------------------------------------------
  describe 'GET /index' do
    context 'autenticado' do
      before { get base_path, headers: user.create_new_auth_token }

      it 'retorna os exercícios do protocolo' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'não autenticado' do
      before { get base_path }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # POST /create
  # -------------------------------------------------------------------
  describe 'POST /create' do
    let(:params) do
      {
        exercise_id: exercise.id,
        muscle_group: "peito",
        sets: 3,
        min_repetitions: 10,
        max_repetitions: 12,
        day: "Segunda",
        observation: "executar com controle"
      }
    end

    context 'autenticado' do
      it 'cria um novo exercise no protocolo' do
        post base_path, params: params, headers: user.create_new_auth_token
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['exercise_id']).to eq(exercise.id)
      end
    end

    context 'não autenticado' do
      before { post base_path, params: params }
      it_behaves_like 'unauthorized request'
    end
  end
end
