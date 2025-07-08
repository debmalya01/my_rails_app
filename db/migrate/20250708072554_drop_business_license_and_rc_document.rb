class DropBusinessLicenseAndRcDocument < ActiveRecord::Migration[7.1]
  def change
    drop_table :business_licenses
    drop_table :rc_documents
  end
end
