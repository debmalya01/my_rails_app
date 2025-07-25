module Api 
  module V1 
    class BookingsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :doorkeeper_authorize!
      before_action :set_booking, only: [:show, :edit, :update, :destroy]

      def index
        @bookings = Booking.all
        LogBroadcaster.log("Fetched #{@bookings.size} bookings for user #{current_resource_owner.id}", level: :info)
        render json: @bookings.as_json(
          include: {
            car: { only: [:id, :make, :model, :year] },
            service_center: { only: [:id, :garage_name, :phone] },
            # service_types: { only: [:id, :name, :base_price] },
            # invoice: { only: [:id, :amount, :status, :issued_at] }
          }
        ), status: :ok
      end

      def show
        if @booking
          LogBroadcaster.log("Showing booking details for booking ID #{@booking.id}", level: :info)
          render json: @booking.as_json(
            include: {
              car: { only: [:id, :make, :model, :year] },
              service_center: { only: [:id, :garage_name, :phone] },
              service_types: { only: [:id, :name, :base_price] },
              invoice: { only: [:id, :amount, :status, :issued_at] }
            }
          ), status: :ok
        end
      end

      def new
        @car = Car.find(params[:car_id])
        @booking = @car.bookings.build
        LogBroadcaster.log("Creating a new booking for car ID #{@car.id}", level: :info)
        render json: @booking, status: :ok
      end
      
      def edit
        LogBroadcaster.log("Editing booking ID #{@booking.id}", level: :info)
        render json: @booking.as_json(
          include: {
            car: { only: [:id, :make, :model, :year] },
            service_types: { only: [:id, :name, :base_price] }
          }
        ), status: :ok
      end

      def assign_nearest_center(booking)
        nearest_center = CenterMatchingService.find_nearest_available_for(booking)
        Rails.logger.info "Nearest Center: #{nearest_center.inspect}"
        if nearest_center
          booking.update(service_center: nearest_center)
          return true
        else
          return false
        end
      end

      def create
        @car = current_resource_owner.cars.find(params[:car_id])
        @booking = @car.bookings.build(booking_params)
        @booking.user = current_resource_owner

        Rails.logger.info "Booking Params: #{booking_params.inspect}"
        Rails.logger.info "Booking Service Date: #{@booking.service_date.inspect}"

        begin
          assign_nearest_center(@booking)
          Rails.logger.info "Assigned nearest service center: #{@booking.service_center.inspect}"
          begin
            @booking.save!
            Rails.logger.info "Booking saved successfully with ID: #{@booking.id}"
            LogBroadcaster.log("Booking created successfully with ID #{@booking.id}", level: :info)
            render json: @booking, status: :created
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Booking creation failed: #{e.message}"
            LogBroadcaster.log("Booking creation failed: #{e.message}", level: :error)
            render json: { error: 'Booking could not be created.' }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.warn "No compatible service center found for booking: #{e.message}"
          LogBroadcaster.log("No compatible service center found for booking: #{e.message}", level: :warn)
          render json: { error: 'No nearby compatible service center found for the selected brand and location.' }, status: :unprocessable_entity
        end
      end
        
      def update
        @booking.assign_attributes(booking_params)
        if assign_nearest_center(@booking)
          begin
            @booking.update(booking_params)
            Rails.logger.info "Booking updated successfully"
            LogBroadcaster.log("Booking updated successfully with ID #{@booking.id}", level: :info)
            render json: @booking, status: :ok
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Booking update failed: #{e.message}"
            LogBroadcaster.log("Booking update failed: #{e.message}", level: :error)
            render json: { error: 'Booking could not be updated.' }, status: :unprocessable
          end
        else
          Rails.logger.warn "No compatible service center found for booking update"
          render json: { error: 'No nearby compatible service center found for the selected brand and location.' }, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          @booking.destroy!
          Rails.logger.info "Booking destroyed successfully"
          LogBroadcaster.log("Booking deleted successfully with ID #{@booking.id}", level: :info)
          head :no_content
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.logger.error "Booking deletion failed: #{e.message}"
          LogBroadcaster.log("Booking deletion failed: #{e.message}", level: :error)
          render json: { error: 'Booking could not be deleted.' }, status: :unprocessable_entity
        end
      end


      private
      def set_booking
        @booking = current_resource_owner.bookings.find(params[:id])

        return render json: { error: 'Booking not found' }, status: :not_found if @booking.nil?
        return render json: { error: 'You are not authorized to access this booking.'}, status: :forbidden if @booking.user_id != current_resource_owner.id
      end

      def booking_params
        params.require(:booking).permit(:service_date, :notes, :pincode, :status, service_type_ids: [])
      end

      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
