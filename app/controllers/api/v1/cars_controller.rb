module Api 
  module V1 
    class CarsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :doorkeeper_authorize!
      before_action :set_car, only: [:show, :update, :destroy]

      # GET /cars or /cars.json
      def index
        q = current_resource_owner.cars.ransack(params[:q])
        @cars = q.result.page(params[:page]).per(params[:per_page] || 5)
        LogBroadcaster.log("Fetched #{@cars.size} cars for user #{current_resource_owner.id} - page #{@cars.current_page}", level: :info)
        # render json: {
        #   cars: cars.as_json(
        #     include: {
        #       vehicle_brand: { only: [:id, :name] }
        #     }
        #   ),
        #   meta: {
        #     current_page: cars.current_page,
        #     total_pages: cars.total_pages,
        #     total_count: cars.total_count
        #   }
        # }, status: :ok

        render 'api/v1/cars/index', formats: [:json], status: :ok
      end

      def show
        LogBroadcaster.log("Showing car details for car ID #{@car.id}", level: :info)
        # render json: @car.as_json(
        #   include: {
        #     bookings: {
        #       only: [:id, :service_date, :notes, :status],
        #       include: {
        #         service_center: { only: [:garage_name] }
        #       }
        #     }
        #   }
        # ), status: :ok
        render 'api/v1/cars/show', formats: [:json], status: :ok
      end

      def new
        LogBroadcaster.log("Creating a new car for user #{current_resource_owner.id}", level: :info)
        @car = Car.new
        render json: {
          car: @car,
          current_user: { id: current_resource_owner.id, name: current_resource_owner.name }
        }, status: :ok
      end

      def create
        @car = current_resource_owner.cars.build(car_params)
        @car.make = @car.vehicle_brand.name if @car.vehicle_brand
        LogBroadcaster.log("Attempting to create a new car for user #{current_resource_owner.id}", level: :info)
        begin
          @car.save!
          LogBroadcaster.log("Car created successfully with ID #{@car.id}", level: :info)
          render json:@car, status: :created
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Car creation failed: #{e.message}"
          LogBroadcaster.log("Car creation failed: #{e.message}", level: :error)
          render json: { error: 'Car could not be created.'}, status: :unprocessable_entity
        end
      end

      def edit
        LogBroadcaster.log("Editing car details for car ID #{@car.id}", level: :info)
        render json: @car.as_json(
          include: {
            vehicle_brand: { only: [:id, :name] }
          }
        ), status: :ok
      end

      def update
        LogBroadcaster.log("Attempting to update car details for car ID #{@car.id}", level: :info)
        begin
          @car.update!(car_params)
          LogBroadcaster.log("Car updated successfully with ID #{@car.id}", level: :info)
          render json: @car, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Car update failed: #{e.message}"
          LogBroadcaster.log("Car update failed: #{e.message}", level: :error)
          render json: { error: 'Car could not be updated.' }, status: :unprocessable_entity
        end
      end

      def destroy
        LogBroadcaster.log("Attempting to delete car ID #{@car.id}", level: :info)
        begin
          @car.destroy!
          LogBroadcaster.log("Car deleted successfully with ID #{@car.id}", level: :info)
          render json: { message: 'Car was successfully destroyed.'} , status: :see_other
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.logger.error "Car deletion failed: #{e.message}"
          LogBroadcaster.log("Car deletion failed: #{e.message}", level: :error)
          render json: { error: 'Car could not be deleted.' }, status: :unprocessable_entity
        end
      end

      private
      def set_car
        @car = Car.find_by(id: params[:id])

        return render json: { error: 'Car not found' }, status: :not_found if @car.nil?
        return render json: { error: 'You are not authorized to access this car.' }, status: :forbidden if @car.user_id != current_resource_owner.id
      end

      def car_params
        params.require(:car).permit(
          :model, :year, :registration_number, :vehicle_brand_id
        )
      end

      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end    
