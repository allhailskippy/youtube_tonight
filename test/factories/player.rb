FactoryGirl.define do
  factory :player do
    association :user
    sequence(:player_id) {|n| "player-#{n}" }
    live false
  end
end
