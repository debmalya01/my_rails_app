class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    User.second # TEMP: Replace with actual authentication later
  end
end
