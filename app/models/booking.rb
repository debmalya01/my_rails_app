class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :service_center, optional: true

  has_many :booking_services, dependent: :destroy
  has_many :service_types, through: :booking_services
end
