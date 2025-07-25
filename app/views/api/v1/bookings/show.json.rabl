object @booking => nil  # removes "booking" root

attributes :id, :car_id, :service_date, :notes, :service_center_id,
           :status, :pincode, :created_at, :updated_at, :user_id

child :car do
  attributes :id, :make, :model, :year
end

child :service_center do
  attributes :id, :garage_name, :phone
end

child :service_types, object_root: false do
  attributes :id, :name, :base_price
end

child :invoice do
  attributes :id, :amount, :status, :issued_at
end
