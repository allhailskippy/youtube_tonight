class UserPolicy < ApplicationPolicy
  add_attributes :requires_auth?, :import_playlists?
  exclude_attributes :new?, :edit?

  def manage?
    has_role?(:admin)
  end

  def index?
    if has_role?(:host)
      false
    end || read?
  end

  def show?
    has_role?(:host) || manage?
  end

  def update?
    manage? || user.id == record.id
  end

  def requires_auth?
    true
  end

  def import_playlists?
    update?
  end

  class Scope < Scope
    def resolve
      scope.without_system_admin.all
    end
  end
end
