require 'rails_helper'

RSpec.describe Api::V1::CarsController, type: :request do

  let(:car_owner) { FactoryBot.create(:car_owner) }
  let(:garage_admin) { FactoryBot.create(:garage_admin) }
  let(:vehicle_brand) { FactoryBot.create(:vehicle_brand) }
  let!(:car) { FactoryBot.create(:car, car_owner: car_owner, vehicle_brand: vehicle_brand) }
  let!(:other_user) { FactoryBot.create(:car_owner) }
  let!(:other_car) { FactoryBot.create(:car, car_owner: other_user, vehicle_brand: vehicle_brand) }

  let(:car_owner_token) { create_access_token_for(car_owner) }
  let(:garage_admin_token) { create_access_token_for(garage_admin) }

  let(:car_owner_headers) do
    {
      "Authorization" => "Bearer #{car_owner_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  let(:garage_admin_headers) do
    {
      "Authorization" => "Bearer #{garage_admin_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe 'GET /api/v1/cars' do
    context 'when user is a car owner' do
      it 'returns a successful response with cars' do
        # Stub logging
        allow(LogBroadcaster).to receive(:log)
        
        get "/api/v1/cars", headers: car_owner_headers 
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        cars = json['cars']
        expect(cars.first['id']).to eq(car.id)
        
        # Verify logging was called
        expect(LogBroadcaster).to have_received(:log).with(match(/Fetched \d+ cars for user/), level: :info)
      end

      it 'only returns cars belonging to the authenticated user' do
        # Stub logging
        allow(LogBroadcaster).to receive(:log)
        
        get "/api/v1/cars", headers: car_owner_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        cars = json['cars']
        car_ids = cars.map { |c| c['id'] }
        expect(car_ids).to include(car.id)
        expect(car_ids).not_to include(other_car.id)
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        get "/api/v1/cars", headers: garage_admin_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
        expect(json['user_type']).to eq('GarageAdmin')
        expect(json['required_type']).to eq('CarOwner')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get "/api/v1/cars"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/cars/:id' do
    context 'when user is a car owner' do
      it 'returns a successful response with the requested car' do
        # Stub logging
        allow(LogBroadcaster).to receive(:log)
        
        get "/api/v1/cars/#{car.id}", headers: car_owner_headers
        expect(response).to have_http_status(:ok)
        
        # Verify logging was called
        expect(LogBroadcaster).to have_received(:log).with(match(/Showing car details for car ID/), level: :info)
      end

      it 'returns 404 if the car does not exist' do
        get "/api/v1/cars/999999", headers: car_owner_headers
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Car not found')
        expect(json['car_id']).to eq('999999')
      end

      it 'returns 403 if the car belongs to another user' do
        get "/api/v1/cars/#{other_car.id}", headers: car_owner_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('You are not authorized to access this car.')
        expect(json['car_id']).to eq(other_car.id.to_s)
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        get "/api/v1/cars/#{car.id}", headers: garage_admin_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

  describe 'POST /api/v1/cars' do
    context 'when user is a car owner' do
      it 'creates a new car and returns it' do
        expect {
          post "/api/v1/cars", params: {
            car: {
              model: 'Camry',
              year: 2020,
              registration_number: 'REG123',
              vehicle_brand_id: vehicle_brand.id
            }
          }, headers: car_owner_headers
        }.to change(Car, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['model']).to eq('Camry')
        expect(json['year']).to eq(2020)
        expect(json['registration_number']).to eq('REG123')
      end

      it 'returns validation errors when car data is invalid' do
        post "/api/v1/cars", params: {
          car: {
            model: '',
            year: 'invalid',
            registration_number: '',
            vehicle_brand_id: nil
          }
        }, headers: car_owner_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Validation failed')
        expect(json['details']).to be_an(Array)
        expect(json['invalid_attributes']).to be_an(Array)
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        post "/api/v1/cars", params: {
          car: {
            model: 'Camry',
            year: 2020,
            registration_number: 'REG123',
            vehicle_brand_id: vehicle_brand.id
          }
        }, headers: garage_admin_headers
        
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

  describe 'PUT /api/v1/cars/:id' do
    context 'when user is a car owner' do
      it 'returns a car with the updated attributes' do
        put "/api/v1/cars/#{car.id}", params:{
          id: car.id,
          car: {
            model: 'Updated Model',
            year: 2021,
            registration_number: 'REG456',
            vehicle_brand_id: vehicle_brand.id
          }
        }, headers: car_owner_headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['model']).to eq('Updated Model')
        expect(json['year']).to eq(2021)
        expect(json['registration_number']).to eq('REG456')
      end

      it 'returns validation errors when update data is invalid' do
        put "/api/v1/cars/#{car.id}", params:{
          id: car.id,
          car: {
            model: '',
            year: 'invalid',
            registration_number: '',
            vehicle_brand_id: nil
          }
        }, headers: car_owner_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Validation failed')
        expect(json['details']).to be_an(Array)
        expect(json['invalid_attributes']).to be_an(Array)
      end

      it 'returns 404 if the car does not exist' do
        put "/api/v1/cars/999999", params: {
          car: { model: 'Test' }
        }, headers: car_owner_headers
        
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Car not found')
      end

      it 'returns 403 if the car belongs to another user' do
        put "/api/v1/cars/#{other_car.id}", params: {
          car: { model: 'Unauthorized Update' }
        }, headers: car_owner_headers
        
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('You are not authorized to access this car.')
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        put "/api/v1/cars/#{car.id}", params: {
          car: { model: 'Admin Update' }
        }, headers: garage_admin_headers
        
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

  describe 'DELETE /api/v1/cars/:id' do
    context 'when user is a car owner' do
      it 'deletes the car and returns success message' do
        expect {
          delete "/api/v1/cars/#{car.id}", headers: car_owner_headers
        }.to change(Car, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Car was successfully destroyed.')
      end

      it 'returns 404 if the car does not exist' do
        delete "/api/v1/cars/999999", headers: car_owner_headers
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Car not found')
      end

      it 'returns 403 if the car belongs to another user' do
        delete "/api/v1/cars/#{other_car.id}", headers: car_owner_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('You are not authorized to access this car.')
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        delete "/api/v1/cars/#{car.id}", headers: garage_admin_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

  describe 'GET /api/v1/cars/new' do
    context 'when user is a car owner' do
      it 'returns a successful response for new car form' do
        get "/api/v1/cars/new", headers: car_owner_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['current_user']['id']).to eq(car_owner.id)
        expect(json['car']).to be_present
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        get "/api/v1/cars/new", headers: garage_admin_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

  describe 'GET /api/v1/cars/:id/edit' do
    context 'when user is a car owner' do
      it 'returns car data for editing' do
        get "/api/v1/cars/#{car.id}/edit", headers: car_owner_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(car.id)
        expect(json['vehicle_brand']).to be_present
      end

      it 'returns 404 if the car does not exist' do
        get "/api/v1/cars/999999/edit", headers: car_owner_headers
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Car not found')
      end

      it 'returns 403 if the car belongs to another user' do
        get "/api/v1/cars/#{other_car.id}/edit", headers: car_owner_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('You are not authorized to access this car.')
      end
    end

    context 'when user is a garage admin' do
      it 'returns forbidden status' do
        get "/api/v1/cars/#{car.id}/edit", headers: garage_admin_headers
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied. Only car owners can manage cars.')
      end
    end
  end

end 