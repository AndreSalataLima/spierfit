require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let!(:gym) { create(:gym) }
  let!(:superadmin) { create(:user, :superadmin) }
  let!(:gym_admin) { create(:user, role: :gym, gyms: [gym]) }
  let!(:regular_user) { create(:user) }
  let!(:user1) { create(:user, gyms: [gym]) }
  let!(:user2) { create(:user, gyms: [gym]) }

  # -------------------------------------------------------------------
  # GET /api/v1/users
  # -------------------------------------------------------------------
  describe 'GET /api/v1/users' do
    let(:path) { '/api/v1/users' }

    context 'when authenticated as superadmin' do
      before { get path, headers: superadmin.create_new_auth_token }

      it 'returns list of all users' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(User.count)
      end
    end

    context 'when authenticated as gym' do
      before { get path, headers: gym_admin.create_new_auth_token }

      it 'returns list of users (restricted to gym scope)' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
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
  # GET /api/v1/users/:id
  # -------------------------------------------------------------------
  describe 'GET /api/v1/users/:id' do
    let(:path) { "/api/v1/users/#{user1.id}" }

    context 'when authenticated as superadmin' do
      before { get path, headers: superadmin.create_new_auth_token }

      it 'returns any user' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(user1.id)
      end
    end

    context 'when authenticated as gym' do
      before { get path, headers: gym_admin.create_new_auth_token }

      it 'returns user in gym scope' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(user1.id)
      end
    end

    context 'when authenticated as same user' do
      before { get path, headers: user1.create_new_auth_token }

      it 'returns self' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(user1.id)
      end
    end

    context 'when authenticated as different user' do
      before { get "/api/v1/users/#{user2.id}", headers: user1.create_new_auth_token }

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
  end

  # -------------------------------------------------------------------
  # POST /api/v1/users
  # -------------------------------------------------------------------
  describe 'POST /api/v1/users' do
    let(:path) { '/api/v1/users' }
    let(:valid_params) { attributes_for(:user) }

    context 'when authenticated as superadmin' do
      it 'creates a new user' do
        expect {
          post path, params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'when authenticated as gym' do
      it 'creates a new user (restricted to gym scope)' do
        expect {
          post path, params: valid_params, headers: gym_admin.create_new_auth_token
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
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
  # PUT /api/v1/users/:id
  # -------------------------------------------------------------------
  describe 'PUT /api/v1/users/:id' do
    let(:path) { "/api/v1/users/#{user1.id}" }
    let(:update_params) { { name: 'Updated Name', email: Faker::Internet.unique.email } }

    context 'when authenticated as superadmin' do
      it 'updates any user' do
        put path, params: update_params, headers: superadmin.create_new_auth_token
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'when authenticated as gym' do
      it 'updates user in gym scope' do
        put path, params: update_params, headers: gym_admin.create_new_auth_token
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'when authenticated as same user' do
      it 'updates own data' do
        put path, params: update_params, headers: user1.create_new_auth_token
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'when authenticated as other user' do
      before { put "/api/v1/users/#{user2.id}", params: update_params, headers: regular_user.create_new_auth_token }
      it_behaves_like 'forbidden request'
    end

    context 'when not authenticated' do
      before { put path, params: update_params }
      it_behaves_like 'unauthorized request'
    end
  end
end
