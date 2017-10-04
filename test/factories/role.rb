FactoryGirl.define do
  factory :role do
    association :user
    sequence(:title) {|n| "role#{n}" }
  end
end
