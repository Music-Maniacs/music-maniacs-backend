class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update destroy]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def destroy
    user = current_user
    user.deleted_at = Time.now

    if user.save
      head :no_content, status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end
end
