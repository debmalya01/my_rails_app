require 'rails_helper'

RSpec.describe Api::V1::CarsController, type: :request do

  let(:user) { FactoryBot.create(:car_owner) }
  let(:vehicle_brand) { FactoryBot.create(:vehicle_brand) }
  let!(:car) { FactoryBot.create(:car, car_owner: user, vehicle_brand: vehicle_brand) }

  let(:access_token) { create_access_token_for(user) }

  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe 'GET /api/v1/cars' do
    it 'returns a successful response with cars' do
      get "/api/v1/cars", headers: headers 
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first['id']).to eq(car.id)
    end
  end

  describe 'GET /api/v1/cars/:id' do
    it 'returns a successful response with the requested car' do
      get "/api/v1/cars/#{car.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns a 404 if the car does not exist' do
      get "/api/v1/cars/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/cars' do

    it 'creates a new car and returns it' do
      expect {
        post "/api/v1/cars", params: {
          car: {
            model: 'Camry',
            year: 2020,
            registration_number: 'REG123',
            vehicle_brand_id: vehicle_brand.id
          }
        }, headers: headers
      }.to change(Car, :count).by(1)
    end
  end

  describe 'PUT /api/v1/cars/:id' do

    it 'returns a car with the updated attributes' do
      
      put "/api/v1/cars/#{car.id}", params:{
        id: car.id,
        car: {
          model: 'Updated Model',
          year: 2021,
          registration_number: 'REG456',
          vehicle_brand_id: vehicle_brand.id
        }
      }, headers: headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['model']).to eq('Updated Model')
      expect(json['year']).to eq(2021)
      expect(json['registration_number']).to eq('REG456')
    end
  end

  describe 'DELETE /api/v1/cars/:id' do
    it 'deletes the car and returns see other' do
      expect {
        delete "/api/v1/cars/#{car.id}", headers: headers
      }.to change(Car, :count).by(-1)
      
      expect(response).to have_http_status(:see_other)
    end

    it 'returns a 404 if the car does not exist' do
      delete "/api/v1/cars/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/cars/new' do
    it 'returns a successful response for new car form' do
      get "/api/v1/cars/new", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['current_user']['id']).to eq(user.id)
    end
  end

end 