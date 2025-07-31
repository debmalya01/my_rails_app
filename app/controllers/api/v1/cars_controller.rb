module Api 
  module V1 
    class CarsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :doorkeeper_authorize!
      before_action :ensure_car_owner
      before_action :set_car, only: [:show, :edit, :update, :destroy]

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from ActiveRecord::RecordNotDestroyed, with: :record_not_destroyed

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
        
        @car.save!
        LogBroadcaster.log("Car created successfully with ID #{@car.id}", level: :info)
        render json: @car, status: :created
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
        
        @car.update!(car_params)
        LogBroadcaster.log("Car updated successfully with ID #{@car.id}", level: :info)
        render json: @car, status: :ok
      end

      def destroy
        LogBroadcaster.log("Attempting to delete car ID #{@car.id}", level: :info)
        
        @car.destroy!
        LogBroadcaster.log("Car deleted successfully with ID #{@car.id}", level: :info)
        render json: { message: 'Car was successfully destroyed.' }, status: :ok
      end

      private
      
      def ensure_car_owner
        unless current_resource_owner&.car_owner?
          LogBroadcaster.log("Access denied: User #{current_resource_owner&.id || 'unknown'} (#{current_resource_owner&.type || 'unknown type'}) attempted to access cars endpoint", level: :warn)
          render json: { 
            error: 'Access denied. Only car owners can manage cars.',
            user_type: current_resource_owner&.type,
            required_type: 'CarOwner'
          }, status: :forbidden
          return false
        end
      end

      def set_car
        @car = Car.find_by(id: params[:id])
        
        if @car.nil?
          LogBroadcaster.log("Car not found: ID #{params[:id]} for user #{current_resource_owner.id}", level: :warn)
          render json: { 
            error: 'Car not found',
            car_id: params[:id]
          }, status: :not_found
          return
        end
        
        if @car.user_id != current_resource_owner.id
          LogBroadcaster.log("Access denied: User #{current_resource_owner.id} attempted to access car #{@car.id} owned by user #{@car.user_id}", level: :warn)
          render json: { 
            error: 'You are not authorized to access this car.',
            car_id: params[:id]
          }, status: :forbidden
          return
        end
      end

      def car_params
        params.require(:car).permit(
          :model, :year, :registration_number, :vehicle_brand_id
        )
      end

      def current_resource_owner
        @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      # Error handling methods
      def record_not_found(exception)
        LogBroadcaster.log("Record not found: #{exception.message}", level: :error)
        render json: { 
          error: 'Resource not found',
          details: exception.message
        }, status: :not_found
      end

      def record_invalid(exception)
        LogBroadcaster.log("Validation failed: #{exception.message}", level: :error)
        render json: { 
          error: 'Validation failed',
          details: exception.record.errors.full_messages,
          invalid_attributes: exception.record.errors.attribute_names
        }, status: :unprocessable_entity
      end

      def record_not_destroyed(exception)
        LogBroadcaster.log("Deletion failed: #{exception.message}", level: :error)
        render json: { 
          error: 'Resource could not be deleted',
          details: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end    
