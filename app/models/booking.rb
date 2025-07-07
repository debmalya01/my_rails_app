class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :service_center, optional: true

  has_many :booking_services, dependent: :destroy
  has_many :service_types, through: :booking_services

  enum status: {
    pending: 'pending',
    waiting_for_pickup: 'waiting_for_pickup',
    pickup_completed: 'pickup_completed',
    in_service: 'in_service',
    ready_for_dropoff: 'ready_for_dropoff',
    dropped_off: 'dropped_off',
    cancelled: 'cancelled' 
  }, _prefix: :status

  validates :status, inclusion: { in: statuses.keys }

  validates :service_date, presence: true 
  validate :service_date_cannot_be_in_the_past
  validates :service_types, presence: { message: "must include at least one service type" }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit number" }, presence: true


  def self.ransackable_attributes(auth_object = nil)
    ["service_date", "status"]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[car service_center]
  end

  private
  def service_date_cannot_be_in_the_past
    if service_date.present? && service_date < Date.today
      errors.add(:service_date, "can't be in the past")
    end
  end 
end
