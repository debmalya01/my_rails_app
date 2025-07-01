class Car < ApplicationRecord
    has_many :bookings, dependent: :destroy
    belongs_to :vehicle_brand
end
