require 'rails_helper'

RSpec.describe 'Api::V1::Gyms', type: :request do
  let!(:gym1) { create(:gym) }
  let!(:gym2) { create(:gym) }
  let!(:superadmin) { create(:user, :superadmin) }
  let!(:gym_admin) { create(:user, role: :gym, gyms: [gym1]) }
  let!(:other_gym_admin) { create(:user, role: :gym, gyms: [gym2]) }
  let!(:regular_user) { create(:user) }

  # -------------------------------------------------------------------
  # GET /api/v1/gyms
  # -------------------------------------------------------------------

  describe 'GET /api/v1/gyms' do
    let(:path) { '/api/v1/gyms' }

    context 'when authenticated as superadmin' do
      before { get path, headers: superadmin.create_new_auth_token }

      it 'returns list of gyms' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(Gym.count)
      end
    end

    context 'when authenticated as gym' do
      before { get path, headers: gym_admin.create_new_auth_token }

      it 'returns list of gyms' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authenticated as regular user' do
      before { get path, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when not authenticated' do
      before { get path }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # GET /api/v1/gyms/:id
  # -------------------------------------------------------------------

  describe 'GET /api/v1/gyms/:id' do
    let(:path) { "/api/v1/gyms/#{gym1.id}" }

    context 'when authenticated as superadmin' do
      before { get path, headers: superadmin.create_new_auth_token }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'when authenticated as gym of same gym' do
      before { get path, headers: gym_admin.create_new_auth_token }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'when authenticated as gym of other gym' do
      before { get path, headers: other_gym_admin.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when authenticated as regular user' do
      before { get path, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when not authenticated' do
      before { get path }
      it_behaves_like 'unauthorized request'
    end

    context 'when gym does not exist' do
      let(:invalid_path) { '/api/v1/gyms/999999' }

      it 'returns 404 not found' do
        get invalid_path, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------
  # POST /api/v1/gyms
  # -------------------------------------------------------------------

  describe 'POST /api/v1/gyms' do
    let(:path) { '/api/v1/gyms' }
    let(:valid_params) { attributes_for(:gym) }
    let(:invalid_params) { { name: '', email: 'invalid-email', password: '123', password_confirmation: '321' } }

    context 'when authenticated as superadmin' do
      it 'creates new gym' do
        expect {
          post path, params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(Gym, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'returns 422 with invalid parameters' do
        expect {
          post path, params: invalid_params, headers: superadmin.create_new_auth_token
        }.not_to change(Gym, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when authenticated as gym' do
      before { post path, params: valid_params, headers: gym_admin.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when authenticated as regular user' do
      before { post path, params: valid_params, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when not authenticated' do
      before { post path, params: valid_params }
      it_behaves_like 'unauthorized request'
    end
  end

  # -------------------------------------------------------------------
  # PUT /api/v1/gyms/:id
  # -------------------------------------------------------------------

  describe 'PUT /api/v1/gyms/:id' do
    let(:path) { "/api/v1/gyms/#{gym1.id}" }
    let(:update_params) { { name: 'Updated Gym', email: Faker::Internet.unique.email } }
    let(:invalid_update_params) { { name: '', email: 'invalid-email' } }

    context 'when authenticated as superadmin' do
      it 'updates any gym' do
        put path, params: update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:ok)
      end

      it 'returns 422 with invalid update parameters' do
        put path, params: invalid_update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when authenticated as gym_admin of the same gym' do
      it 'updates its own gym' do
        put path, params: update_params, headers: gym_admin.create_new_auth_token
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authenticated as gym_admin of another gym' do
      it 'returns forbidden' do
        put path, params: update_params, headers: other_gym_admin.create_new_auth_token
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when authenticated as regular user' do
      before { put path, params: update_params, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when not authenticated' do
      before { put path, params: update_params }
      it_behaves_like 'unauthorized request'
    end

    context 'when gym does not exist' do
      let(:invalid_path) { '/api/v1/gyms/999999' }

      it 'returns 404 not found' do
        put invalid_path, params: update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
