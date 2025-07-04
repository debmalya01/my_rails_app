class AddLicenseNumberToServiceCenters < ActiveRecord::Migration[7.1]
  def change
    add_column :service_centers, :license_number, :string
  end
end
