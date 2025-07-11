module Api 
  module V1 
    class CarsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_car, only: [:show, :update, :destroy]

      # GET /cars or /cars.json
      def index
        cars = current_user.cars
        render json: cars, status: :ok
      end

      def show
      end

      def new
        @car = Car.new
        render json: @car, status: :ok
      end

      def create
        @car = current_user.cars.build(car_params)
        @car.make = @car.vehicle_brand.name if @car.vehicle_brand
        
        begin
          @car.save!
          render json:@car, status: :created
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Car creation failed: #{e.message}"
          render json: { error: 'Car could not be created.'}, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        begin
          @car.update!(car_params)
          render json: @car, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Car update failed: #{e.message}"
          render json: { error: 'Car could not be updated.' }, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          @car.destroy!
          render json: { message: 'Car was successfully destroyed.'} , status: :see_other
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.logger.error "Car deletion failed: #{e.message}"
          render json: { error: 'Car could not be deleted.' }, status: :unprocessable_entity
        end
      end

      private
      def set_car
        begin
          @car = current_user.cars.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Car not found' }, status: :not_found
        end
      end

      def car_params
        params.require(:car).permit(
          :model, :year, :registration_number, :vehicle_brand_id
        )
      end
    end
  end
end    
