Rails.application.routes.draw do
  devise_for :gyms, controllers: { registrations: 'registrations', sessions: 'gyms/sessions' }
  devise_for :users, controllers: { registrations: 'registrations' }
  devise_for :personals, controllers: { registrations: 'registrations' }

  resources :exercises
  resources :personals

  resources :machines do
    member do
      get 'exercises', to: 'machines#exercises', as: 'machine_exercises'
      get 'start_exercise_set/:exercise_id', to: 'machines#start_exercise_set', as: 'start_exercise_set'
    end
    collection do
      get 'user_index', to: 'machines#user_index'
    end
  end

  resources :workouts do
    member do
      post 'complete', to: 'workouts#complete'
    end
  end

  resources :exercise_sets do
    member do
      post 'complete', to: 'exercise_sets#complete'
    end
  end
  resources :arduino_cloud_data, only: [:index]

  resources :users do
    resources :workouts, only: [:index, :new, :create]
  end

  resources :gyms do
    resources :machines, only: [:index, :new, :create]
  end

  mount ActionCable.server => '/cable'

  get 'arduino_cloud_data', to: 'arduino_cloud_data#index'
  get "up" => "rails/health#show", as: :rails_health_check

  root to: 'welcome#index'
end
