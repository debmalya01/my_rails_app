class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :document_type
      t.string :number
      t.datetime :issued_at
      t.references :documentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
