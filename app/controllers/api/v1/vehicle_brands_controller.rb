module Api
  module V1
    class VehicleBrandsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        @vehicle_brands = VehicleBrand.all
        LogBroadcaster.log("Fetched #{@vehicle_brands.size} vehicle brands", level: :info)
        render json: @vehicle_brands, status: :ok
      end
    end
  end
end 