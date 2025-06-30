class BookingsController < ApplicationController
  before_action :set_booking, only: %i[ show edit update destroy ]

  # GET /bookings or /bookings.json
  def index
    @bookings = Booking.all
  end

  # GET /bookings/1 or /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @car = Car.find(params[:car_id])
    @booking = @car.bookings.build
  end


  # GET /bookings/1/edit
  def edit
  end

  def assign_nearest_center(booking)
    user_pincode = booking.pincode.to_i

    centers = ServiceCenter.where.not(pincode: nil)

    nearest_center = centers.min_by do |center|
      (center.pincode.to_i - user_pincode).abs
    end

    max_threshold = 20

    if nearest_center && (nearest_center.pincode.to_i - user_pincode).abs <= max_threshold
      booking.service_center = nearest_center
      return true
    else
      return false
    end
  end

  # POST /bookings or /bookings.json
  def create
    @car = Car.find(params[:car_id])
    @booking = @car.bookings.build(booking_params.except(:car_id))

    if assign_nearest_center(@booking)
      @booking.save
      redirect_to @booking, notice: "Booking was successfully updated and assigned."
    else
      flash.now[:alert] = "No nearby service center found for the new pincode."
      render :edit, status: :unprocessable_entity
    end
    render :edit, status: :unprocessable_entity
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    @booking.assign_attributes(booking_params)
    if assign_nearest_center(@booking)
      respond_to do |format|
        if @booking.update(booking_params)
          format.html { redirect_to @booking, notice: "Booking was successfully updated." }
          format.json { render :show, status: :ok, location: @booking }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        end
      end
    else
      flash.now[:alert] = "No nearby service center found in your area"
      render :show
    end
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    car_id = @booking.car_id
    @booking.destroy!

    respond_to do |format|
      format.html { redirect_to car_path(car_id), status: :see_other, notice: "Booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:service_date, :notes, :pincode, service_type_ids: [])
    end
end
