require 'rails_helper'

RSpec.describe Api::V1::GarageVehicleBrandsController, type: :request do
  let!(:garage_admin) { FactoryBot.create(:garage_admin) }
  let!(:service_center) { FactoryBot.create(:service_center, user: garage_admin) }
  let!(:vehicle_brand1) { FactoryBot.create(:vehicle_brand, name: "Toyota") }
  let!(:vehicle_brand2) { FactoryBot.create(:vehicle_brand, name: "Honda") }
  let!(:vehicle_brand3) { FactoryBot.create(:vehicle_brand, name: "Ford") }
  let(:access_token) { create_access_token_for(garage_admin) }
  
  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token.token}",
      "ACCEPT" => "application/json"
    }
  end

  describe 'GET /api/v1/garage-vehicle-brands' do
    context 'when user is authenticated as garage admin' do
      it 'returns all vehicle brands with selected brand ids', aggregate_failures: true do
        # Associate some brands with the service center
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand1)
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand2)

        get "/api/v1/garage-vehicle-brands", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['vehicle_brands']).to be_an(Array)
        expect(json['vehicle_brands'].size).to eq(3)
        expect(json['selected_brand_ids']).to contain_exactly(vehicle_brand1.id, vehicle_brand2.id)
        expect(json['service_center']['id']).to eq(service_center.id)
        expect(json['service_center']['garage_name']).to eq(service_center.garage_name)
      end

      it 'returns empty selected_brand_ids when no brands are associated', aggregate_failures: true do
        get "/api/v1/garage-vehicle-brands", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['selected_brand_ids']).to be_empty
        expect(json['vehicle_brands'].size).to eq(3)
      end
    end

    context 'when user is not a garage admin' do
      let!(:car_owner) { FactoryBot.create(:car_owner) }
      let(:car_owner_token) { create_access_token_for(car_owner) }
      let(:car_owner_headers) do
        {
          "Authorization" => "Bearer #{car_owner_token.token}",
          "ACCEPT" => "application/json"
        }
      end

      it 'returns forbidden status', aggregate_failures: true do
        get "/api/v1/garage-vehicle-brands", headers: car_owner_headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied.')
      end
    end

    context 'when garage admin has no service center' do
      let!(:garage_admin_without_center) { FactoryBot.create(:garage_admin) }
      let(:no_center_token) { create_access_token_for(garage_admin_without_center) }
      let(:no_center_headers) do
        {
          "Authorization" => "Bearer #{no_center_token.token}",
          "ACCEPT" => "application/json"
        }
      end

      it 'returns not found status', aggregate_failures: true do
        get "/api/v1/garage-vehicle-brands", headers: no_center_headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Service center not found.')
      end
    end
  end

  describe 'PUT /api/v1/garage-vehicle-brands' do
    context 'when user is authenticated as garage admin' do
      it 'updates vehicle brands successfully', aggregate_failures: true do
        # Pre-associate some brands
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand1)
        
        put "/api/v1/garage-vehicle-brands", 
            params: { vehicle_brand_ids: [vehicle_brand2.id, vehicle_brand3.id] }.to_json,
            headers: headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['message']).to eq('Vehicle brands updated successfully!')
        expect(json['selected_brand_ids']).to contain_exactly(vehicle_brand2.id, vehicle_brand3.id)
        
        # Verify the associations were updated in the database
        service_center.reload
        expect(service_center.vehicle_brand_ids).to contain_exactly(vehicle_brand2.id, vehicle_brand3.id)
      end

      it 'clears all vehicle brands when empty array is provided', aggregate_failures: true do
        # Pre-associate some brands
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand1)
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand2)
        
        put "/api/v1/garage-vehicle-brands", 
            params: { vehicle_brand_ids: [] }.to_json,
            headers: headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['selected_brand_ids']).to be_empty
        service_center.reload
        expect(service_center.vehicle_brand_ids).to be_empty
      end

      it 'handles missing vehicle_brand_ids parameter gracefully', aggregate_failures: true do
        put "/api/v1/garage-vehicle-brands", 
            params: {}.to_json,
            headers: headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['selected_brand_ids']).to be_empty
      end

      it 'returns error when invalid brand id is provided', aggregate_failures: true do
        put "/api/v1/garage-vehicle-brands", 
            params: { vehicle_brand_ids: [999999] }.to_json,
            headers: headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Error updating vehicle brands')
      end
    end

    context 'when user is not a garage admin' do
      let!(:car_owner) { FactoryBot.create(:car_owner) }
      let(:car_owner_token) { create_access_token_for(car_owner) }
      let(:car_owner_headers) do
        {
          "Authorization" => "Bearer #{car_owner_token.token}",
          "ACCEPT" => "application/json"
        }
      end

      it 'returns forbidden status', aggregate_failures: true do
        put "/api/v1/garage-vehicle-brands", 
            params: { vehicle_brand_ids: [vehicle_brand1.id] }.to_json,
            headers: car_owner_headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Access denied.')
      end
    end

    context 'when garage admin has no service center' do
      let!(:garage_admin_without_center) { FactoryBot.create(:garage_admin) }
      let(:no_center_token) { create_access_token_for(garage_admin_without_center) }
      let(:no_center_headers) do
        {
          "Authorization" => "Bearer #{no_center_token.token}",
          "ACCEPT" => "application/json"
        }
      end

      it 'returns not found status', aggregate_failures: true do
        put "/api/v1/garage-vehicle-brands", 
            params: { vehicle_brand_ids: [vehicle_brand1.id] }.to_json,
            headers: no_center_headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Service center not found.')
      end
    end
  end
end