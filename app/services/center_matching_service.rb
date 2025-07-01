class CenterMatchingService
    def self.find_nearest_available_for(booking)
        car_brand_id = booking.car.vehicle_brand_id
        service_date = booking.service_date
        user_pincode = booking.pincode.to_i

        ServiceCenter.joins(:vehicle_brands)
            .where(vehicle_brands: { id: car_brand_id})
            .where.not(pincode: nil)
            .select do |center|
                center.max_capacity_per_day > center.bookings.where(service_date: service_date).count
            end
            .min_by { |center| (center.pincode.to_i - user_pincode).abs} 
    end
end