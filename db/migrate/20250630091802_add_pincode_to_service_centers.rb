class AddPincodeToServiceCenters < ActiveRecord::Migration[7.1]
  def change
    add_column :service_centers, :pincode, :string
  end
end
