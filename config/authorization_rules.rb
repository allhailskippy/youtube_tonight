authorization do
  role :guest do
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :callbacks, :to => :google_oauth2
    has_permission_on :callbacks, :to => :failure
    has_permission_on :home, :to => :read
    has_permission_on :current_user, :to => :index

    # Devise requires update privs to users, users still need to be logged in to access
    # controller actions so this should be safe
    has_permission_on :users, :to => [:update, :requires_auth]
    has_permission_on :devise_sessions, :to => :manage
  end

  role :host do
    includes :guest

    has_permission_on :users, :to => [:update, :requires_auth]
    has_permission_on :videos, :to => :manage
    has_permission_on :shows, :to => :manage
    has_permission_on :youtube_parser, :to => :read
    has_permission_on :broadcasts, :to => :read
    has_permission_on :playlists do
      to :manage
      if_attribute :user => is {user}
    end
    has_permission_on :playlist_items do
      to :manage
      if_attribute :playlist => { :user => is {user} }
    end
  end

  # permissions on other roles, such as
  role :admin do
    includes :guest
    includes :host

    has_permission_on :users, :to => :manage

    # Admins can see all playlists
    has_permission_on :playlists, :to => :manage
    has_permission_on :playlist_items, :to => :manage
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete, :index, :show]
  privilege :create, :includes => :new
  privilege :read, :includes => [:index, :show]
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
