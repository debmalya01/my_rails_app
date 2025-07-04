class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :type, :garage_name, :license_number, :pincode, :phone, :max_capacity_per_day
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

end
