ActiveAdmin.register Car do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :make, :model, :year, :registration_number, :vehicle_brand_id, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:make, :model, :year, :registration_number, :vehicle_brand_id, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :vehicle_brand
  filter :car_owner, as: :select, collection: -> { User.where(type: 'CarOwner').pluck(:name, :id) }
  filter :registration_number
  
  index do
    selectable_column
    id_column
    column :make
    column :model
    column :year
    column :registration_number
    column :car_owner
    actions
  end

  form do |f|
    f.inputs do
      f.input :make
      f.input :model
      f.input :year
      f.input :registration_number
      f.input :car_owner, as: :select, collection: User.where(type: 'CarOwner').pluck(:name, :id)
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :make
      row :model
      row :year
      row :registration_number
      row "Car Owner" do |car|
        car.car_owner.name if car.car_owner
      end
    end

    if car.bookings.any?

      panel "Bookings" do
        table_for car.bookings do
          column :id
          column "Service Date", :service_date
          column "Status", :status
          column "Service Center" do |booking|
            booking.service_center.name if booking.service_center
          end
          column "Pincode", :pincode
          column "Notes", :notes
        end if car.bookings.any?
      end
    end

  end           
end
