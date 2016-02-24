class Playlist < ActiveRecord::Base
  model_stamper

  ##
  # Relationships
  #
  belongs_to :user
  has_many :playlist_items, :dependent => :destroy

  # Here for consistency
  def self.as_json_hash
    {
    }
  end
end
