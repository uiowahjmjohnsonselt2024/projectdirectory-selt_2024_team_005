module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "WebSocket connected: #{current_user}"
    end

    private

    def find_verified_user
      # Extract session data from cookie encryption
      verified_user = User.find_by(username: env["rack.session"][:username])
      verified_user || reject_unauthorized_connection
    end
  end
end
