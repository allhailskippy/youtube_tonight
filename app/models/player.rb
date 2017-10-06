class Player < ActiveRecord::Base
  model_stamper

  # == Relationships ========================================================
  belongs_to :user
end
