class YoutubeParserController < ApplicationController
  # GET /youtube_parser.json
  def index
    respond_to do |format|
      format.json do
        authorize(:youtube_parser, :index?)
        yt_info = YoutubeApi.get_video_info(params[:v])
        render :json => { :data => yt_info }
      end
    end
  end
end
