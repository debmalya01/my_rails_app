module Api
    module V1
      class ServiceTypesController < ApplicationController
        skip_before_action :verify_authenticity_token
  
        def index
          @service_types = ServiceType.all
          render json: @service_types, status: :ok
        end
      end
    end
end