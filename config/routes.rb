Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :home

  resources :shows
  resources :videos
  resources :playlists
  resources :users do
    member do
      get :requires_auth, :as => 'requires_auth'
    end
  end
  get :current_user, :to => 'current_user#index', :as => :current_user

  get 'broadcasts' => 'broadcasts#index'
  get 'youtube_parser' => 'youtube_parser#index'
  root :to => 'shows#index'
end
