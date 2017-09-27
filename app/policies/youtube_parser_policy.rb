class YoutubeParserPolicy < ApplicationPolicy
  only_attribute :index?

  def index?
    has_role?(:host, :admin)
  end
end
