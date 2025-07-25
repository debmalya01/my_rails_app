object false

node(:cars) do
  @cars.map do |car|
    {
      id: car.id,
      model: car.model,
      year: car.year,
      registration_number: car.registration_number,
      vehicle_brand: {
        id: car.vehicle_brand&.id,
        name: car.vehicle_brand&.name
      }
    }
  end
end

node(:meta) do
  {
    current_page: @cars.current_page,
    total_pages: @cars.total_pages,
    total_count: @cars.total_count
  }
end
