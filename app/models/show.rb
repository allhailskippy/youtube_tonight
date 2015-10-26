class Show < ActiveRecord::Base
  attr_accessible :title, :air_date

  ##
  # Validations
  #
  validates :title, :presence => true
  validates :air_date, :date => { :after_or_equal_to => Date.today }
end
