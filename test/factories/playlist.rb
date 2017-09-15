FactoryGirl.define do
  factory :playlist do
    association :user
    sequence(:api_playlist_id) {|n| "abcdefg#{n}" }
    sequence(:api_title) {|n| "title #{n}" }
    video_count 0
    sequence(:api_description) {|n| "description #{n}" }
    api_thumbnail_default_url "http://localhost/thumbnail.gif"
    api_thumbnail_default_width 120
    api_thumbnail_default_height 90
    api_thumbnail_medium_url "http://localhost/thumbnail.gif"
    api_thumbnail_medium_width 320
    api_thumbnail_medium_height 180
    api_thumbnail_high_url "http://localhost/thumbnail.gif"
    api_thumbnail_high_width 480
    api_thumbnail_high_height 360
    api_thumbnail_standard_url "http://localhost/thumbnail.gif"
    api_thumbnail_standard_width 640
    api_thumbnail_standard_height 480
    api_thumbnail_maxres_url "http://localhost/thumbnail.gif"
    api_thumbnail_maxres_width 1280
    api_thumbnail_maxres_height 720

    factory :playlist_with_videos do
      transient do
        videocount 5
      end

      after(:create) do |playlist, factory|
        create_list(:video, factory.videocount, parent: playlist)
      end
    end
  end
end
