class ShowsController < ApplicationController
  # GET /shows
  # GET /shows.json
  def index
    respond_to do |format|
      format.html
      format.json do
        shows = Show.all
        shows_by_id = shows.inject({}){|acc, show| acc[show.id] = show; acc}
        Video.where(show_id: shows_by_id.keys).group(:show_id).count.each do |show_id, count|
          shows_by_id[show_id].video_count = count
        end

        render json: {
          data: shows_by_id.values.as_json(Show.as_json_hash)
        }
      end
    end
  end

  # GET /shows/:id.json
  def show
    respond_to do |format|
      begin
        @show = Show.find(params[:id])
        format.json do
          render json: {
            data: @show.as_json
          }
        end
      rescue ActiveRecord::RecordNotFound
        format.json do
          render json: {
            errors: 'Not Found'
          },
          status: :unprocessable_entity
        end
      rescue Exception => e
        format.json do
          render json: {
            errors: e.to_s
          },
          status: :unprocessable_entity
        end
      end
    end
  end

  # POST /shows.json
  def create
    respond_to do |format|
      begin
        # Create
        @show = scoped.build(params[:show])

        # TODO: Permissions
        # permitted_to!(:create, @show)

        # Save Show
        @show.save!

        format.json do
          render json: @show.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
              errors: @show.errors,
              full_errors: @show.errors.full_messages
            },
            status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /shows/:id.json
  def update
    @show = scoped.find(params[:id])

    respond_to do |format|
      begin
        @show.update_attributes!(params[:show])
        format.json do
          render json: @show.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
            errors: @show.errors,
            full_errors: @show.errors.full_messages
          },
          status: :unprocessable_entity
        end
      rescue Exception => e
        format.json do
          render json: {
            errors: e.to_s
          },
          status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /shows/:id
  def destroy
    respond_to do |format|
      begin
        @show = scoped.find(params[:id])
        @show.destroy
        format.json do
          render json: {
            :status => :ok
          }
        end
      rescue Exception => e
        format.json do
          render json: {
            :errors => [e.to_s]
          },
          status: :unprocessable_entity
        end
      end
    end
  end

private
  def scoped
    Show.scoped
  end
end
