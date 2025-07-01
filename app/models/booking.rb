class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :service_center, optional: true

  has_many :booking_services, dependent: :destroy
  has_many :service_types, through: :booking_services

  validates :service_date, presence: true 
  validate :service_date_cannot_be_in_the_past
  validates :service_types, presence: { message: "must include at least one service type" }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit number" }, presence: true

  private
  def service_date_cannot_be_in_the_past
    if service_date.present? && service_date < Date.today
      errors.add(:service_date, "can't be in the past")
    end
  end 
end
