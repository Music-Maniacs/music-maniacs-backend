class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:user_info]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def change_password
    if current_user.update(user_params_change_password)
      render head: :no_content, status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end
