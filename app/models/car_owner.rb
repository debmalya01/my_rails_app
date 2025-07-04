class CarOwner < User
  has_many :cars, foreign_key: 'user_id' ,dependent: :destroy
  has_many :bookings, through: :cars
end