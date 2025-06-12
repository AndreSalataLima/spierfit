require 'rails_helper'

RSpec.describe 'Api::V1::Exercises', type: :request do
  let!(:exercise1) { create(:exercise) }
  let!(:exercise2) { create(:exercise) }

  let!(:superadmin) { create(:user, :superadmin) }
  let!(:gym_admin)  { create(:user, :gym) }
  let!(:user)       { create(:user) }

  let(:base_path) { '/api/v1/exercises' }
  let(:valid_params) do
    attributes_for(:exercise).slice(:name, :description, :muscle_group).merge(machine_ids: [])
  end

  let(:invalid_params) { { name: '' } }
  # -------------------------------------------------------------------
  # GET /api/v1/gyms
  # -------------------------------------------------------------------
  describe 'GET /api/v1/exercises' do
    context 'autenticado' do
      it 'retorna todos os exercícios' do
        get base_path, headers: user.create_new_auth_token
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.map { |e| e['id'] }).to match_array([exercise1.id, exercise2.id])
      end
    end

    context 'sem autenticação' do
      before { get base_path }
      it_behaves_like 'unauthorized request'
    end
  end
  # -------------------------------------------------------------------
  # GET /api/v1/gyms/:id
  # -------------------------------------------------------------------
  describe 'GET /api/v1/exercises/:id' do
    context 'autenticado' do
      before { get "#{base_path}/#{exercise1.id}", headers: user.create_new_auth_token }

      it 'retorna exercício com machine_ids' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include('machine_ids')
        expect(json['machine_ids']).to be_a(Array)
      end
    end

    context 'quando não existe' do
      it '404 not found' do
        get "#{base_path}/999999", headers: user.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'sem autenticação' do
      before { get "#{base_path}/#{exercise1.id}" }
      it_behaves_like 'unauthorized request'
    end
  end
  # -------------------------------------------------------------------
  # POST /api/v1/gyms
  # -------------------------------------------------------------------
  describe 'POST /api/v1/exercises' do
    context 'como superadmin' do
      it 'cria exercício' do
        expect {
          post base_path, params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(Exercise, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'retorna 422 com params inválidos' do
        post base_path, params: invalid_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'como usuário comum ou gym-admin' do
      it 'forbidden' do
        post base_path, params: valid_params, headers: user.create_new_auth_token
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'sem autenticação' do
      before { post base_path, params: valid_params }
      it_behaves_like 'unauthorized request'
    end
  end
  # -------------------------------------------------------------------
  # PUT /api/v1/gyms/:id
  # -------------------------------------------------------------------
  describe 'PUT /api/v1/exercises/:id' do
    context 'como superadmin' do
      it 'atualiza exercício' do
        put "#{base_path}/#{exercise1.id}", params: { name: 'Novo Nome' },
          headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:ok)
        expect(exercise1.reload.name).to eq('Novo Nome')
      end

      it '422 com dados inválidos' do
        put "#{base_path}/#{exercise1.id}", params: invalid_params,
          headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'como usuário comum ou gym-admin' do
      it 'forbidden' do
        put "#{base_path}/#{exercise1.id}", params: { name: 'X' },
          headers: user.create_new_auth_token
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'sem autenticação' do
      before { put "#{base_path}/#{exercise1.id}", params: { name: 'X' } }
      it_behaves_like 'unauthorized request'
    end
  end
end
