class PlaylistItem < ActiveRecord::Base
  model_stamper

  ##
  # Relationships
  #
  belongs_to :playlist

  # Here for consistency
  def self.as_json_hash
    {
    }
  end
end
