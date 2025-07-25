module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_application

    def connect
      token = request.params[:access_token]
      app = Doorkeeper::AccessToken.by_token(token)&.application
      reject_unauthorized_connection unless app
      self.current_application = app
    end
  end
end
