class CreateBookingsServiceTypesJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :bookings, :service_types do |t|
      t.index :booking_id
      t.index :service_type_id
    end
  end
end
