FactoryBot.define do
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
end
