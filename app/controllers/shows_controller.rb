class ShowsController < ApplicationController
  # GET /shows
  # GET /shows.json
  def index
    @shows = Show.all
    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: @shows.as_json
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
