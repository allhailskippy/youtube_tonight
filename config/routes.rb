Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :home
  resources :shows
  resources :videos
  match 'broadcasts' => 'broadcasts#index'
  match 'youtube_parser' => 'youtube_parser#index'
  resources :authorization_rules, :only => [:index] do
         collection do
            get :graph
            get :change
            get :suggest_change
          end
  end
  root :to => 'shows#index'
end
