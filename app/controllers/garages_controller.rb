class GaragesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @garages = ServiceCenter.all.order(:garage_name)
  end

  def show
    @garage = ServiceCenter.find(params[:id])
    @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
  end
end
