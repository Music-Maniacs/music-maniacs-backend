class Admin::UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: @users.as_json, pagination: pagination_info(@users) }
  end

  def show
    @user = User.find(params[:id])
    render json: @user.as_json(methods: :state)
  end

  def create
    @user = User.new(user_params_create)

    if @user.save
      render json: @user, status: :ok
    else
      render json: @user.errors.details, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params_update)
      render json: @user, status: :ok
    else
      render json: @user.errors.details, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      head :no_content, status: :ok
    else
      render json: @user.errors.details, status: :unprocessable_entity
    end
  end

  private

  def user_params_create
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :full_name, :biography, links_attributes: [:url, :title, :_destroy, :id])
  end

  def user_params_update
    params.require(:user).permit(:username, :email, :full_name, :biography, links_attributes: [:url, :title, :_destroy, :id])
  end
end
