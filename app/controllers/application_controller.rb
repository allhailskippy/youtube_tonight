class ApplicationController < ActionController::Base
  # If we want to skip devise authentication on current controller/actions specifically, set them up here
  SKIP_DEVISE_AUTHENTICATION = [
    {:controller => :auth, :action => :facebook }
  ]

  # Declarative Authorization in Models
  before_filter :set_current_user

  # Userstamp Gem
  include Userstamp

  # Permissions
  filter_access_to :all

  # Rails
  protect_from_forgery

protected

  # Allow current user in models
  def set_current_user
    Authorization.current_user = nil # Need to do this to stop devise from using a previous user

    # Skip authentication if controller/action is in the exclude list
    unless SKIP_DEVISE_AUTHENTICATION.include?({:controller => params[:controller].to_sym, :action => params[:action].to_sym})
      # Check the expires_at token to see if we've still got a valid token
      if current_user.try(:token_expired?)
        sign_out(current_user)
        redirect_to new_user_session_path
      else
        # auth_token overrides the session to log in a different user
        sign_out(current_user) if params[:auth_token].present? && current_user

        authenticate_user!
        Authorization.current_user = current_user

        # Remove auth_token now that user has been authenticated
        if params[:auth_token].present?
          current_user.auth_token = nil
          current_user.save
        end
      end
    end
  end
end
