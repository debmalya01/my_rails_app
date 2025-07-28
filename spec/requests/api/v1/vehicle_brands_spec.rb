require 'rails_helper'

RSpec.describe Api::V1::VehicleBrandsController, type: :request do

  describe "GET /api/v1/vehicle_brands" do
    it "returns mocked vehicle brands without hitting DB" do
      # Stub VehicleBrand.all
      mocked_brands = [
        double("VehicleBrand", id: 1, name: "Toyota", as_json: { id: 1, name: "Toyota" }),
        double("VehicleBrand", id: 2, name: "Honda", as_json: { id: 2, name: "Honda" })
      ]
      allow(VehicleBrand).to receive(:all).and_return(mocked_brands)

      # Stub LogBroadcaster
      allow(LogBroadcaster).to receive(:log)

      get "/api/v1/vehicle_brands"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.first["name"]).to eq("Toyota")

      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with("Fetched 2 vehicle brands", level: :info)
    end
  end
end
