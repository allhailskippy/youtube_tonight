class BroadcastsController < ApplicationController
  layout "broadcasts"

  def index
    authorize :broadcast, :index?
  end
end
