garage_admin = GarageAdmin.create!(
  name: 'Test Garage Admin',
  email: 'test@garage.com',
  password: 'password123'
)

service_center = ServiceCenter.create!(
  user: garage_admin,
  garage_name: 'Test Garage',
  phone: '1234567890',
  pincode: '123456',
  license_number: 'LIC123',
  max_capacity_per_day: 10
)

puts 'Created test garage admin and service center'
puts "Garage Admin ID: #{garage_admin.id}"
puts "Service Center ID: #{service_center.id}"
puts "Vehicle Brands count: #{VehicleBrand.count}"