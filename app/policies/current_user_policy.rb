class CurrentUserPolicy < ApplicationPolicy
  only_attribute :index?

  def index?
    true
  end
end
