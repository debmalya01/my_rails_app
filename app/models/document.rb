class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  has_one :rc_document, dependent: :destroy
  has_one :business_license, dependent: :destroy
end
