class GaragesController < ApplicationController
  def index
    @garages = ServiceCenter.all.order(:name)
  end

  def show
    @garage = ServiceCenter.find(params[:id])
    @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
  end
end
