class Video < ActiveRecord::Base
  attr_accessible :title, :link, :show_id, :start_time, :end_time

  ##
  # Validations
  #
  validates :title, :presence => true
  validates :link, :presence => true, :url => true

  ##
  # Relastions
  #
  belongs_to :show
end
