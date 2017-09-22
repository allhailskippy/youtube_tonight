class CallbackPolicy < ApplicationPolicy
  def google_oauth2?
    true
  end

  def failure?
    true
  end
end
