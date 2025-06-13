require 'rails_helper'

RSpec.describe 'Api::V1::Machines', type: :request do
  let!(:gym1) { create(:gym) }
  let!(:gym2) { create(:gym) }
  let!(:machine1) { create(:machine, gym: gym1) }
  let!(:machine2) { create(:machine, gym: gym2) }

  let!(:superadmin) { create(:user, :superadmin) }
  let!(:gym_admin) { create(:user, :gym, gyms: [gym1]) }
  let!(:other_gym_admin) { create(:user, :gym, gyms: [gym2]) }
  let!(:regular_user) { create(:user) }

  let(:base_path) { '/api/v1/machines' }

  let(:valid_params) do
    {
      name: Faker::Device.model_name,
      gym_id: gym1.id
    }
  end

  let(:update_params) do
    {
      name: Faker::Device.model_name,
      status: 'inativo'
    }
  end

  let(:invalid_params) do
    {
      name: '',
      gym_id: nil
    }
  end

  # -------------------------------------------------------------------
  # GET /api/v1/machines
  # -------------------------------------------------------------------
  describe 'GET /api/v1/machines' do
    context 'como superadmin' do
      before { get base_path, headers: superadmin.create_new_auth_token }

      it 'retorna todas as machines' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.map { |m| m['id'] }).to match_array([machine1.id, machine2.id])
      end
    end

    context 'como gym-admin' do
      before { get base_path, headers: gym_admin.create_new_auth_token }

      it 'retorna só as machines da sua gym' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.map { |m| m['id'] }).to eq([machine1.id])
      end
    end

    context 'como usuário regular' do
      before { get base_path, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'sem autenticar' do
      before { get base_path }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # GET /api/v1/machines/:id
  # -------------------------------------------------------------------
  describe 'GET /api/v1/machines/:id' do
    context 'como superadmin' do
      before { get "#{base_path}/#{machine1.id}", headers: superadmin.create_new_auth_token }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'como gym-admin da mesma gym' do
      before { get "#{base_path}/#{machine1.id}", headers: gym_admin.create_new_auth_token }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'como gym-admin de outra gym' do
      before { get "#{base_path}/#{machine1.id}", headers: other_gym_admin.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'como usuário regular' do
      before { get "#{base_path}/#{machine1.id}", headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'sem autenticação' do
      before { get "#{base_path}/#{machine1.id}" }
      it_behaves_like 'unauthorized request'
    end

    context 'quando a machine não existe' do
      it 'retorna 404' do
        get "#{base_path}/999999", headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------
  # POST /api/v1/machines
  # -------------------------------------------------------------------
  describe 'POST /api/v1/machines' do
    context 'como superadmin' do
      it 'cria machine para qualquer gym' do
        expect {
          post base_path, params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(Machine, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'retorna 422 com params inválidos' do
        post base_path, params: invalid_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'como gym-admin da própria gym' do
      it 'cria machine' do
        expect {
          post base_path, params: valid_params, headers: gym_admin.create_new_auth_token
        }.to change(Machine, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'como gym-admin de outra gym' do
      before { post base_path, params: valid_params, headers: other_gym_admin.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'como usuário regular' do
      before { post base_path, params: valid_params, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'sem autenticação' do
      before { post base_path, params: valid_params }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # PUT /api/v1/machines/:id
  # -------------------------------------------------------------------
  describe 'PUT /api/v1/machines/:id' do
    context 'como superadmin' do
      it 'atualiza qualquer machine' do
        put "#{base_path}/#{machine1.id}", params: update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:ok)
      end

      it 'retorna 422 se os dados forem inválidos' do
        put "#{base_path}/#{machine1.id}", params: invalid_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'como gym-admin da mesma gym' do
      before { put "#{base_path}/#{machine1.id}", params: update_params, headers: gym_admin.create_new_auth_token }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'como gym-admin de outra gym' do
      before { put "#{base_path}/#{machine1.id}", params: update_params, headers: other_gym_admin.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'como usuário regular' do
      before { put "#{base_path}/#{machine1.id}", params: update_params, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'sem autenticação' do
      before { put "#{base_path}/#{machine1.id}", params: update_params }
      it_behaves_like 'unauthorized request'
    end

    context 'quando a machine não existe' do
      it 'retorna 404' do
        put "#{base_path}/999999", params: update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
