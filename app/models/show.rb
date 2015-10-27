class Show < ActiveRecord::Base
  attr_accessible :title, :air_date
  attr_accessor :video_count

  ##
  # Validations
  #
  validates :title, :presence => true
  validates :air_date, :date => { :after_or_equal_to => Date.today }

  ##
  # Relations
  #
  has_many :videos

  ##
  # Methods
  #
  def self.as_json_hash
    {
      methods: [:video_count]
    }
  end
end
