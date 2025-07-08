class CenterMatchingService
  def self.find_nearest_available_for(booking)
    car_brand_id = booking.car.vehicle_brand_id
    service_date = booking.service_date
    user_pincode = booking.pincode.to_i

    centers = ServiceCenter
                .joins(:vehicle_brands)
                .includes(:bookings)
                .where(vehicle_brands: { id: car_brand_id })
                .where.not(pincode: nil)
    Rails.logger.info "Found #{centers} service centers for brand ID #{car_brand_id}" 

    available_centers = centers.select do |center|
      center.bookings.select { |b| b.service_date == service_date }.size < center.max_capacity_per_day
    end

    Rails.logger.info "Available centers for brand ID #{car_brand_id} on #{service_date}: #{available_centers.inspect}"

    available_centers.min_by do |center|
      (center.pincode.to_i - user_pincode).abs
      Rails.logger.info "Calculating distance for center #{center.garage_name} with pincode #{center.pincode}"
    end
  end
end
