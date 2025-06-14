require 'rails_helper'

RSpec.describe 'Api::V1::ExerciseSets', type: :request do
  let!(:workout)      { create(:workout) }
  let!(:exercise_set) { create(:exercise_set, workout: workout) }
  let!(:user)         { create(:user) }
  let(:base_path)     { "/api/v1/workouts/#{workout.id}/exercise_sets" }

  # -------------------------------------------------------------------
  # GET /show
  # -------------------------------------------------------------------
  describe 'GET /show' do
    it 'retorna um exercise_set' do
      get "#{base_path}/#{exercise_set.id}", headers: user.create_new_auth_token
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(exercise_set.id)
    end

    it '401 se não autenticado' do
      get "#{base_path}/#{exercise_set.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # -------------------------------------------------------------------
  # POST /create
  # -------------------------------------------------------------------
  describe 'POST /create' do
    let(:exercise) { create(:exercise) }
    let(:valid_params) do
      {
        exercise_id: exercise.id,
        sets:        3,
        reps:        10,
        weight:      20,
        duration:    30,
        rest_time:   60,
        intensity:   'medium',
        feedback:    'OK'
      }
    end

    it 'cria um exercise_set' do
      expect {
        post base_path, params: valid_params, headers: user.create_new_auth_token
      }.to change(ExerciseSet, :count).by(1)
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
    it 'atualiza um exercise_set' do
      patch "#{base_path}/#{exercise_set.id}",
            params: { reps: 15 },
            headers: user.create_new_auth_token

      expect(response).to have_http_status(:ok)
      expect(exercise_set.reload.reps).to eq(15)
    end

    it '401 se não autenticado' do
      patch "#{base_path}/#{exercise_set.id}", params: { reps: 99 }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
