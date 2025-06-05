require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do

  # -------------------------------------------------------------------
  # Show /api/v1/users
  # -------------------------------------------------------------------

  describe 'GET /api/v1/users/:id' do
    let!(:user1) { User.create!(email: 'one@spierfit.com', password: '12345678', name: 'One') }
    let!(:user2) { User.create!(email: 'two@spierfit.com', password: '12345678', name: 'Two') }

    context 'when authenticated' do
      it 'returns the user as JSON' do
        get "/api/v1/users/#{user1.id}", headers: user1.create_new_auth_token

        expect(response).to have_http_status(:ok)

        expected_response = {
          'id' => user1.id,
          'name' => 'One',
          'email' => 'one@spierfit.com'
        }

        expect(JSON.parse(response.body)).to include(expected_response)
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        get "/api/v1/users/#{user1.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated but accessing another user' do
      it 'returns 403 forbidden' do
        get "/api/v1/users/#{user2.id}", headers: user1.create_new_auth_token

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to include('error' => 'Ação não autorizada.')
      end
    end

    context 'when authenticated as superadmin' do
      let!(:superadmin) { User.create!(email: 'admin@spierfit.com', password: '12345678', name: 'Admin', role: :superadmin) }

      it 'returns any user as JSON' do
        get "/api/v1/users/#{user1.id}", headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:ok)

        expected_response = {
          'id' => user1.id,
          'name' => 'One',
          'email' => 'one@spierfit.com'
        }

        expect(JSON.parse(response.body)).to include(expected_response)
      end
    end

  end

  # -------------------------------------------------------------------
  # Index /api/v1/users
  # -------------------------------------------------------------------

  describe 'GET /api/v1/users' do
    let!(:user1) { User.create!(email: 'one@spierfit.com', password: '12345678', name: 'One') }
    let!(:user2) { User.create!(email: 'two@spierfit.com', password: '12345678', name: 'Two') }

    context 'when authenticated' do
      it 'returns a list of users as JSON' do
        get '/api/v1/users', headers: user1.create_new_auth_token

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(2)

        expected_users = [
          { 'id' => user1.id, 'name' => 'One', 'email' => 'one@spierfit.com' },
          { 'id' => user2.id, 'name' => 'Two', 'email' => 'two@spierfit.com' }
        ]

        expect(json_response).to match_array(expected_users)
      end
    end

    context 'when not authenticated' do
      it 'returns 401 unauthorized' do
        get '/api/v1/users'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as superadmin' do
      let!(:superadmin) { User.create!(email: 'admin@spierfit.com', password: '12345678', name: 'Admin', role: :superadmin) }

      it 'returns a list of all users as JSON' do
        get '/api/v1/users', headers: superadmin.create_new_auth_token

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(3)

        expected_users = [
          { 'id' => user1.id, 'name' => 'One', 'email' => 'one@spierfit.com' },
          { 'id' => user2.id, 'name' => 'Two', 'email' => 'two@spierfit.com' },
          { 'id' => superadmin.id, 'name' => 'Admin', 'email' => 'admin@spierfit.com' }
        ]


        expect(json_response).to match_array(expected_users)
      end
    end
  end

  # -------------------------------------------------------------------
  # POST /api/v1/users
  # -------------------------------------------------------------------
  describe 'POST /api/v1/users' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          name: 'New User',
          email: 'new@example.com',
          password: '12345678',
          password_confirmation: '12345678'
        }
      end

      it 'creates a new user and returns it as JSON' do
        expect {
          post '/api/v1/users', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'id',
          'name' => 'New User',
          'email' => 'new@example.com'
        )
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          name: '',
          email: 'invalid-email',
          password: '123',
          password_confirmation: '321'
        }
      end

      it 'returns 422 unprocessable entity with errors' do
        expect {
          post '/api/v1/users', params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when authenticated as superadmin' do
      let!(:superadmin) { User.create!(email: 'admin@spierfit.com', password: '12345678', name: 'Admin', role: :superadmin) }

      let(:valid_params) do
        {
          name: 'Superadmin Created User',
          email: 'created_by_admin@example.com',
          password: '12345678',
          password_confirmation: '12345678'
        }
      end

      it 'creates a new user successfully' do
        expect {
          post '/api/v1/users', params: valid_params, headers: superadmin.create_new_auth_token
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('name' => 'Superadmin Created User', 'email' => 'created_by_admin@example.com')
      end
    end

  end



end
