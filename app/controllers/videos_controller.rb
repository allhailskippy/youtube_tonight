class VideosController < ApplicationController
  def index
    @videos = Video.all
    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: @videos.as_json
        }
      end
    end
  end
end
