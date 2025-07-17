require 'rails_helper'

RSpec.describe Api::V1::VehicleBrandsController, type: :request do 
  
  describe 'GET /api/v1/vehicle_brands' do
    it 'returns a successful response with all vehicle brands' do
      FactoryBot.create_list(:vehicle_brand, 5) # Create some vehicle brands for testing
      
      get "/api/v1/vehicle_brands", headers: headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(5) # Adjust based on how many you created
    end
  end
end