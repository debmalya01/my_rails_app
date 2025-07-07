ActiveAdmin.register ServiceCenter do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :garage_name, :phone, :pincode, :max_capacity_per_day, :license_number
  #
  # or
  #
  # permit_params do
  #   permitted = [:garage_name, :phone, :pincode, :max_capacity_per_day, :user_id, :license_number]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  index do
    selectable_column
    id_column
    column :garage_name
    column :phone
    column :pincode
    column :max_capacity_per_day
    column :license_number
    actions
  end

  filter :garage_name
  filter :phone
  filter :pincode
  filter :max_capacity_per_day
  filter :license_number

  
  form do |f|
    f.inputs do
      f.input :garage_name
      f.input :phone
      f.input :max_capacity_per_day
    end
    actions
  end

  show do 
    attributes_table do
      row :id
      row :garage_name
      row :phone
      row :pincode
      row :max_capacity_per_day
      row :license_number
    end

    panel "Bookings" do
      table_for service_center.bookings do
        column :id
        column :service_date
        column :status
      end
    end
  end
end
