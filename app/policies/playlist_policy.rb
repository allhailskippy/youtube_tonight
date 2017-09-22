class PlaylistPolicy < ApplicationPolicy
  def manage?
    if has_role?(:host)
      record.user == user
    end or has_role?(:admin)
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
