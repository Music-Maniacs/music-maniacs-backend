class Admin::RolesController < ApplicationController
  def index
    roles = Role.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: roles, pagination: pagination_info(roles) }
  end

  def create
    role = Role.new(role_params)

    if role.save
      render json: role, status: :ok
    else
      render json: { errors: role.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    user = Role.find(params[:id])
    render json: user.as_json(methods: :permission_ids)
  end

  def update
    role = Role.find(params[:id])

    if role.update(role_params)
      render json: role, status: :ok
    else
      render json: { errors: role.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    role = Role.find(params[:id])

    if role.destroy
      head :no_content, status: :ok
    else
      render json: { errors: role.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, permission_ids: [])
  end
end
