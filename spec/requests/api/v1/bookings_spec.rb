require 'rails_helper'

RSpec.describe Api::V1::BookingsController, type: :request do

  let(:user) { FactoryBot.create(:car_owner) }
  let(:vehicle_brand) { FactoryBot.create(:vehicle_brand) }
  let(:service_center) do
    sc = FactoryBot.create(:service_center, pincode: "700050")
    FactoryBot.create(:service_center_brand, service_center: sc, vehicle_brand: vehicle_brand)
    sc
  end

  let!(:car) { FactoryBot.create(:car, car_owner: user, vehicle_brand: vehicle_brand) }
  let(:booking) { FactoryBot.create(:booking, car: car, user: user) }

  let(:access_token) { create_access_token_for(user) }

  let(:headers) do 
    {
      "Authorization" => "Bearer #{access_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe 'GET /api/v1/bookings/history' do
    it 'returns paginated booking history' do
      # Create test bookings
      FactoryBot.create_list(:booking, 3, car: car, user: user)
      
      # Stub logging
      allow(LogBroadcaster).to receive(:log)
      
      get "/api/v1/bookings/history?page=1&per_page=2", headers: headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      
      # Check pagination structure
      expect(json).to have_key('bookings')
      expect(json).to have_key('pagination')
      expect(json['pagination']['per_page']).to eq(2)
      expect(json['pagination']['current_page']).to eq(1)
      
      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with(match(/Fetched \d+ booking history entries/), level: :info)
    end
  end

  describe 'GET /api/v1/bookings/:id' do
    it 'returns a successful response with the requested booking' do
      # Stub logging
      allow(LogBroadcaster).to receive(:log)
      
      get "/api/v1/bookings/#{booking.id}", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(booking.id)
      expect(json['car']['id']).to eq(car.id)
      
      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with(match(/Showing booking details for booking ID/), level: :info)
    end

    it 'returns a 404 if the booking does not exist' do
      get "/api/v1/bookings/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/cars/:car_id/bookings/new' do
    it "creates a new booking and returns it" do
      service_center # ensure it is created
      
      # Stub external service to control behavior
      allow(CenterMatchingService).to receive(:find_nearest_available_for)
        .and_return(service_center)
      
      # Stub logging calls
      allow(LogBroadcaster).to receive(:log)
      
      count_before = Booking.count
      post "/api/v1/cars/#{car.id}/bookings", params: {
        booking: {
          car_id: car.id,
          service_date: Date.tomorrow,
          pincode: "700050",
          status: "pending",
          notes: "Test booking",
          service_type_ids: [FactoryBot.create(:service_type).id]
        }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(Booking.count).to eq(count_before + 1)

      json = JSON.parse(response.body)
      expect(json['car_id']).to eq(car.id)
      expect(json['service_date']).to eq(Date.tomorrow.to_s)
      
      # Verify service interactions
      expect(CenterMatchingService).to have_received(:find_nearest_available_for)
      expect(LogBroadcaster).to have_received(:log).with(match(/Booking created successfully/), level: :info)
    end
  end

  describe 'PUT /api/v1/bookings/:id' do
    it "updates a existing booking and returns it" do
      service_center # ensure it is created
      
      # Stub external service
      allow(CenterMatchingService).to receive(:find_nearest_available_for)
        .and_return(service_center)
      
      # Stub logging calls
      allow(LogBroadcaster).to receive(:log)
      
      put "/api/v1/bookings/#{booking.id}", params: {
        id: booking.id,
        booking: {
          car_id: car.id,
          service_date: Date.tomorrow,
          pincode: "700055",
          status: "pending",
          notes: "Test bookings",
          service_type_ids: [FactoryBot.create(:service_type).id]
        }
      }, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['car_id']).to eq(car.id)
      expect(json['service_date']).to eq(Date.tomorrow.to_s)
      expect(json['pincode']).to eq("700055")
      expect(json['notes']).to eq("Test bookings")
      
      # Verify service interactions
      expect(LogBroadcaster).to have_received(:log).with(match(/Booking updated successfully/), level: :info)
    end

    it "returns 422 if update fails" do
      # Stub to return nil (no service center found)
      allow(CenterMatchingService).to receive(:find_nearest_available_for)
        .and_return(nil)
      
      put "/api/v1/bookings/#{booking.id}", params: {
        id: booking.id,
        booking: {
          car_id: car.id,
          service_date: Date.yesterday, # invalid date
          pincode: "700055",
          status: "pending",
          notes: "Test bookings",
          service_type_ids: [FactoryBot.create(:service_type).id]
        }
      }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq("No nearby compatible service center found for the selected brand and location.")
    end 
  end

  describe 'DELETE /api/v1/bookings/:id' do
    it 'deletes the booking and returns see other' do
      # Stub logging for delete operation
      allow(LogBroadcaster).to receive(:log)
      
      delete "/api/v1/bookings/#{booking.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      
      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with(match(/Booking deleted successfully/), level: :info)
    end

    it 'returns a 404 if the booking does not exist' do
      delete "/api/v1/bookings/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe 'GET /api/v1/bookings/new' do
    it 'returns a successful response for new booking form' do
      # Stub logging
      allow(LogBroadcaster).to receive(:log)
      
      get "/api/v1/cars/#{car.id}/bookings/new", headers: headers
      expect(response).to have_http_status(:ok)
      
      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with(match(/Creating a new booking for car/), level: :info)
    end
  end

  describe 'GET /api/v1/bookings/:id/edit' do
    it 'returns a successful response for edit booking form' do
      # Stub logging
      allow(LogBroadcaster).to receive(:log)
      
      get "/api/v1/bookings/#{booking.id}/edit", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(booking.id)
      expect(json['car']['id']).to eq(car.id)
      
      # Verify logging was called
      expect(LogBroadcaster).to have_received(:log).with(match(/Editing booking ID/), level: :info)
    end

    it 'returns a 404 if the booking does not exist' do
      get "/api/v1/bookings/9999/edit", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
      
      
