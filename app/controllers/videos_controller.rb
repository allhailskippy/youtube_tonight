class VideosController < ApplicationController
  respond_to :html

  def index
    @videos = Video.all
  end
end
