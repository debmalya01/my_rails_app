class AddMaxCapacityToServiceCenters < ActiveRecord::Migration[7.1]
  def change
    add_column :service_centers, :max_capacity_per_day, :integer
  end
end
