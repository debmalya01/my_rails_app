class GarageAdmin < User
  has_one :service_center, foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :service_center
  validates_associated :service_center

  after_initialize :build_service_center_if_nil

  private

  def build_service_center_if_nil
    build_service_center if new_record? && service_center.nil?
  end

end