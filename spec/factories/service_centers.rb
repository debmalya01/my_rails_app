FactoryBot.define do
  factory :service_center do
    garage_name { "Main Service Center" }
    pincode { "700000" }
    phone { "1234567890" }
    license_number { "LIC123456" }
    max_capacity_per_day { 20 }
    association :user, factory: :garage_admin
  end
end
    