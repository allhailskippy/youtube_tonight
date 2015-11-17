Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :home
  resources :shows
  resources :videos
  get 'broadcasts' => 'broadcasts#index'
  get 'youtube_parser' => 'youtube_parser#index'
  root :to => 'shows#index'
end
