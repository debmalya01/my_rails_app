module Api
  module V1
    class GaragesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :doorkeeper_authorize!

      def index
        @garages = [current_resource_owner.service_center]
        LogBroadcaster.log("Fetched #{@garages.first.inspect} garage for user #{current_resource_owner.id}", level: :info)
        render json: @garages.as_json(
          methods: [:bookings_count]
        ), status: :ok
      end

      def show
        @garage = current_resource_owner.service_center

        @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
        LogBroadcaster.log("Showing garage details for garage ID #{@garage.id} with #{@bookings.size} bookings", level: :info)
        render json: { 
          garage: @garage, 
          bookings: @bookings.as_json(
            include: {
              car: { 
                only: [:id, :make, :model, :year],
                include: {
                  vehicle_brand: { only: [:id, :name] }
                }
              }
            }
          )
        }, status: :ok
      end

      private
      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end  
      