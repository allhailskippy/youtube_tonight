class ShowUser < ActiveRecord::Base
  # == Relationships ========================================================
  belongs_to :user
  belongs_to :show
end
