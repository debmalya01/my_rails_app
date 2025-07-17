require 'rails_helper'

RSpec.describe "Api::V1::GarageBookingsController", type: :request do
  let(:garage_admin) { FactoryBot.create(:garage_admin) }
  let(:service_center) { FactoryBot.create(:service_center, user: garage_admin) }
  let(:car) { FactoryBot.create(:car) }
  let!(:booking) { FactoryBot.create(:booking, service_center: service_center, car: car) }

  let(:access_token) { create_access_token_for(garage_admin) }
  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe "GET /api/v1/garages/:id" do
    it "returns a list of bookings for the garage" do
      get "/api/v1/garages/#{service_center.id}", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["garage"]["id"]).to eq(service_center.id)
      expect(json["bookings"].first["id"]).to eq(booking.id)
      expect(json["bookings"].first["car"]["id"]).to eq(car.id)
    end
  end

  describe "GET /api/v1/garages/:id/bookings/:id/edit" do
    it "returns a specific booking's details" do
      get "/api/v1/garages/#{service_center.id}/bookings/#{booking.id}/edit", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(booking.id)
      expect(json["car"]["id"]).to eq(car.id)
    end
  end

  describe "PUT /api/v1/garages/:id/bookings/:id" do
    it "updates the booking status" do
      put "/api/v1/garages/#{service_center.id}/bookings/#{booking.id}", params: {
        booking: { status: "in_service" }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      booking.reload
      expect(booking.status).to eq("in_service")
    end

    it "returns 422 if update fails" do
      put "/api/v1/garages/#{service_center.id}/bookings/#{booking.id}", params: {
        booking: { status: nil }
      }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Booking status could not be updated.")
    end
  end
end
