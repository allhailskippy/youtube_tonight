class CallbackPolicy < ApplicationPolicy
  only_attrs :google_oauth2?, :failure?

  def google_oauth2?
    true
  end

  def failure?
    true
  end
end
