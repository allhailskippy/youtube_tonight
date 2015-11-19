class RolesController < ApplicationController
  # POST /roles.json
  def create
    respond_to do |format|
      begin
        # Create
        @role = scoped.build(role_params)

        permitted_to!(:create, @role)

        # Save role
        @role.save!

        format.json do
          render json: @role.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
              errors: @role.errors,
              full_errors: @role.errors.full_messages
            },
            status: :unprocessable_entity
        end
      end
    end
  end

private
  def role_params
    params.require(:role).permit(
      :user_id, :title
    )
  end
end
