module Api 
  module V1 
    class BookingsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_booking, only: [:show, :edit, :update, :destroy]

      def index
        @bookings = Booking.all
        render json: @bookings.as_json(
          include: {
            car: { only: [:id, :make, :model, :year] },
            service_center: { only: [:id, :garage_name, :phone] },
            service_types: { only: [:id, :name, :base_price] },
            invoice: { only: [:id, :amount, :status, :issued_at] }
          }
        ), status: :ok
      end

      def show
        if @booking
          render json: @booking.as_json(
            include: {
              car: { only: [:id, :make, :model, :year] },
              service_center: { only: [:id, :garage_name, :phone] },
              service_types: { only: [:id, :name, :base_price] },
              invoice: { only: [:id, :amount, :status, :issued_at] }
            }
          ), status: :ok
        else
          render json: { error: 'Booking not found' }, status: :not_found
        end
      end

      def new
        @car = Car.find(params[:car_id])
        @booking = @car.bookings.build
        render json: @booking, status: :ok
      end
      
      def edit
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
        @car = current_user.cars.find(params[:car_id])
        @booking = @car.bookings.build(booking_params)
        @booking.user = current_user

        Rails.logger.info "Booking Params: #{booking_params.inspect}"
        Rails.logger.info "Booking Service Date: #{@booking.service_date.inspect}"

        begin
          assign_nearest_center(@booking)
          Rails.logger.info "Assigned nearest service center: #{@booking.service_center.inspect}"
          begin
            @booking.save!
            Rails.logger.info "Booking saved successfully with ID: #{@booking.id}"
            render json: @booking, status: :created
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Booking creation failed: #{e.message}"
            render json: { error: 'Booking could not be created.' }, status: :unprocessable
          end
        rescue StandardError => e
          Rails.logger.warn "No compatible service center found for booking: #{e.message}"
          render json: { error: 'No nearby compatible service center found for the selected brand and location.' }, status: :unprocessable_entity
        end
      end
        
      def update
        @booking.assign_attributes(booking_params)
        if assign_nearest_center(@booking)
          begin
            @booking.update(booking_params)
            Rails.logger.info "Booking updated successfully" 
            render json: @booking, status: :ok
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Booking update failed: #{e.message}"
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
          render json: { message: 'Booking was successfully destroyed.' }, status: :see_other
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.logger.error "Booking deletion failed: #{e.message}"
          render json: { error: 'Booking could not be deleted.' }, status: :unprocessable_entity
        end
      end


      private
      def set_booking
        @booking = current_user.bookings.find(params[:id])
      end

      def booking_params
        params.require(:booking).permit(:service_date, :notes, :pincode, :status, service_type_ids: [])
      end
    end
  end
end
