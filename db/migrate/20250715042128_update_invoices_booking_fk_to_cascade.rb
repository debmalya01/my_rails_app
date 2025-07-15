class UpdateInvoicesBookingFkToCascade < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :invoices, :bookings
    add_foreign_key :invoices, :bookings, on_delete: :cascade
  end
end
