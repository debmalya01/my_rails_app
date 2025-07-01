class CreateServiceCenterBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :service_center_brands do |t|
      t.references :service_center, null: false, foreign_key: true
      t.references :vehicle_brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
