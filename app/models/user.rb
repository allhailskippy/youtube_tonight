class User < ActiveRecord::Base
  attr_accessible :auth_hash, :email, :expires_at, :facebook_id, :name, :profile_image
end
