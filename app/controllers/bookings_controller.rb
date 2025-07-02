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
    nearest_center = CenterMatchingService.find_nearest_available_for(booking)
    if nearest_center
      booking.service_center = nearest_center
      return true
    else
      return false
    end
  end  

  # POST /bookings or /bookings.json
  def create
    @car = Car.find(params[:car_id])
    @booking = @car.bookings.build(booking_params)

    Rails.logger.info "Booking Params: #{booking_params.inspect}"
    Rails.logger.info "Booking Service Date: #{@booking.service_date.inspect}"

    if assign_nearest_center(@booking)
      if @booking.save
        Rails.logger.info "Booking saved successfully with ID: #{@booking.id}"
        redirect_to @car, notice: "Booking was successfully created and assigned."
      else
        Rails.logger.error "Booking failed to save: #{@booking.errors.full_messages.inspect}"
        flash.now[:alert] = "Failed to save booking. Please check the details."
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.warn "No compatible service center found for booking"
      flash.now[:alert] = "No nearby compatible service center found for the selected brand and location."
      render :new, status: :unprocessable_entity
    end
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
      params.require(:booking).permit(:service_date, :notes, :pincode, :status, service_type_ids: [])
    end
end
