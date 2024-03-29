FactoryGirl.define do
  factory :show do
    air_date { Date.tomorrow }
    sequence(:title) {|n| "Show Title #{n}" }
    users { [FactoryGirl.create(:user)] }

    factory :show_with_videos do
      transient do
        video_count 5
      end

      after(:create) do |show, factory|
        create_list(:video, factory.video_count, parent: show)
      end
    end
  end
end
