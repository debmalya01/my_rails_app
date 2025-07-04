class RemoveLocationFromServiceCenter < ActiveRecord::Migration[7.1]
  def change
    remove_column :service_centers, :location, :string
  end
end
