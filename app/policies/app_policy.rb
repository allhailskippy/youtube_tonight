class AppPolicy < ApplicationPolicy
  only_attrs :index?

  def index?
    true
  end
end
