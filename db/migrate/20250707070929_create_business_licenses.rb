class CreateBusinessLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :business_licenses do |t|
      t.references :document, null: false, foreign_key: true
      t.string :license_number
      t.string :issued_by

      t.timestamps
    end
  end
end
