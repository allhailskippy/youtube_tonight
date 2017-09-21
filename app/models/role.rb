class Role < ActiveRecord::Base
  # == Relationships ========================================================
  belongs_to :user

  # == Validations ==========================================================
  validates :title, :presence => true, :uniqueness => {:scope => :user_id}
end
