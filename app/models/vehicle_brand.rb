class VehicleBrand < ApplicationRecord
    has_many :cars
    has_many :service_center_brands
    has_many :service_center, through: :service_center_brands
    validates :name, presence: true, uniqueness: true

    def self.ransackable_attributes(auth_object = nil)
        ["id", "name"]
    end
end
