class RcDocument < ApplicationRecord
  belongs_to :document
  validates :rc_number, presence: true, uniqueness: true
end
