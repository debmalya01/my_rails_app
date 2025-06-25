class Car < ApplicationRecord
    has_many :bookings, dependent: :destroy
end
