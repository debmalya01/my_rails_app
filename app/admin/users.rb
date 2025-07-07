ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :email, :type # :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :type
    column "Cars Owned" do |user|
      if user.car_owner?
        user.cars_count
      else
        "N/A"
      end
    end
    actions
  end

    filter :name
    filter :email
    filter :type, as: :select, collection: -> { User.distinct.pluck(:type) }

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :type
      row :email
    end

    panel "Cars Owned" do
      table_for user.cars do
        column :id
        column :brand
        column :model
      end
    end
  end
end
