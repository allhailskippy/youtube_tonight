class VideoPolicy < ApplicationPolicy
  exclude_attributes :new?, :edit?

  def index?
    record.is_a?(Symbol) || read?
  end

  def read?
    if has_role?(:host)
      return false if record.is_a?(Symbol)
      if record.parent_type == 'Show'
        record.parent.users.include?(user)
      elsif record.parent_type == 'Playlist'
        record.parent.user == user
      end
    end || manage?
  end

  def create?
    has_roles?(:admin, :host)
  end

  def manage?
    if has_role?(:admin)
      true
    elsif has_role?(:host)
      return false if record.is_a?(Symbol)

      if read?
        if record.parent_type == 'Show'
          record.changes.blank? || record.changes.keys == ["position"] || record.creator == user
        elsif record.parent_type == 'Playlist'
          true
        end
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
