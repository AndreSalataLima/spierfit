Rails.application.routes.draw do
  devise_for :gyms, controllers: { registrations: 'registrations', sessions: 'gyms/sessions' }
  devise_for :users, controllers: { registrations: 'registrations' }
  devise_for :personals, controllers: { registrations: 'registrations' }

  resources :machines
  resources :workouts
  resources :exercises
  resources :machines
  resources :personals
  resources :users do
    resources :workouts, only: [:index, :new, :create]
  end

  resources :gyms do
    resources :machines, only: [:index, :new, :create]
  end

  get 'arduino_cloud_data', to: 'arduino_cloud_data#index'
  get "up" => "rails/health#show", as: :rails_health_check

  root to: 'welcome#index'
end
