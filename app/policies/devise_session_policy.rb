class DeviseSessionPolicy < ApplicationPolicy
  exclude_attributes :new?, :edit?

  def manage?
    true 
  end
end
