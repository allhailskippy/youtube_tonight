require 'sidekiq/web'

Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  resources :shows
  resources :videos
  resources :playlists, only: [:show, :index, :create, :update], constraints: { format: /json/ }
  resources :users do
    member do
      get :requires_auth, :as => 'requires_auth'
    end
  end
  get :current_user, :to => 'current_user#index', :as => :current_user

  get 'broadcasts' => 'broadcasts#index'
  get 'youtube_parser' => 'youtube_parser#index'
  get 'app' => 'app#index'
  root :to => 'app#index'

  authenticate :user, lambda { |u| u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
