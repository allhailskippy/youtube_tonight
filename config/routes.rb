require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  resources :users, only: [:index, :show, :update, :destroy] , constraints: { format: /json/ } do
    member do
      get :requires_auth, :as => 'requires_auth'
    end
  end
  resources :shows, except: [:new, :edit], constraints: { format: /json/ }
  resources :videos, except: [:new, :edit], constraints: { format: /json/ }
  resources :playlists, only: [:index, :show, :create, :update], constraints: { format: /json/ }

  get :current_user, :to => 'current_user#index', :as => :current_user, constraints: { format: /json/ }
  get 'broadcasts' => 'broadcasts#index'
  get 'youtube_parser' => 'youtube_parser#index', constraints: { format: /json/ }
  get 'app' => 'app#index'
  root :to => 'app#index'

  authenticate :user, lambda { |u| u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
