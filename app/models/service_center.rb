class ServiceCenter < ApplicationRecord
    belongs_to :user, class_name: 'GarageAdmin'
    has_many :bookings
    has_many :service_center_brands
    has_many :vehicle_brands, through: :service_center_brands

    validates :garage_name, :phone, :pincode, presence: true
    validates :phone, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
    validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit number" }
    validates :max_capacity_per_day, numericality: { only_integer: true, greater_than: 0 }
end
