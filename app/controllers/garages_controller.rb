class GaragesController < ApplicationController
  before_action :authenticate_user!
  def index
    @garages = [current_user.service_center]
  end

  def show
    @garage = current_user.service_center
    @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
  end
end
