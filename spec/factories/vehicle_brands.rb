FactoryBot.define do
  factory :vehicle_brand do
    sequence(:name) { |n| "Brand#{n}" }
  end
end
