class YoutubeParserController < ApplicationController
  # GET /youtube_parser.json
  def index
    respond_to do |format|
      format.json do
        begin
          yt_info = YoutubeApi.get_video_info(params[:v])
          render :json => { :data => yt_info }
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render :json => { :errors => [e.to_s] },
                 :status => :unprocessable_entity
        end
      end
    end
  end
end
