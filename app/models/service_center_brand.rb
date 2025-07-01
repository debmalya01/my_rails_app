class ServiceCenterBrand < ApplicationRecord
  belongs_to :service_center
  belongs_to :vehicle_brand
end
