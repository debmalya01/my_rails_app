class Api::V1::GarageVehicleBrandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_or_doorkeeper!
  before_action :ensure_garage_admin
  before_action :set_service_center

  def show
    vehicle_brands = VehicleBrand.all.order(:name)
    selected_brand_ids = @service_center.vehicle_brand_ids

    render json: {
      vehicle_brands: vehicle_brands.map { |brand| { id: brand.id, name: brand.name } },
      selected_brand_ids: selected_brand_ids,
      service_center: {
        id: @service_center.id,
        garage_name: @service_center.garage_name
      }
    }
  end

  def update
    selected_brand_ids = params[:vehicle_brand_ids] || []
    
    # Remove existing associations
    @service_center.service_center_brands.destroy_all
    
    # Create new associations
    selected_brand_ids.each do |brand_id|
      @service_center.service_center_brands.create!(vehicle_brand_id: brand_id)
    end
    
    render json: {
      message: 'Vehicle brands updated successfully!',
      selected_brand_ids: @service_center.reload.vehicle_brand_ids
    }
  rescue => e
    render json: { error: "Error updating vehicle brands: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def authenticate_user_or_doorkeeper!
    if doorkeeper_token
      doorkeeper_authorize!
    else
      authenticate_user!
    end
  end

  def current_resource_owner
    if doorkeeper_token
      User.find(doorkeeper_token.resource_owner_id)
    else
      current_user
    end
  end

  def ensure_garage_admin
    unless current_resource_owner.garage_admin?
      render json: { error: 'Access denied.' }, status: :forbidden
    end
  end

  def set_service_center
    @service_center = current_resource_owner.service_center
    unless @service_center
      render json: { error: 'Service center not found.' }, status: :not_found
    end
  end
end