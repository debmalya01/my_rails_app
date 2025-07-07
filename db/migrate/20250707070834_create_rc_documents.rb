class CreateRcDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :rc_documents do |t|
      t.references :document, null: false, foreign_key: true
      t.string :rc_number
      t.date :issue_date

      t.timestamps
    end
  end
end
