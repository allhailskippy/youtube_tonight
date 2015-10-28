class Role < ActiveRecord::Base
  ##
  # Validations
  #
  validates :title, :presence => true, :uniqueness => {:scope => :user_id}

  ##
  # Relationships
  #
  belongs_to :user
end
