class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  attr_accessor :garage_name, :license_number, :location, :pincode, :phone, :max_capacity_per_day

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def car_owner?
    type == 'CarOwner'
  end

  def garage_admin?
    type == 'GarageAdmin'
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email type]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[cars]
  end
  
end
