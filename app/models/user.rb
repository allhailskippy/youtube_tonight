class User < ActiveRecord::Base
  model_stamper

  attr_accessor :role_titles

  ##
  # Authentication
  #
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :trackable,
    :omniauthable, :omniauth_providers => [:facebook]

  ##
  # Relationships
  #
  has_many :roles, :dependent => :destroy

  ##
  # Validation
  #
  validates :role_titles,
    :presence => {
      :message => "must be selected"
    },
    :on => :update,
    :if => Proc.new{|r| !r.requires_auth }

  ##
  # Hooks
  #
  before_update :update_roles, :if => Proc.new {|r|
    r.role_titles != r.role_symbols.collect(&:to_s) || r.requires_auth_changed?
  }

  ##
  # Methods
  #
  # Stores user info on successful sign in from facebook
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.provider = auth.provider
      u.uid = auth.uid
      u.requires_auth = true
    end
    user.expires_at = auth.credentials.expires_at
    user.email = auth.info.email
    user.name = auth.info.name
    user.profile_image = auth.info.image
    user.save!
    user
  end

  # To determine if our token has expired
  def token_expired?(new_time = nil)
    return Time.at(expires_at) < Time.now rescue true
  end

  # Used for finding out what roles a user has (declarative authorization)
  def role_symbols
    (roles || []).map {|r| r.title.to_sym}
  end

  # Here for consistency
  def self.as_json_hash
    {
      :include => :roles,
      :methods => [:role_titles, :is_admin]
    }
  end

  # Deal with roles on update
  def update_roles
    # Wipe out any existing roles
    roles.destroy_all
    roles.reload

    if !requires_auth
      self.role_titles ||= []
      self.role_titles.each do |title|
        self.roles.build(:title => title)
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
end
