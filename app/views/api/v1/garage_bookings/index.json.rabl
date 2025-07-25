object false

node(:garage) do
  {
    id: @garage.id,
    garage_name: @garage.garage_name,
    phone: @garage.phone,
    pincode: @garage.pincode,
    max_capacity_per_day: @garage.max_capacity_per_day,
    user_id: @garage.user_id,
    license_number: @garage.license_number,
  }
end

node(:bookings) do
  @bookings.map do |booking|
    {
      id: booking.id,
      car_id: booking.car_id,
      service_date: booking.service_date,
      notes: booking.notes,
      service_center_id: booking.service_center_id,
      status: booking.status,
      pincode: booking.pincode,
      created_at: booking.created_at,
      updated_at: booking.updated_at,
      user_id: booking.user_id,
      car: {
        id: booking.car.id,
        make: booking.car.make,
        model: booking.car.model,
        year: booking.car.year
      }
    }
  end
end

node(:meta) do
  {
    current_page: @bookings.current_page,
    total_pages: @bookings.total_pages,
    total_count: @bookings.total_count
  }
end
      
