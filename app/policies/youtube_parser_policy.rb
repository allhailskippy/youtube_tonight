class YoutubeParserPolicy < ApplicationPolicy
  def read?
    has_role?(:host, :admin)
  end
end
