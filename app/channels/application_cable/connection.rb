# Mostly from: https://rubytutorial.io/actioncable-devise-authentication/
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', "#{current_user.name} (#{current_user.id})" unless Rails.env.test?
    end

  protected
    def find_verified_user
      verified_user = User.find_by(id: cookies.signed['user.id'])
      begin
        expires_at = cookies.signed['user.expires_at']
        if verified_user && expires_at && expires_at > Time.now
          verified_user
        elsif request.params["internal"] == true && Rails.env.test?
          User.find(SYSTEM_ADMIN_ID)
        else
          reject_unauthorized_connection
        end
      rescue Exception => e
        reject_unauthorized_connection
      end
    end
  end
end
