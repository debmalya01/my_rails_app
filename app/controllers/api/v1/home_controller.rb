module Api
  module V1
    class HomeController < ApplicationController
      def index
        render json: { ... }
      end

      def about
        render json: { ... }
      end
    end
  end
end
