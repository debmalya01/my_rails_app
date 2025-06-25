class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :car, null: false, foreign_key: true
      t.date :service_date
      t.text :notes

      t.timestamps
    end
  end
end
