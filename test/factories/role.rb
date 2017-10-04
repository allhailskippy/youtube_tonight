FactoryGirl.define do
  factory :role do
    association :user
    title 'admin'
  end
end
