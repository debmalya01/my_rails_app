class GarageAdmin < User
  has_one :service_center, foreign_key: :user_id, dependent: :destroy
end