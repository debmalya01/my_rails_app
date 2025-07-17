require 'rails_helper'

RSpec.describe Api::V1::ServiceTypesController, type: :request do
  
  describe 'GET /api/v1/service_types' do
    it 'returns a successful response with all service types' do
      FactoryBot.create_list(:service_type, 5) # Create some service types for testing
      
      get "/api/v1/service_types"
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(5) # Adjust based on how many you created
    end
  end
end