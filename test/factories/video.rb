FactoryGirl.define do
  factory :video do
    association :parent, factory: :show
    sequence(:title) {|n| "Video Title #{n}" }
    sequence(:link) {|n| "http://localhost/video_id/#{n}" }
    sequence(:api_video_id) {|n| "video_id_#{n}" }
    api_description "Video Descripton"
    api_thumbnail_medium_url "http://localhost/thumbnail.gif"
    api_thumbnail_default_url "http://localhost/thumbnail.gif"
    api_thumbnail_high_url "http://localhost/thumbnail.gif"
    sequence(:api_title) {|n| "Api Title #{n}" }
    api_duration "PT22S"
    api_duration_seconds 22
  end
end
