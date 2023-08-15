class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:user_info]

  def user_info
    render json: current_user, status: :ok
  end
end
