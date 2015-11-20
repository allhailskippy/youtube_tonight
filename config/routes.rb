Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :home
  resources :shows
  resources :videos
  resources :manage_users, :only => :index

  resources :users do
    member do
      get :requires_auth, :as => 'requires_auth'
    end
  end

  get 'broadcasts' => 'broadcasts#index'
  get 'youtube_parser' => 'youtube_parser#index'
  root :to => 'shows#index'
end
