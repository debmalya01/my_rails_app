class ServiceCenter < ApplicationRecord
    has_many :bookings
    has_many :service_center_brands
    has_many :vehicle_brands, through: :service_center_brands
end
