class YoutubeParserController < ApplicationController
  def index
    respond_to do |format|
      begin
        yt_info = YoutubeApi.get_video_info(params[:v])
        format.json do
          render :json => {
            :data => yt_info
          }
        end
      rescue Exception => e
        format.json do
          render :json => {
            :error => e.to_s
          }
        end
      end
    end
  end
end
