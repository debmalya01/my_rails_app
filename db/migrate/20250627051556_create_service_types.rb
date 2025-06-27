class CreateServiceTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :service_types do |t|
      t.string :name
      t.decimal :base_price

      t.timestamps
    end
  end
end
