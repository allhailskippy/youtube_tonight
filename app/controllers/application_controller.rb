class ParentException < StandardError
end

class ApplicationController < ActionController::Base
  # Permissions
  include Pundit
  protect_from_forgery

  def after_sign_in_path_for(user)
    if user.requires_auth
      requires_auth_user_path(user)
    else
      root_path
    end
  end

  def permission_denied
    sign_out(current_user)
    redirect_to new_user_session_path
  end

  # If we want to skip devise authentication on current controller/actions specifically, set them up here
  SKIP_DEVISE_AUTHENTICATION = [
    {:controller => :auth, :action => :google_oauth2 },
    {:controller => :current_user, :action => :index }
  ]

  # Declarative Authorization in Models
  before_action :set_current_user

  # Userstamp Gem
  include Userstamp

  # Rails
  protect_from_forgery

  # Handle common exceptions
  rescue_from Exception, with: :general_exception_error
  rescue_from Pundit::NotAuthorizedError, with: :authorization_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_error
  rescue_from ParentException, with: :parent_error

protected
  def not_found_error
    render json: { errors: ['Not Found'] },
           status: :not_found
  end

  def invalid_record_error(e)
    render json: { errors: e.record.errors, full_errors: e.record.errors.full_messages },
           status: :unprocessable_entity
  end

  def authorization_error
    render json: { errors: ['Unauthorized'] },
           status: :unauthorized
  end

  def general_exception_error(e)
    NewRelic::Agent.notice_error(e)
    render json: { errors: [e.to_s] },
           status: :unprocessable_entity
  end

  def parent_error
    render json: { errors: ['Expected Show or Playlist to be provided'] },
           status: :expectation_failed
  end

  # Allow current user in models
  def set_current_user
    Authorization.current_user = nil

    # Skip authentication if controller/action is in the exclude list
    unless SKIP_DEVISE_AUTHENTICATION.include?({:controller => params[:controller].to_sym, :action => params[:action].to_sym})
      # Ensure token is up to date
      current_user.try(:get_token)

      # Check the expires_at token to see if we've still got a valid token
      if current_user.try(:token_expired?)
        sign_out(current_user)
        redirect_to new_user_session_path
      else
        begin
          authenticate_user!
          Authorization.current_user = current_user

          # Remove auth_token now that user has been authenticated
          if params[:auth_token].present?
            current_user.auth_token = nil
            current_user.save
          end
        rescue
          redirect_to new_user_session_path
        end
      end
    end
  end
end
