class Video < ActiveRecord::Base
  ##
  # Validations
  #
  validates :title, :presence => true
  validates :link, :presence => true, :url => true
  validate :validate_start_end_time

  ##
  # Relationships
  #
  belongs_to :parent, polymorphic: true

  ##
  # Hooks
  #
  before_create :set_position, if: Proc.new{|r| r.position.blank? }
  after_save :send_video_update_request
  after_destroy :send_video_update_request

  ##
  # Methods
  #
  # Here for consistency
  def self.as_json_hash
    {}
  end

  def set_position
    p = parent.videos.maximum(:position) + 1 rescue 0
    write_attribute(:position, p)
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
    WebsocketRails[:video_player].trigger(:update_video_list, {:show_id => parent_id})
  end
end
