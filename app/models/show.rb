class Show < ActiveRecord::Base
  attr_accessor :video_count

  ##
  # Validations
  #
  validates :title, presence: true
  validates :air_date, date: { :after_or_equal_to => Date.today }, on: :create
  validates :air_date, date: true, on: :update
  validates :hosts, presence: { message: 'must be selected' }

  ##
  # Relationships
  #
  has_many :videos, dependent: :destroy, as: :parent
  has_many :show_users
  has_many :users, through: :show_users

  ##
  # Hooks
  #

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

  # Deal with hosts if passed in this way
  def hosts=(ids)
    @hosts = ids

    # Wipe out any existing roles
    users.destroy_all
    users.reload

    users << User.where('id in (?)', ids.split(',')).all
  end
end
