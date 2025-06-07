require 'rails_helper'

RSpec.describe 'Api::V1::Gyms', type: :request do

  let!(:superadmin) { create(:user, :superadmin) }
  let!(:gym_admin) { create(:user, role: :gym) }
  let!(:regular_user) { create(:user) }
  let!(:gym1) { create(:gym, name: 'Gym One', email: 'gym1@example.com') }
  let!(:gym2) { create(:gym, name: 'Gym Two', email: 'gym2@example.com') }

  # -------------------------------------------------------------------
  # GET /api/v1/gyms
  # -------------------------------------------------------------------

  describe 'GET /api/v1/gyms' do

    context 'when authenticated as superadmin' do
      it 'returns list of gyms' do
        get '/api/v1/gyms', headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(2)
        expect(json_response.map { |gym| gym['id'] }).to include(gym1.id, gym2.id)
      end
    end

    context 'when authenticated as gym' do
      it 'returns list of gyms' do
        get '/api/v1/gyms', headers: gym_admin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(2)
      end
    end

    context 'when authenticated as regular user' do
      it 'returns 403 forbidden' do
        get '/api/v1/gyms', headers: regular_user.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to include('error' => 'Ação não autorizada.')
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        get '/api/v1/gyms'
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  # -------------------------------------------------------------------
  # GET /api/v1/gyms/:id
  # -------------------------------------------------------------------

  describe 'GET /api/v1/gyms/:id' do

    context 'when authenticated as superadmin' do
      it 'returns single gym' do
        get "/api/v1/gyms/#{gym1.id}", headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Gym One')
      end
    end

    context 'when authenticated as gym' do
      it 'returns single gym' do
        get "/api/v1/gyms/#{gym1.id}", headers: gym_admin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Gym One')
      end
    end

    context 'when gym does not exist' do
      it 'returns 404 not found' do
        get "/api/v1/gyms/999999", headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when authenticated as regular user' do
      it 'returns 403 forbidden' do
        get "/api/v1/gyms/#{gym1.id}", headers: regular_user.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        get "/api/v1/gyms/#{gym1.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  # -------------------------------------------------------------------
  # POST /api/v1/gyms
  # -------------------------------------------------------------------

  describe 'POST /api/v1/gyms' do

    let(:valid_params) do
      { name: 'New Gym', email: 'newgym@example.com', password: '12345678', password_confirmation: '12345678' }
    end

    let(:invalid_params) do
      { name: '', email: 'invalid-email', password: '123', password_confirmation: '321' }
    end

    context 'when authenticated as superadmin' do
      it 'creates new gym' do
        expect {
          post '/api/v1/gyms', params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(Gym, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('New Gym')
      end

      it 'returns 422 with invalid parameters' do
        expect {
          post '/api/v1/gyms', params: invalid_params, headers: superadmin.create_new_auth_token
        }.not_to change(Gym, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when authenticated as gym' do
      it 'returns 403 forbidden' do
        post '/api/v1/gyms', params: valid_params, headers: gym_admin.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when authenticated as regular user' do
      it 'returns 403 forbidden' do
        post '/api/v1/gyms', params: valid_params, headers: regular_user.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        post '/api/v1/gyms', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  # -------------------------------------------------------------------
  # PUT /api/v1/gyms/:id
  # -------------------------------------------------------------------

  describe 'PUT /api/v1/gyms/:id' do

    let(:update_params) do
      { name: 'Updated Gym', email: 'updated@example.com' }
    end

    let(:invalid_update_params) do
      { name: '', email: 'invalid-email' }
    end

    context 'when authenticated as superadmin' do
      it 'updates existing gym' do
        put "/api/v1/gyms/#{gym1.id}", params: update_params, headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Updated Gym')
      end

      it 'returns 422 with invalid update parameters' do
        put "/api/v1/gyms/#{gym1.id}", params: invalid_update_params, headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when authenticated as gym' do
      it 'updates existing gym' do
        put "/api/v1/gyms/#{gym1.id}", params: update_params, headers: gym_admin.create_new_auth_token

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Updated Gym')
      end
    end

    context 'when gym does not exist' do
      it 'returns 404 not found' do
        put "/api/v1/gyms/999999", params: update_params, headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when authenticated as regular user' do
      it 'returns 403 forbidden' do
        put "/api/v1/gyms/#{gym1.id}", params: update_params, headers: regular_user.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        put "/api/v1/gyms/#{gym1.id}", params: update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
