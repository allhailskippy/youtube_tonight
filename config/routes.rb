Youtubetonight::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }

  resources :shows
  resources :videos
  resources :home
  match 'youtube_parser' => 'youtube_parser#index'

  root :to => 'shows#index'
end
