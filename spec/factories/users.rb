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
end