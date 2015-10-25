class ShowsController < ApplicationController
  def index
    @shows = Show.order("id desc").all
    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: @shows.as_json
        }
      end
    end
  end
end
