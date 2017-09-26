class ShowPolicy < ApplicationPolicy
  exclude_attrs :new?, :edit?

  def manage?
    !!has_role?(:admin)
  end

  def read?
    if has_role?(:host)
      record && record.users.include?(user)
    end || manage?
  end

  def index?
    if has_role?(:host)
      record.is_a?(Symbol) || read?
    end || read?
  end

  class Scope < Scope
    def resolve
      if has_role?(:admin)
        Show.all
      else
        Show.joins(:users).where(users: { id: user.id }).all
      end
    end
  end
end
