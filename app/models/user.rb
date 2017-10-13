class User < ActiveRecord::Base
  model_stamper

  # == Attributes ===========================================================
  attr_accessor :role_titles, :change_roles, :skip_playlist_import, :skip_registered_user_email, :skip_authorized_email

  # == Extensions ===========================================================
  devise :database_authenticatable,
         :trackable,
         :omniauthable,
         { omniauth_providers: [:google_oauth2] }

  # == Relationships ========================================================
  has_many :roles, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :show_users, dependent: :destroy
  has_many :shows, through: :show_users

  # == Validations ==========================================================
  validates :name, presence: true
  validates :email, presence: true
  validates :role_titles,
    presence: {
      message: "must be selected"
    },
    on: :update,
    if: Proc.new{|r| !r.requires_auth }

  # == Scopes ===============================================================
  scope :without_system_admin, -> { where("users.id != ?", SYSTEM_ADMIN_ID) }

  # == Callbacks ============================================================
  after_create :deliver_registered_user_email, unless: Proc.new{|r| r.skip_registered_user_email }
  after_create :import_playlists, unless: Proc.new{|r| r.skip_playlist_import }
  before_validation :update_roles, if: Proc.new{|r| r.change_roles }
  before_update :deliver_authorized_email, if: Proc.new{|r| !r.skip_authorized_email && !r.requires_auth && r.requires_auth_changed? }

  # == Class Methods ========================================================
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

  # == Instance Methods =====================================================
  def role_symbols
    (roles || []).map {|r| r.title.to_sym}
  end

  def role_titles
    (@role_titles || role_symbols).collect(&:to_sym)
  end

  # Accepts one or more roles
  # has_role(:admin)
  # has_role(:admin, :host)
  def has_role(*roles)
    # Must find at least one of roles to count
    (role_titles & roles.map(&:to_sym)).present?
  end
  alias_method :has_roles, :has_role

  def as_json(options = {})
    super({
      include: :roles,
      methods: [:role_titles, :is_admin]
    }.merge(options))
  end

  def is_admin
    role_symbols.any?{|r| r == :admin}
  end

  def get_token
    token = token_expired? ? get_refresh_token : auth_hash
    token
  end

  # This won't just return if we're out of date, it will
  # also get a new token if time is out. Will only ever
  # return true if we can't get a new token
  def token_expired?(new_time = nil)
    expired = Time.at(expires_at) < Time.now rescue true
    if expired
      begin
        get_refresh_token
        expired = Time.at(read_attribute(:expires_at)) < Time.now
      rescue Exception
        expired = true
      end
    end
    expired
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

    begin
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
        playlist.api_title = details[:title]
        playlist.api_description = details[:description]
        %w(default medium high standard maxres).each do |size|
          current_size = details[:thumbnails].try(size.to_sym)
          %w(url width height).each do |type|
            playlist.send("api_thumbnail_#{size}_#{type}=", current_size.try(type.to_sym))
          end
        end

        playlist.save! if playlist.changed?
      end

      playlists.reload
      playlists.each do |playlist|
        VideoImportWorker.perform_async(playlist.id)
      end
    rescue Exception => e
      NewRelic::Agent.notice_error(e)
    ensure
      update_attributes!(importing_playlists: false)
    end
    playlists
  end

protected
  def deliver_authorized_email
    UserMailer.authorized_email(self).deliver_now!
  end

  def deliver_registered_user_email
    UserMailer.registered_user(self).deliver_now!
  end

  def update_roles
    # Wipe out any existing roles
    roles.destroy_all
    roles.reload

    unless requires_auth
      self.role_titles ||= []
      self.role_titles.each do |title|
        next if !Authorization.current_user.try(:is_admin) && title.to_sym == :admin
        self.roles.build(title: title)
      end
    end
  end
end
