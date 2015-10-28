Youtubetonight::Application.routes.draw do
  resources :shows
  resources :videos
  resources :home
  match 'youtube_parser' => 'youtube_parser#index'

  # Facebook Authentication
  get '/auth/:provider/callback', to: 'sessions#create'

  root :to => 'videos#index'
end
