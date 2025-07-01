class VehicleBrand < ApplicationRecord
    has_many :service_center_brands
    has_many :service_center, through: :service_center_brands
end
