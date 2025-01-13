Rails.application.routes.draw do
  devise_for :gyms, controllers: { registrations: 'registrations', sessions: 'gyms/sessions' }
  devise_for :users, controllers: { registrations: 'registrations' }
  devise_for :personals, controllers: { registrations: 'registrations' }

  resources :exercises

  resources :personals, only: [:index, :show, :create, :update, :destroy] do
    member do
      get 'dashboard', to: 'personals#dashboard'
      get 'gyms_index', to: 'personals#gyms_index'
      post 'select_gym', to: 'personals#select_gym'
      get 'users_index', to: 'personals#users_index'
      get 'wellness_users_index', to: 'personals#wellness_users_index'
      get 'prescribed_workouts', to: 'personals#prescribed_workouts'
      get 'autocomplete_users', to: 'personals#autocomplete_users'
      get 'filter_protocols', to: 'personals#filter_protocols'
    end

    # Se você ainda quiser manter a listagem/edição de workout protocols aninhados em personals, mantenha somente:
    resources :users, only: [] do
      resources :workout_protocols, only: [:index, :show, :edit, :update, :destroy]
    end
  end

  resources :machines do
    member do
      get 'exercises', to: 'machines#exercises', as: 'machine_exercises'
      get 'start_exercise_set/:exercise_id', to: 'machines#start_exercise_set', as: 'start_exercise_set'
    end
    collection do
      get 'user_index', to: 'machines#user_index'
      get 'select_equipment', to: 'machines#select_equipment'
    end
  end

  resources :workouts do
    member do
      post 'complete', to: 'workouts#complete'
    end
    resources :exercise_sets, only: [:show]
  end

  resources :exercise_sets do
    member do
      patch 'update_weight', to: 'exercise_sets#update_weight'
      patch 'update_rest_time'
      patch 'complete', to: 'exercise_sets#complete'
      get :reps_and_sets
      get :process_new_data
      get :chart_data
    end
  end

  resources :arduino_cloud_data, only: [:index]

  resources :users do
    member do
      get 'dashboard', to: 'users#dashboard'
      get 'prescribed_workouts', to: 'users#prescribed_workouts'
    end
    resources :workouts, only: [:index, :new, :create]

    resources :workout_protocols, only: [:index, :show, :edit, :update, :destroy] do
      member do
        get 'day/:day', to: 'workout_protocols#show_day', as: 'day'
        post 'assign_to_user', to: 'workout_protocols#assign_to_user'
      end
    end

    collection do
      get 'search', to: 'users#search'
    end
  end

  resources :gyms do
    member do
      get 'dashboard', to: 'gyms#dashboard'
    end
    resources :machines, only: [:index, :new, :create]
  end

  resources :protocol_exercises, only: [:new]

  # Rotas exclusivas para criar Protocolos
  # =>  new_for_personal / create_for_personal
  # =>  new_for_user / create_for_user
  resources :workout_protocols, only: [] do
    collection do
      # Caminho do Personal
      get  'new_for_personal',   to: 'workout_protocols#new_for_personal'
      post 'create_for_personal', to: 'workout_protocols#create_for_personal'

      # Caminho do Aluno
      get  'new_for_user',       to: 'workout_protocols#new_for_user'
      post 'create_for_user',    to: 'workout_protocols#create_for_user'
    end
  end

  get 'day/:day', to: 'workout_protocols#show_day', as: 'day'

  # Rotas para o ESP32
  get 'esp32/register',   to: 'esp32#register'
  post 'esp32/register',  to: 'esp32#register'
  post 'esp32/receive_data', to: 'esp32#receive_data'
  get 'esp32/data_points',   to: 'esp32#data_points'

  mount ActionCable.server => '/cable'

  post 'arduino_cloud_data/receive_data', to: 'arduino_cloud_data#receive_data'
  get 'arduino_cloud_data',               to: 'arduino_cloud_data#index'
  get "up" => "rails/health#show", as: :rails_health_check

  root to: 'pages#welcome'
end
