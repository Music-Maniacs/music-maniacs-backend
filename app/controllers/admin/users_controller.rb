class Admin::UsersController < ApplicationController
  def index
    q = users_scope.ransack(params[:q])
    users = q.result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: users.as_json(methods: :state, include: :role), pagination: pagination_info(users) }
  end

  def show
    user = users_scope.find(params[:id])
    render json: user.as_json(methods: :state, include: %i[links role])
  end

  def create
    user = User.new(user_params_create)

    if user.save
      render json: user.as_json(methods: :state, include: :role), status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    user = users_scope.find(params[:id])

    if user.update(user_params_update)
      render json: user.as_json(methods: :state, include: %i[links role]), status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      head :no_content, status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  private

  # en el controller de admin se tienen que poder ver los usuarios borrados
  def users_scope
    User.with_deleted
  end

  def user_params_create
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :full_name, :biography,
                                 :role_id, links_attributes: %i[url title _destroy id])
  end

  def user_params_update
    params.require(:user).permit(:username, :email, :full_name, :biography, :role_id,
                                 links_attributes: %i[url title _destroy id])
  end
end
