class PlaylistItem < ActiveRecord::Base
  model_stamper

  ##
  # Relationships
  #
  belongs_to :playlist
end
