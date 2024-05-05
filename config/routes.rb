# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'home#index'
  get 'login', to: 'sessions#new_login'
  post 'login', to: 'sessions#create_login'
  get 'register', to: 'sessions#new_register'
  post 'register', to: 'sessions#create_register'
  delete 'logout', to: 'sessions#destroy'
  resources :posts do
    resources :comments, only: %i[create edit update destroy]
    resources :reactions, only: %i[create update destroy]
  end
end