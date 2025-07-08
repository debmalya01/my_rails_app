# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).


# require 'json'

# file_path = Rails.root.join('db', 'seeds', 'car-list.json')
# brands = JSON.parse(File.read(file_path))

# brands.each do |entry|
#   VehicleBrand.find_or_create_by!(name: entry["brand"])
# end

# puts "Seeded #{VehicleBrand.count} vehicle brands."

# User.create!(name: "Glenn Bracewell", email: "glenn@example.com")
# User.create!(name: "John Doe", email: "doe@example.com")
# puts "Seeded #{User.count} users."

# ServiceCenter.create!([
#   { name: "Elite Motors", location: "Downtown", phone: "9876543210", pincode: 700041, max_capacity_per_day: 5 },
#   { name: "QuickFix Garage", location: "Airport Road", phone: "9123456780", pincode: 700037, max_capacity_per_day: 3 }
# ])
# puts "Seeded #{ServiceCenter.count} service centers."

    # ServiceType.create!([
    #   { name: "Interim Car Service", base_price: 3000 },
    #   { name: "Full Car Service", base_price: 4800 },
    #   { name: "Major Service", base_price: 6200 },
    #   { name: "Oil Change", base_price: 1500 },
    #   { name: "Oil Filter Replacement", base_price: 700 },
    #   { name: "Air Filter Replacement", base_price: 600 },
    #   { name: "Cabin Filter Replacement", base_price: 650 },
    #   { name: "Brake Service", base_price: 2200 },
    #   { name: "Brake Examination", base_price: 800 },
    #   { name: "Brake Fluid Exchange", base_price: 1100 },
    #   { name: "Battery Testing", base_price: 500 },
    #   { name: "Battery Replacement", base_price: 4000 },
    #   { name: "Spark Plugs Replacement", base_price: 1000 },
    #   { name: "Rotate Tires", base_price: 800 },
    #   { name: "Wheel Alignment", base_price: 1200 },
    #   { name: "Tires Replacement", base_price: 4500 },
    #   { name: "Check Coolant Hoses", base_price: 500 },
    #   { name: "Check Coolant Levels", base_price: 450 },
    #   { name: "Check Steering and Suspension", base_price: 900 },
    #   { name: "Suspension Inspection", base_price: 1100 },
    #   { name: "Engine Inspection", base_price: 1300 },
    #   { name: "General Inspection", base_price: 1000 }
    # ])
    # puts "Seeded #{ServiceType.count} service types"

# ServiceCenter.all.each do |center|
#   # Assign 4 hardcoded brand IDs (1 to 4) to each center
#   [1, 2, 3, 4].each do |brand|
#     ServiceCenterBrand.find_or_create_by!(
#       service_center_id: center.id,
#       vehicle_brand_id: brand
#     )
#   end
# end

# puts "Seeded ServiceCenterBrand mappings for each service center."


# [1,2].each do |center|
  # [1,2,3,4].each do |brand|
  #   ServiceCenterBrand.find_or_create_by!(
  #     service_center_id:center,
  #     vehicle_brand_id:brand
  #   )
  # end
# end

# puts "ServiceCenterBrand mappings: #{ServiceCenterBrand.count} created."



AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?