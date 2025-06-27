# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


ServiceCenter.create!([
  { name: "Elite Motors", location: "Downtown", phone: "9876543210" },
  { name: "QuickFix Garage", location: "Airport Road", phone: "9123456780" }
])

ServiceType.create!([
  { name: "Interim Car Service", base_price: 3000 },
  { name: "Full Car Service", base_price: 4800 },
  { name: "Major Service", base_price: 6200 },
  { name: "Oil Change", base_price: 1500 },
  { name: "Oil Filter Replacement", base_price: 700 },
  { name: "Air Filter Replacement", base_price: 600 },
  { name: "Cabin Filter Replacement", base_price: 650 },
  { name: "Brake Service", base_price: 2200 },
  { name: "Brake Examination", base_price: 800 },
  { name: "Brake Fluid Exchange", base_price: 1100 },
  { name: "Battery Testing", base_price: 500 },
  { name: "Battery Replacement", base_price: 4000 },
  { name: "Spark Plugs Replacement", base_price: 1000 },
  { name: "Rotate Tires", base_price: 800 },
  { name: "Wheel Alignment", base_price: 1200 },
  { name: "Tires Replacement", base_price: 4500 },
  { name: "Check Coolant Hoses", base_price: 500 },
  { name: "Check Coolant Levels", base_price: 450 },
  { name: "Check Steering and Suspension", base_price: 900 },
  { name: "Suspension Inspection", base_price: 1100 },
  { name: "Engine Inspection", base_price: 1300 },
  { name: "General Inspection", base_price: 1000 }
])
