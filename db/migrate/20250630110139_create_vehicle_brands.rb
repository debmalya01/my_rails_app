class CreateVehicleBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicle_brands do |t|
      t.string :name

      t.timestamps
    end
  end
end
