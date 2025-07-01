class Car < ApplicationRecord
    has_many :bookings, dependent: :destroy
    belongs_to :vehicle_brand

    validates :model, :owner_name, :registration_number, presence: true
    validates :registration_number, uniqueness: true
end
