class ShowPolicy < ApplicationPolicy
  def manage?
    !!has_role?(:admin)
  end

  def read?
    if has_role?(:host)
      record.users.include?(user)
    end or manage?
  end

  class Scope < Scope
    def resolve
      if has_role?(:admin)
        Show.all
      else
        Show.joins(:users).where(users: { id: 31 }).all
      end
    end
  end
end
