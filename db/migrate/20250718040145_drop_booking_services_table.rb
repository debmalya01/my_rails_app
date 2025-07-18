class DropBookingServicesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :booking_services
  end
end
