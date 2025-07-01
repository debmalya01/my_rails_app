class AddVehicleBrandToCars < ActiveRecord::Migration[7.1]
  def change
    add_reference :cars, :vehicle_brand, null: true, foreign_key: true
  end
end
