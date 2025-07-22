require 'rails_helper'

RSpec.describe Api::V1::GarageVehicleBrandsController, type: :controller do
  let(:garage_admin) { create(:garage_admin) }
  let(:car_owner) { create(:car_owner) }
  let(:service_center) { create(:service_center, user: garage_admin) }
  let(:vehicle_brand1) { create(:vehicle_brand, name: 'Toyota') }
  let(:vehicle_brand2) { create(:vehicle_brand, name: 'Honda') }
  let(:token) { double acceptable?: true, resource_owner_id: garage_admin.id }

  before do
    vehicle_brand1
    vehicle_brand2
    allow(controller).to receive(:doorkeeper_token) { token }
    allow(controller).to receive(:current_resource_owner) { garage_admin }
  end

  describe 'GET #show' do
    context 'when user is garage admin' do
      before { service_center }

      it 'returns success response with vehicle brands data' do
        get :show
        expect(response).to be_successful
        
        json_response = JSON.parse(response.body)
        expect(json_response['vehicle_brands']).to be_present
        expect(json_response['selected_brand_ids']).to eq([])
        expect(json_response['service_center']['garage_name']).to eq(service_center.garage_name)
      end

      it 'includes all vehicle brands' do
        get :show
        json_response = JSON.parse(response.body)
        brand_names = json_response['vehicle_brands'].map { |b| b['name'] }
        expect(brand_names).to include('Toyota', 'Honda')
      end
    end

    context 'when user is car owner' do
      let(:car_owner_token) { double acceptable?: true, resource_owner_id: car_owner.id }
      
      before do
        allow(controller).to receive(:doorkeeper_token) { car_owner_token }
        allow(controller).to receive(:current_resource_owner) { car_owner }
      end

      it 'returns forbidden status' do
        get :show
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Access denied.')
      end
    end
  end

  describe 'PATCH #update' do
    context 'when user is garage admin' do
      before { service_center }

      it 'updates vehicle brands successfully' do
        patch :update, params: { vehicle_brand_ids: [vehicle_brand1.id, vehicle_brand2.id] }
        
        expect(response).to be_successful
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Vehicle brands updated successfully!')
        expect(service_center.reload.vehicle_brands).to include(vehicle_brand1, vehicle_brand2)
      end

      it 'removes existing associations and creates new ones' do
        # Create initial association
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand1)
        
        # Update with different brands
        patch :update, params: { vehicle_brand_ids: [vehicle_brand2.id] }
        
        expect(service_center.reload.vehicle_brands).to eq([vehicle_brand2])
        expect(service_center.vehicle_brands).not_to include(vehicle_brand1)
      end

      it 'handles empty selection' do
        service_center.service_center_brands.create!(vehicle_brand: vehicle_brand1)
        
        patch :update, params: { vehicle_brand_ids: [] }
        
        expect(service_center.reload.vehicle_brands).to be_empty
      end

      it 'returns error on failure' do
        allow_any_instance_of(ServiceCenter).to receive(:service_center_brands).and_raise(StandardError.new('Database error'))
        
        patch :update, params: { vehicle_brand_ids: [vehicle_brand1.id] }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('Database error')
      end
    end

    context 'when user is car owner' do
      let(:car_owner_token) { double acceptable?: true, resource_owner_id: car_owner.id }
      
      before do
        allow(controller).to receive(:doorkeeper_token) { car_owner_token }
        allow(controller).to receive(:current_resource_owner) { car_owner }
      end

      it 'returns forbidden status' do
        patch :update, params: { vehicle_brand_ids: [vehicle_brand1.id] }
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Access denied.')
      end
    end
  end
end