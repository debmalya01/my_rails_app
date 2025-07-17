module Api
  module V1
    class GarageBookingsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_garage
      before_action :set_booking, only: [:edit, :update]
      before_action :doorkeeper_authorize!

      def index
        @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
        render json: { 
          garage: @garage, 
          bookings: @bookings.as_json(
            include: {
              car: { only: [:id, :make, :model, :year] }
            }
          )
        }, status: :ok
      end

      def edit
        render json: @booking.as_json(
          include: {
            car: { only: [:id, :make, :model, :year] }
          }
        ), status: :ok
      end

      def update
        begin
          @booking.update!(booking_params)
          render json: @booking, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Booking update failed: #{e.message}"
          render json: { error: 'Booking status could not be updated.' }, status: :unprocessable_entity
        end
      end

      private
      def set_garage
        @garage = current_resource_owner.service_center
      end

      def set_booking
        @booking = @garage.bookings.find(params[:id])
      end

      def booking_params
        params.require(:booking).permit(:status)
      end

      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end