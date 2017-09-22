class VideoPolicy < ApplicationPolicy
  def read?
    if has_role?(:host)
      if record.parent_type == 'Show'
        record.parent.users.include?(user)
      end
      if record.parent_type == 'Playlist'
        record.parent.user == user
      end
    end or manage?
  end

  def manage?
    if has_role?(:host)
      if record.parent_type == 'Show'
        record.parent.creator == user
      end
      if record.parent_type == 'Playlist'
        record.parent.user == user
      end
    end
  end

  class Scope < Scope
    def resolve
      if has_role?(:admin)
        Playlist.all
      else
        Playlist.where(user_id: user.id).all
      end
    end
  end
end
