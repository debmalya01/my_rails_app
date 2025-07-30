require 'rails_helper'

RSpec.describe Api::V1::VehicleBrandsController, type: :request do

  describe "GET /api/v1/vehicle_brands" do
    it "returns vehicle brands successfully" do
      # Create real test data with unique names
      FactoryBot.create(:vehicle_brand, name: "Toyota")
      FactoryBot.create(:vehicle_brand, name: "Honda")
      FactoryBot.create(:vehicle_brand, name: "Ford")
      
      # Stub logging (external concern, not core business logic)
      allow(LogBroadcaster).to receive(:log)

      get "/api/v1/vehicle_brands"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(json.map { |brand| brand["name"] }).to include("Toyota", "Honda", "Ford")

      # Verify logging was called with correct message
      expect(LogBroadcaster).to have_received(:log).with("Fetched 3 vehicle brands", level: :info)
    end
  end
end
