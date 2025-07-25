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

  describe 'GET /api/v1/bookings/:id' do
    it 'returns a successful response with the requested booking' do
      get "/api/v1/bookings/#{booking.id}", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(booking.id)
      expect(json['car']['id']).to eq(car.id)
    end

    it 'returns a 404 if the booking does not exist' do
      get "/api/v1/bookings/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/cars/:car_id/bookings/new' do
    it "creates a new booking and returns it" do
      service_center # ensure it is created
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

      puts response.status
      puts response.body

      expect(response).to have_http_status(:created)
      expect(Booking.count).to eq(count_before + 1)

      json = JSON.parse(response.body)
      expect(json['car_id']).to eq(car.id)
      expect(json['service_date']).to eq(Date.tomorrow.to_s)
    end
  end

  describe 'PUT /api/v1/bookings/:id' do
    it "updates a existing booking and returns it" do
      service_center # ensure it is created
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
      puts response.status
      puts response.body

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['car_id']).to eq(car.id)
      expect(json['service_date']).to eq(Date.tomorrow.to_s)
      expect(json['pincode']).to eq("700055")
      expect(json['notes']).to eq("Test bookings")
    end

    it "returns 422 if update fails" do
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
      delete "/api/v1/bookings/#{booking.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it 'returns a 404 if the booking does not exist' do
      delete "/api/v1/bookings/9999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe 'GET /api/v1/bookings/new' do
    it 'returns a successful response for new booking form' do
      get "/api/v1/cars/#{car.id}/bookings/new", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/bookings/:id/edit' do
    it 'returns a successful response for edit booking form' do
      get "/api/v1/bookings/#{booking.id}/edit", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(booking.id)
      expect(json['car']['id']).to eq(car.id)
    end

    it 'returns a 404 if the booking does not exist' do
      get "/api/v1/bookings/9999/edit", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
      
      
