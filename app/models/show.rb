class Show < ActiveRecord::Base
  # == Relationships ========================================================
  has_many :videos, dependent: :destroy, as: :parent
  has_many :show_users
  has_many :users, through: :show_users

  # == Validations ==========================================================
  validates :title, presence: true
  validates :air_date, date: { :after_or_equal_to => Date.today }, on: :create
  validates :air_date, date: true, on: :update
  validates :hosts, presence: { message: 'must be selected' }

  # == Instance Methods =====================================================
  def hosts
    @hosts || users.collect{|u| u.id.to_s}.sort.join(',')
  end

  def hosts=(ids)
    @hosts = ids

    current_ids = users.collect{|u| u.id.to_s}
    new_ids = ids.split(',')

    to_clear = (current_ids - new_ids)
    if to_clear.present?
      show_users.where(show_id: id, user_id: to_clear).destroy_all
    end

    to_add = (new_ids - current_ids)
    if to_add.present?
      users << User.where('id in (?)', to_add).all
    end
  end

  def video_count
    videos.size
  end

  def as_json(options = {})
    super({
      include: :users,
      methods: [:video_count, :hosts]
    }.merge(options))
  end
end
