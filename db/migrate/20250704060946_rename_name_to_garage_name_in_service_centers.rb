class RenameNameToGarageNameInServiceCenters < ActiveRecord::Migration[7.1]
  def change
    rename_column :service_centers, :name, :garage_name
  end
end
