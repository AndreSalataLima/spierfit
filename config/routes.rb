Rails.application.routes.draw do

  devise_for :personals, controllers: { registrations: 'registrations' }
  devise_for :users, controllers: { registrations: 'registrations' }

  resources :workouts
  resources :exercises
  resources :gyms
  resources :personals
  resources :users
  resources :exercise_sets

  resources :users do
    resources :workouts, only: [:index, :new, :create]
  end

  # root to: 'home#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
#
