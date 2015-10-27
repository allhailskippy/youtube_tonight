class YoutubeParserController < ApplicationController
  def index
    yt_info = YoutubeApi.get_video_info(params[:v])
    respond_to do |format|
      format.json do
        render :json => yt_info
      end
    end
  end
end
