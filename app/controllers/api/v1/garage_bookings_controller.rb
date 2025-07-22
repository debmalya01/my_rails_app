module Api
  module V1
    class GarageBookingsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_garage
      before_action :set_booking, only: [:edit, :update]
      before_action :doorkeeper_authorize!

      def index
        q = @garage.bookings.ransack(params[:q])
        # Only allow filtering by status (and other safe fields if needed)
        if params[:q]
          params[:q].slice!(:status_eq)
        end
        bookings = q.result.page(params[:page]).per(params[:per_page] || 5)
        render json: { 
          garage: @garage, 
          bookings: bookings.as_json(
            include: {
              car: { only: [:id, :make, :model, :year] }
            }
          ),
          meta: {
            current_page: bookings.current_page,
            total_pages: bookings.total_pages,
            total_count: bookings.total_count
          }
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
        if params[:garage_id].to_s != @garage.id.to_s
          render json: { error: 'You are not authorized to access this garage.' }, status: :forbidden
        end
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