class DropRcDocumentsAndBusinessLicensesTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :rc_documents, if_exists: true
    drop_table :business_licenses, if_exists: true
  end
end
