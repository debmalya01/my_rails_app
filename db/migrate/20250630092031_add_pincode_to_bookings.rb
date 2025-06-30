class AddPincodeToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :pincode, :string
  end
end
