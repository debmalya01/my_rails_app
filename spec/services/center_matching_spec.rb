require 'rails_helper'

RSpec.describe CenterMatchingService do
  describe '.find_nearest_available_for' do
    let(:vehicle_brand) { FactoryBot.create(:vehicle_brand) }
    let(:car_owner) { FactoryBot.create(:car_owner) }

    let(:service_center_1) { FactoryBot.create(:service_center, pincode: 110001, max_capacity_per_day: 2) }
    let(:service_center_2) { FactoryBot.create(:service_center, pincode: 110005, max_capacity_per_day: 2) }

    let!(:scb1) { FactoryBot.create(:service_center_brand, service_center: service_center_1, vehicle_brand: vehicle_brand) }
    let!(:scb2) { FactoryBot.create(:service_center_brand, service_center: service_center_2, vehicle_brand: vehicle_brand) }

    let(:car) { FactoryBot.create(:car, car_owner: car_owner, vehicle_brand: vehicle_brand) }

    let(:booking_date) { Date.today }

    let(:booking) do
      FactoryBot.create(:booking, car: car, pincode: 110002, service_date: booking_date)
    end

    before do
      # Only service_center_2 is full
      FactoryBot.create_list(:booking, 2, service_center: service_center_2, service_date: booking_date)
    end

    it 'returns the nearest available service center' do
      result = CenterMatchingService.find_nearest_available_for(booking)
      expect(result).to eq(service_center_1)
    end

    it 'returns nil if no service center is available' do
      # Fill up service_center_1 too
      FactoryBot.create_list(:booking, 2, service_center: service_center_1, service_date: booking_date)
      
      result = CenterMatchingService.find_nearest_available_for(booking)
      expect(result).to be_nil
    end
  end
end
