# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource(type: params[:type])

    if resource.is_a?(GarageAdmin)
      resource.build_service_center
    end

    respond_with resource
  end


  # POST /resource
  # def create
  #   super do |resource|
  #     if resource.is_a?(GarageAdmin) && resource.persisted?
  #       ServiceCenter.create!(
  #         user: resource,
  #         garage_name: params[:user][:garage_name],
  #         license_number: params[:user][:license_number],
  #         max_capacity_per_day: params[:user][:max_capacity_per_day].to_i,
  #         phone: params[:user][:phone],
  #         pincode: params[:user][:pincode]
  #       )
  #     end
  #   end
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :type, :name, :email, :password, :password_confirmation,
      service_center_attributes: [:garage_name, :license_number, :pincode, :phone, :max_capacity_per_day]
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if resource.garage_admin?
      garages_path
    else
      super(resource)
    end
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
