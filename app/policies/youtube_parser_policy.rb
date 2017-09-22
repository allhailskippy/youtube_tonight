class YoutubeParserPolicy < ApplicationPolicy
  only_attrs :index?

  def index?
    has_role?(:host, :admin)
  end
end
