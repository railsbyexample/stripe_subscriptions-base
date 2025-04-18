require 'sidekiq/web'

Rails.application.routes.draw do
  mount StripeEvent::Engine, at: 'webhooks/stripe'

  resources :movies
  resources :products do
    resource :purchase
  end

  resource :card
  resource :pricing, controller: :pricing
  resource :subscription do
    patch :resume
  end

  resources :charges
  resources :payments

  namespace :admin do
    resources :users
    resources :announcements
    resources :notifications
    resources :services

    root to: "users#index"
  end
  get '/privacy', to: 'home#privacy'
  get '/terms', to: 'home#terms'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :notifications, only: [:index]
  resources :announcements, only: [:index]
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
