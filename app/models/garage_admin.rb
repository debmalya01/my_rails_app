class GarageAdmin < User
  has_one :service_center, foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :service_center
  validates_associated :service_center

end