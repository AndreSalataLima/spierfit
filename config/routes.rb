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
    end

    # Escopo de rotas de users e workout_protocols dentro de personals
    resources :users, only: [] do
      resources :workout_protocols do
        resources :protocol_exercises, only: [:create, :update, :destroy]
      end
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
      post 'complete', to: 'exercise_sets#complete'
      patch 'update_weight', to: 'exercise_sets#update_weight'
      patch 'update_rest_time'
      patch 'complete'
      get :reps_and_sets
      get :process_new_data
    end
  end

  resources :arduino_cloud_data, only: [:index]

  resources :users do
    member do
      get 'dashboard', to: 'users#dashboard'
    end
    resources :workouts, only: [:index, :new, :create]

    # Escopo para acesso direto aos workout_protocols do user
    resources :workout_protocols do
      resources :protocol_exercises, only: [:create, :update, :destroy]
    end
  end

  resources :gyms do
    member do
      get 'dashboard', to: 'gyms#dashboard'
    end
    resources :machines, only: [:index, :new, :create]
  end

  resources :protocol_exercises, only: [:new]

  # Rotas para o ESP32
  get 'esp32/register', to: 'esp32#register'
  post 'esp32/register', to: 'esp32#register'
  post 'esp32/receive_data', to: 'esp32#receive_data'
  get 'esp32/data_points', to: 'esp32#data_points'

  mount ActionCable.server => '/cable'

  post 'arduino_cloud_data/receive_data', to: 'arduino_cloud_data#receive_data'
  get 'arduino_cloud_data', to: 'arduino_cloud_data#index'
  get "up" => "rails/health#show", as: :rails_health_check

  root to: 'pages#welcome'
end
