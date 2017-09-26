class CurrentUserPolicy < ApplicationPolicy
  only_attrs :index?

  def index?
    true
  end
end
