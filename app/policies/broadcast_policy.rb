class BroadcastPolicy < ApplicationPolicy
  def read?
    has_role?(:host, :admin)
  end
end
