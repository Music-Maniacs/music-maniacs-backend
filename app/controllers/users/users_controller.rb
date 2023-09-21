class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update destroy]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user
    puts "CURRENT_USER: #{user}"
    puts "CURRENT_USER: #{user.full_name}"
    if user.update(user_params_update)
      puts "USER: #{user}"
      render json: user.as_json(methods: :state, include: %i[links role]), status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
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

  private

  def user_params_update
    params.require(:user).permit(:username, :email, :full_name, :biography, :role_id,
                                 links_attributes: %i[url title _destroy id])
  end
end
