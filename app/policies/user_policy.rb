class UserPolicy < ApplicationPolicy
  def manage?
    has_role?(:admin)
  end

  def show?
    has_role?(:host) or manage?
  end

  def update?
    user.id == record.id or manage?
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
