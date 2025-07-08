class Invoice < ApplicationRecord
  belongs_to :booking
  has_one :car_owner, through: :booking, source: :user

  validates :amount, presence: true
end
