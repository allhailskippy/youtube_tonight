class Video < ActiveRecord::Base
  attr_accessible :title, :link, :show_id, :start_time, :end_time, :sort_order,
    :video_id, :api_published_at, :api_channel_id, :api_channel_title,
    :api_description, :api_thumbnail_medium_url, :api_thumbnail_default_url,
    :api_thumbnail_high_url, :api_title

  ##
  # Validations
  #
  validates :title, :presence => true
  validates :link, :presence => true, :url => true

  ##
  # Relastions
  #
  belongs_to :show

  ##
  # Hooks
  #
  before_create :set_sort_order

  ##
  # Methods
  #
  def set_sort_order
    order = show.videos.maximum(:sort_order) + 1 rescue 0
    write_attribute(:sort_order, order)
  end
end
