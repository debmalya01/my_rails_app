class GarageBookingsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_garage
  before_action :set_booking, only: [:edit, :update]

  def index
    @bookings = @garage.bookings.includes(:car).order(service_date: :asc)
  end

  def edit
  end

  def update
    if @booking.update(booking_params)
      redirect_to garage_bookings_path(@garage), notice: "Booking status updated successfully."
    else
      flash.now[:alert] = "Failed to update booking status. Please try again."
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_garage
    @garage = ServiceCenter.find(params[:garage_id])
  end

  def set_booking
    @booking = @garage.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:status)
  end
end
