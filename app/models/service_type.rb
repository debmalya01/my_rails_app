class ServiceType < ApplicationRecord
    has_and_belongs_to_many :bookings
    def self.ransackable_attributes(auth_object = nil)
        ["base_price", "created_at", "id", "id_value", "name", "updated_at"]
    end
end