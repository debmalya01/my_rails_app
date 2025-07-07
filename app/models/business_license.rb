class BusinessLicense < ApplicationRecord
  belongs_to :document
  validates :issued_by, presence: true
  validates :license_number, presence: true, uniqueness: true
end
