require 'rails_helper'

RSpec.describe ServiceCenter, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      service_center = FactoryBot.build(:service_center)
      expect(service_center).to be_valid
    end

    it "is invalid without a garage_name" do
      service_center = FactoryBot.build(:service_center, garage_name: nil)
      expect(service_center).not_to be_valid
    end

    it "is invalid with an incorrectly formatted phone number" do
      service_center = FactoryBot.build(:service_center, phone: "123")
      expect(service_center).not_to be_valid
    end

    it "is invalid with an incorrectly formatted pincode" do
      service_center = FactoryBot.build(:service_center, pincode: "12345")
      expect(service_center).not_to be_valid
    end

    it "is invalid with a non-numeric max_capacity_per_day" do
      service_center = FactoryBot.build(:service_center, max_capacity_per_day: "ten")
      expect(service_center).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a user (GarageAdmin)" do
      admin = FactoryBot.create(:garage_admin)
      service_center = FactoryBot.create(:service_center, user: admin)
      expect(service_center.user).to eq(admin)
    end

    it "has many bookings" do
      service_center = FactoryBot.create(:service_center)
      booking1 = FactoryBot.create(:booking, service_center: service_center)
      booking2 = FactoryBot.create(:booking, service_center: service_center)
      expect(service_center.bookings).to include(booking1, booking2)
    end
  end

  describe "callbacks" do
    it "creates a license document after creation" do
      service_center = FactoryBot.create(:service_center, license_number: "LIC123")
      document = service_center.documents.last
      expect(document).not_to be_nil
      expect(document.document_type).to eq("license")
      expect(document.number).to eq("LIC123")
    end
  end

  describe "#bookings_count" do
    it "returns the correct count of bookings" do
      service_center = FactoryBot.create(:service_center)
      FactoryBot.create_list(:booking, 3, service_center: service_center)
      expect(service_center.bookings_count).to eq(3)
    end
  end
end
