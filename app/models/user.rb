class User < ApplicationRecord
  has_many :cars, dependent: :destroy
  has_many :bookings, through: :cars

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
