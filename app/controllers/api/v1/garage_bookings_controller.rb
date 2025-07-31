module Api
  module V1
    class GarageBookingsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_garage
      before_action :set_booking, only: [:edit, :update]
      before_action :doorkeeper_authorize!

      def index
        q = @garage.bookings.ransack(params[:q])
        # Only allow filtering by status
        if params[:q]
          params[:q].slice!(:status_eq)
        end
        @bookings = q.result.page(params[:page]).per(params[:per_page] || 5)
        LogBroadcaster.log("Fetched #{@bookings.size} bookings for garage ID #{@garage.id} - page #{@bookings.current_page}", level: :info)
        # render json: { 
        #   garage: @garage, 
        #   bookings: bookings.as_json(
        #     include: {
        #       car: { only: [:id, :make, :model, :year] }
        #     }
        #   ),
        #   meta: {
        #     current_page: bookings.current_page,
        #     total_pages: bookings.total_pages,
        #     total_count: bookings.total_count
        #   }
        # }, status: :ok
        render 'api/v1/garage_bookings/index', formats: [:json], status: :ok
      end

      def edit
        LogBroadcaster.log("Editing booking ID #{@booking.id} for garage ID #{@garage.id}", level: :info)
        render json: @booking.as_json(
          include: {
            car: { only: [:id, :make, :model, :year] }
          }
        ), status: :ok
      end

      def update
        begin
          @booking.update!(booking_params)
          LogBroadcaster.log("Booking ID #{@booking.id} updated successfully for garage ID #{@garage.id}", level: :info)
          render json: @booking, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Booking update failed: #{e.message}"
          LogBroadcaster.log("Booking update failed: #{e.message}", level: :error)
          render json: { error: 'Booking status could not be updated.' }, status: :unprocessable_entity
        end
      end

      private
      def set_garage
        @garage = current_resource_owner.service_center
        if params[:garage_id].to_s != @garage.id.to_s
          LogBroadcaster.log("Unauthorized access attempt to garage ID #{params[:garage_id]} by user #{current_resource_owner.id}", level: :warn)
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