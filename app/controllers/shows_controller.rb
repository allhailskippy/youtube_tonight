class ShowsController < ApplicationController
  # GET /shows
  # GET /shows.json
  def index
    respond_to do |format|
      format.html
      format.json do
        shows = Show.with_permissions_to(:read).all
        shows_by_id = shows.inject({}){|acc, show| acc[show.id] = show; acc}
        Video.with_permissions_to(:read).where(parent_id: shows_by_id.keys, parent_type: 'Show').group(:parent_id).count.each do |show_id, count|
          shows_by_id[show_id].video_count = count
        end

        render json: { data: shows_by_id.values.as_json(Show.as_json_hash) }
      end
    end
  end

  # GET /shows/:id.json
  def show
    respond_to do |format|
      begin
        show = Show.with_permissions_to(:read).find(params[:id])
        format.json do
          render json: { data: show.as_json(Show.as_json_hash) }
        end
      rescue ActiveRecord::RecordNotFound
        format.json do
          render json: { errors: 'Not Found' },
                 status: :unprocessable_entity
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # POST /shows.json
  def create
    respond_to do |format|
      begin
        show = scoped.build(show_params)

        permitted_to!(:create, show)
        show.save!

        format.json do
          render json: { data: show.as_json }
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: { errors: show.errors, full_errors: show.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /shows/:id.json
  def update
    show = scoped.find(params[:id])

    respond_to do |format|
      begin
        permitted_to!(:update, show)
        show.update_attributes!(show_params)

        format.json do
          render json: { data: show.as_json }
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: { errors: show.errors, full_errors: show.errors.full_messages },
                 status: :unprocessable_entity
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /shows/:id
  def destroy
    respond_to do |format|
      begin
        show = scoped.find(params[:id])
        permitted_to!(:delete, show)
        show.destroy

        format.json do
          render json: { :status => :ok }
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { :errors => [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

private
  def scoped
    Show.all
  end

  def show_params
    params.require(:show).permit(:title, :air_date, :hosts)
  end
end
