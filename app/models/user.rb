class User < ActiveRecord::Base
  model_stamper

  attr_accessor :role_titles, :change_roles

  ##
  # Authentication
  #
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :trackable,
    :omniauthable, { omniauth_providers: [:google_oauth2] }

  ##
  # Relationships
  #
  has_many :roles, dependent: :destroy
  has_many :playlists, dependent: :destroy

  ##
  # Validation
  #
  validates :name, presence: true
  validates :email, presence: true
  validates :role_titles,
    presence: {
      message: "must be selected"
    },
    on: :update,
    if: Proc.new{|r| !r.requires_auth }

  ##
  # Hooks
  #
  after_create :deliver_registered_user_email,
               :import_playlists,
               :import_videos
  before_validation :update_roles, if: Proc.new{|r| r.change_roles }
  before_update :deliver_authorized_email, if: Proc.new{|r| !r.requires_auth && r.requires_auth_changed? }

  ##
  # Scopes
  #
  scope :without_system_admin, -> { where("users.id != ?", SYSTEM_ADMIN_ID) }

  ##
  # Methods
  #
  # Stores user info on successful sign in from google
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, email: auth.info.email).first_or_initialize do |u|
      u.provider = auth.provider
      u.email = auth.info.email
      u.requires_auth = true
    end
    user.auth_hash = auth.credentials.token
    user.refresh_token = auth.credentials.refresh_token
    user.expires_at = auth.credentials.expires_at
    user.name = auth.info.name
    user.profile_image = auth.info.image
    user.save!
    user
  end

  # To determine if our token has expired
  def token_expired?(new_time = nil)
    expired = Time.at(expires_at) < Time.now rescue true
    if expired
      # Try to get a new token
      get_refresh_token
      expired = Time.at(read_attribute(:expires_at)) < Time.now rescue true
    end
    expired
  end

  # Used for finding out what roles a user has (declarative authorization)
  def role_symbols
    (roles || []).map {|r| r.title.to_sym}
  end

  # Here for consistency
  def self.as_json_hash
    {
      include: :roles,
      methods: [:role_titles, :is_admin]
    }
  end

  # Deal with roles on update
  def update_roles
    # Wipe out any existing roles
    roles.destroy_all
    roles.reload

    unless requires_auth
      self.role_titles ||= []
      self.role_titles.each do |title|
        next if !Authorization.current_user.try(:is_admin) && title == 'admin'
        self.roles.build(title: title)
      end
    end
  end

  def is_admin
    roles.any?{|r| r.title == "admin"}
  end

  # Only the reader is the same
  # as role_symbols
  def role_titles
    @role_titles || role_symbols
  end

  def deliver_authorized_email
    UserMailer.authorized_email(self).deliver_now!
  end

  def deliver_registered_user_email
    UserMailer.registered_user(self).deliver_now!
  end

  # Gets a current token for the user. Does a
  # token refresh if necessary
  def get_token
    token = token_expired? ? get_refresh_token : auth_hash
    token
  end

  def get_refresh_token
    # Refresh auth token from google_oauth2.
    options = {
      body: {
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET,
        refresh_token: "#{refresh_token}",
        grant_type: 'refresh_token'
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    }
    refresh = HTTParty.post('https://accounts.google.com/o/oauth2/token', options)

    if refresh.code == 200
      write_attribute(:auth_hash, refresh.parsed_response['access_token'])
      write_attribute(:expires_at, DateTime.now + refresh.parsed_response['expires_in'].seconds)
      save!
    end
    read_attribute(:auth_hash)
  end

  def import_playlists
    update_attributes!(importing_playlists: true)

    # Get the list of playlists from YouTube
    yt_playlists = YoutubeApi.get_playlists(self)

    # Clean out any playlists that no longer exist
    new_ids = yt_playlists.values.collect{|p| p[:playlist_id] }
    current_ids = playlists.collect(&:api_playlist_id)
    playlists.where(api_playlist_id: (current_ids - new_ids)).destroy_all

    # Create/update existing playlists
    yt_playlists.each do |list, details|
      playlist = Playlist
        .where(user_id: id, api_playlist_id: details[:playlist_id])
        .first_or_initialize(
          user_id: id,
          api_playlist_id: details[:playlist_id],
        )
      playlist.api_title = list.to_s.titleize
      playlist.api_description = details[:description]
      %w(default medium high standard maxres).each do |size|
        %w(url width height).each do |type|
          playlist.send("api_thumbnail_#{size}_#{type}=", details[:thumbnails].try(size.to_sym).try(type.to_sym))
        end
      end
      playlist.creator_id = id
      playlist.updater_id = id

      playlist.save! if playlist.changed?
    end

    update_attributes!(importing_playlists: false)
    playlists.reload
    playlists
  end

  def import_videos
    playlists.each do |playlist|
      VideoImportWorker.perform_async(playlist.id)
    end
  end
end
