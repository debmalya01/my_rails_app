module Api
  module V1
    class GaragesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def index
        @garages = [current_user.service_center]
        render json: @garages, status: :ok
      end

      def show
        @garage = current_user.service_center
        @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
        render json: { garage: @garage, bookings:@bookings }, status: :ok
      end
    end
  end
end  
      