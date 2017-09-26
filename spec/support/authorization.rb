module Authorization
  module Maintenance
    def self.with_user(user)
      prev_user = Authorization.current_user
      Authorization.current_user = user
      User.stamper = user
      yield
    ensure
      Authorization.current_user = prev_user
      User.stamper = prev_user
    end

    def with_user (user, &block)
      Authorization::Maintenance.with_user(user, &block)
    end
  end
end
