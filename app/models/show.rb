class Show < ActiveRecord::Base
  attr_accessor :video_count

  ##
  # Validations
  #
  validates :title, :presence => true
  validates :air_date, :date => { :after_or_equal_to => Date.today }, :on => :create
  validates :air_date, :date => true, :on => :update

  ##
  # Relationships
  #
  has_many :videos, dependent: :destroy, as: :parent

  ##
  # Methods
  #
  def self.as_json_hash
    {
      methods: [:video_count]
    }
  end
end
