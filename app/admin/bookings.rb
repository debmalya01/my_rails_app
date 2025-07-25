ActiveAdmin.register Booking do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :car_id, :service_date, :notes, :service_center_id, :pincode, :status
  #
  # or
  #
  # permit_params do
  #   permitted = [:car_id, :service_date, :notes, :service_center_id, :pincode, :status]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  scope :all, default: true
  scope("Recent Bookings") { |bookings| bookings.where("created_at >= ?", 1.week.ago) }
  scope("Pending Bookings") { |bookings| bookings.where(status: "pending") }
  scope("In Service") { |bookings| bookings.where(status: "in_service") }
  scope("Waiting for pickup") { |bookings| bookings.where(status: "waiting_for_pickup") }
  scope("Cancelled") { |bookings| bookings.where(status: "cancelled") } 
  scope("Completed") { |bookings| bookings.where(status: "dropped_off") }
end
