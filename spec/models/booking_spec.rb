require 'rails_helper'

RSpec.describe Booking, type: :model do
  
    it "is valid with valid atributes" do
      booking = FactoryBot.build(:booking)
      expect(booking).to be_valid
    end

    it "is not valid wihtout a user" do
      booking = FactoryBot.build(:booking, user: nil)
      expect(booking).not_to be_valid
    end

    it "is not valid without a car" do
      booking = FactoryBot.build(:booking, car: nil)
      expect(booking).not_to be_valid
    end

    # it "is not valid without a service center" do
    #   booking = FactoryBot.build(:booking, service_center: nil)
    #   expect(booking).not_to be_valid
    # end

    it "is not valid without a service date" do
      booking = FactoryBot.build(:booking, service_date: nil)
      expect(booking).not_to be_valid
    end
    
    it "is not valid with a past service date" do
      booking = FactoryBot.build(:booking, service_date: Date.yesterday)
      expect(booking).not_to be_valid
    end

    it "is not valid without a status" do
      booking = FactoryBot.build(:booking, status: nil)
      expect(booking).not_to be_valid
    end

    it "is invalid without atleast one service type" do
      booking = FactoryBot.build(:booking)
      booking.service_types.clear
      expect(booking).not_to be_valid
      expect(booking.errors[:service_types]).to include("must include at least one service type")
    end

    it "is not valid with an invalid pincode" do
      booking = FactoryBot.build(:booking, pincode: "12345")
      expect(booking).not_to be_valid
    end

    it "is valid with a 6-digit pincode" do
      booking = FactoryBot.build(:booking, pincode: "123456")
      expect(booking).to be_valid
    end
end