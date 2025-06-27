class CreateBookingServices < ActiveRecord::Migration[7.1]
  def change
    create_table :booking_services do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
