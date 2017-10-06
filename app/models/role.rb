class Role < ActiveRecord::Base
  model_stamper

  # == Relationships ========================================================
  belongs_to :user

  # == Validations ==========================================================
  validates :title, :presence => true, :uniqueness => {:scope => :user_id}
end
