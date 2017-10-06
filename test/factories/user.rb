FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "test_user#{n}" }
    provider 'google_oauth2'
    sequence(:email) { |n| "test_user#{n}@example.com" }
    profile_image 'https://lh4.googleusercontent.com/-2xkwN-nPcB0/AAAAAAAAAAI/AAAAAAAAAcM/GQNFIFgA9bw/photo.jpg'
    auth_hash ''
    expires_at { Time.now.to_i + 1000 }
    requires_auth false
    importing_playlists false
    change_roles true
    role_titles { ['admin'] }
    skip_playlist_import true
  end
end
