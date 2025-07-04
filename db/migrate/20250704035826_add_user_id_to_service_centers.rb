class AddUserIdToServiceCenters < ActiveRecord::Migration[7.1]
  def change
    add_reference :service_centers, :user, null: false, foreign_key: true
  end
end
