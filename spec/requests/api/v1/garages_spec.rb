require 'rails_helper'

RSpec.describe Api::V1::GaragesController, type: :request do

  let!(:user) { FactoryBot.create(:garage_admin) }
  let!(:service_center) { FactoryBot.create(:service_center, user: user) }
  let(:access_token) { create_access_token_for(user) }
  
  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe 'GET /api/v1/garages' do
    it 'returns a successful response with garages' do
      get "/api/v1/garages", headers: headers
      puts response.body
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['id']).to eq(service_center.id)
    end
  end

  describe 'GET /api/v1/garages/:id' do
    it 'returns a successful response with the requested garage' do
      get "/api/v1/garages/#{service_center.id}", headers: headers
      puts response.body
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['garage']['id']).to eq(service_center.id)
      expect(json['garage']['user_id']).to eq(user.id)
      expect(json['bookings']).to be_an(Array)
    end
  end
end