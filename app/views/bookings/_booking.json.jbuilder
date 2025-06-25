json.extract! booking, :id, :car_id, :service_date, :notes, :created_at, :updated_at
json.url booking_url(booking, format: :json)
