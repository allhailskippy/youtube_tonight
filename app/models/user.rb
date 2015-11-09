class User < ActiveRecord::Base
  acts_as_paranoid_versioned

  model_stamper

  attr_accessible :auth_hash, :email, :expires_at, :facebook_id, :name, :profile_image, :provider

  ##
  # Authentication
  #
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :trackable,
    :omniauthable, :omniauth_providers => [:facebook]

  ##
  # Relationships
  #
  has_many :roles

  ##
  # Methods
  #
  # Stores user info on successful sign in from facebook
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
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
end
