object @car => nil  # removes "car" root

attributes :id, :make, :model, :year, :registration_number,
           :created_at, :updated_at, :vehicle_brand_id, :user_id

child :bookings, object_root: false do
  attributes :id, :service_date, :notes, :status

  child :service_center, object_root: false do
    attributes :garage_name
  end
end
