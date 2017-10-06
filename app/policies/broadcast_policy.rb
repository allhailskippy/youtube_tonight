class BroadcastPolicy < ApplicationPolicy
  only_attribute :index?

  def index?
    has_roles?(:host, :admin)
  end
end
