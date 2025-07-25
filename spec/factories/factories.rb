# Combined factories from all files in spec/factories

FactoryBot.define do
  
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "password" }
    type { nil }
  end

  factory :car_owner, class: 'CarOwner', parent: :user do
    name { "Car Owner" }
    type { "CarOwner" }
  end

  factory :garage_admin, class: 'GarageAdmin', parent: :user do
    name { "Garage Admin"}
    type { "GarageAdmin" }
  end

  # cars.rb
  factory :car do
    vehicle_brand
    model { "Camry" }
    year { 2020 }
    sequence(:registration_number) { |n| "REG#{n}" }
    car_owner
  end

  # bookings.rb
  factory :booking do
    association :user, factory: :car_owner
    car
    status { "pending" }
    pincode { "700000" }
    service_date { Date.tomorrow }
    service_center
    notes { "Test booking" }

    after(:build) do |booking|
      service_type = FactoryBot.create(:service_type)
      booking.service_types << service_type
    end
  end

  # service_types.rb
  factory :service_type do
    name { "Oil Change" }
    base_price { 50.0}
  end

  # vehicle_brands.rb
  factory :vehicle_brand do
    sequence(:name) { |n| "Brand#{n}" }
  end

  # service_centers.rb
  factory :service_center do
    garage_name { "Main Service Center" }
    pincode { "700000" }
    phone { "1234567890" }
    license_number { "LIC123456" }
    max_capacity_per_day { 20 }
    association :user, factory: :garage_admin
  end

  # service_center_brands.rb
  factory :service_center_brand do
    service_center
    vehicle_brand
  end

  # documents.rb
  factory :document do
    document_type { :rc_document }
    number { "DOC123456" }
    issued_at { Date.today }
    association :documentable, factory: :car
  end

  # invoices.rb
  factory :invoice do
    booking
    amount { 1000 }
    issued_at { Date.today }
    status { 'pending' }
  end
end 