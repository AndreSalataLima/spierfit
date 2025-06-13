require 'rails_helper'

RSpec.describe 'Api::V1::WorkoutProtocols', type: :request do
  let!(:gym)      { create(:gym) }
  let!(:user)     { create(:user, gyms: [gym]) }
  let!(:personal) { create(:user, role: :personal, gyms: [gym]) }
  let!(:protocol) { create(:workout_protocol, user: user, gym: gym) }
  let(:base_path) { '/api/v1/workout_protocols' }

  # -------------------------------------------------------------------
  # GET /api/v1/workout_protocols
  # -------------------------------------------------------------------
  describe 'GET /index' do
    context 'quando autenticado' do
      before { get base_path, headers: user.create_new_auth_token }

      it 'retorna protocolos acessíveis ao usuário' do
        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |p| p['id'] }
        expect(ids).to include(protocol.id)
      end
    end

    context 'quando não autenticado' do
      before { get base_path }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # POST /api/v1/workout_protocols
  # -------------------------------------------------------------------
  describe 'POST /create' do
    let(:params) do
      {
        name:            'Protocolo de teste',
        description:     'Descrição exemplo',
        execution_goal:  5,
        gym_id:          gym.id
      }
    end

    context 'usuário comum cria para si mesmo' do
      it 'retorna 201 created' do
        expect {
          post base_path, params: params, headers: user.create_new_auth_token
        }.to change(WorkoutProtocol, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['user_id']).to eq(user.id)
      end
    end

    context 'personal atribui a outro usuário' do
      let!(:target) { create(:user, gyms: [gym]) }

      it 'cria protocolo vinculado ao target' do
        custom_params = params.merge(user_id: target.id)

        expect {
          post base_path, params: custom_params, headers: personal.create_new_auth_token
        }.to change(WorkoutProtocol, :count).by(1)

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(json['user_id']).to eq(target.id)
        expect(json['personal_id']).to eq(personal.id)
      end
    end

    context 'quando não autenticado' do
      before { post base_path, params: params }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # PUT /api/v1/workout_protocols/:id
  # -------------------------------------------------------------------
  describe 'PUT /update' do
    let(:update_params) { { name: 'Novo nome' } }
    let(:path)          { "#{base_path}/#{protocol.id}" }

    context 'dono do protocolo' do
      it 'atualiza com sucesso' do
        put path, params: update_params, headers: user.create_new_auth_token
        expect(response).to have_http_status(:ok)
        expect(protocol.reload.name).to eq('Novo nome')
      end
    end

    context 'outro usuário comum' do
      let!(:other_user) { create(:user, gyms: [gym]) }

      before { put path, params: update_params, headers: other_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'não autenticado' do
      before { put path, params: update_params }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # DELETE /api/v1/workout_protocols/:id
  # -------------------------------------------------------------------
  describe 'DELETE /destroy' do
    let(:path) { "#{base_path}/#{protocol.id}" }

    context 'dono do protocolo' do
      it 'remove o protocolo' do
        expect {
          delete path, headers: user.create_new_auth_token
        }.to change(WorkoutProtocol, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'outro usuário' do
      let!(:other_user) { create(:user, gyms: [gym]) }

      before { delete path, headers: other_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'não autenticado' do
      before { delete path }
      it_behaves_like 'unauthorized request'
    end
  end
end
