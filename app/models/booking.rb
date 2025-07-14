class Booking < ApplicationRecord
  after_create :generate_invoice
  after_update :generate_invoice
  belongs_to :car
  belongs_to :service_center, optional: true

  has_many :booking_services, dependent: :destroy
  has_many :service_types, through: :booking_services
  belongs_to :user, class_name: 'CarOwner', foreign_key: 'user_id'
  has_one :invoice, dependent: :destroy  

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
    ["notes", "service_date", "status", "pincode", "car_id", "service_center_id", "id", "booking_services_id", "service_types_id", "user_id", "invoice_id"]
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

  def generate_invoice
    create_invoice!(
      amount: calculate_invoice_amount,
      status: 'pending',
      issued_at: Date.today
    )
  end

  def calculate_invoice_amount
    service_type_ids.sum { |id| ServiceType.find(id).base_price}
  end
end
