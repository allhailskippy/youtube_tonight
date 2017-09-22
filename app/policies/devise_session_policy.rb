class DeviseSessionPolicy < ApplicationPolicy
  exclude_attrs :new?, :edit?

  def manage?
    true 
  end
end
