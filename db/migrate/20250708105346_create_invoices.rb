class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :booking, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.date :issued_at

      t.timestamps
    end
  end
end
