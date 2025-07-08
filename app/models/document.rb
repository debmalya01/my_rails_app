class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  
  enum document_type: {
    rc_document: 'rc_document', license: 'license' 
  }

  validates :document_type, :number, presence: true
end
