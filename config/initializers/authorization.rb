#
# Taken from the declarative_authorization gem. 
# https://github.com/stffn/declarative_authorization/
# 
module Authorization
  def self.current_user
    Thread.current["current_user"] || AnonymousUser.new
  end
  
  # Controller-independent method for setting the current user.
  def self.current_user=(user)
    Thread.current["current_user"] = user
  end
end
