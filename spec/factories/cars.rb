FactoryBot.define do
    factory :car do
        vehicle_brand
        model { "Camry" }
        year { 2020 }
        sequence(:registration_number) { |n| "REG#{n}" }
        car_owner
    end
end