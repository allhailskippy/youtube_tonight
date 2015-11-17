class Video < ActiveRecord::Base
  ##
  # Validations
  #
  validates :title, :presence => true
  validates :link, :presence => true, :url => true
  validate :validate_start_end_time

  ##
  # Relastions
  #
  belongs_to :show

  ##
  # Hooks
  #
  before_create :set_sort_order
  after_save :send_video_update_request
  after_destroy :send_video_update_request

  ##
  # Methods
  #
  def set_sort_order
    order = show.videos.maximum(:sort_order) + 1 rescue 0
    write_attribute(:sort_order, order)
  end

  def validate_start_end_time
    if start_time && end_time && start_time >= end_time
      errors.add(:base, "Start At cannot be greater than End At")
    end

    if end_time.to_i > api_duration_seconds.to_i
      errors.add(:base, "End At cannot be longer than the video duration: " + api_duration_seconds.to_s)
    end
  end

  def send_video_update_request
    WebsocketRails[:video_player].trigger(:update_video_list, {:show_id => show_id})
  end
end
