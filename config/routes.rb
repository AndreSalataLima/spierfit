Rails.application.routes.draw do
  devise_for :personals, controllers: { registrations: 'registrations' }
  devise_for :users, controllers: { registrations: 'registrations' }
  devise_for :gyms, controllers: { registrations: 'registrations', sessions: 'gyms/sessions' }

  resources :machines
  resources :workouts
  resources :exercises
  resources :machines
  resources :personals
  resources :users
  resources :exercise_sets
  resources :gyms

  resources :users do
    resources :workouts, only: [:index, :new, :create]
  end

  devise_scope :gym do
    get 'gyms/sign_in', to: 'gyms/sessions#new'
  end

  get 'arduino_cloud_data', to: 'arduino_cloud_data#index'

  get "up" => "rails/health#show", as: :rails_health_check

  # Define the root path route ("/")
  root to: 'welcome#index'
end
