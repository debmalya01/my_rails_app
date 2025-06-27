class CreateServiceCenters < ActiveRecord::Migration[7.1]
  def change
    create_table :service_centers do |t|
      t.string :name
      t.string :location
      t.string :phone

      t.timestamps
    end
  end
end
