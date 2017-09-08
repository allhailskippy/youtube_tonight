class Show < ActiveRecord::Base
  attr_accessor :video_count, :hosts

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
  has_many :show_users
  has_many :users, through: :show_users

  ##
  # Hooks
  #
  before_save :update_hosts

  ##
  # Methods
  #
  def self.as_json_hash
    {
      include: :users,
      methods: [:video_count, :hosts]
    }
  end

  def hosts
    @hosts || users.collect(&:id).join(',')
  end

  # Deal with roles on update
  def update_hosts
    # Wipe out any existing roles
    users.destroy_all
    users.reload

    users << User.where('id in (?)', hosts.split(',')).all
  end
end
