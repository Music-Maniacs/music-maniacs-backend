class Admin::RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_action

  def index
    roles = roles_scope.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

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
    user = roles_scope.find(params[:id])
    render json: user.as_json(methods: :permission_ids)
  end

  def update
    role = roles_scope.find(params[:id])

    if role.update(role_params)
      render json: role, status: :ok
    else
      render json: { errors: role.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    role = roles_scope.find(params[:id])

    if role.destroy
      head :no_content, status: :ok
    else
      render json: { errors: role.errors.details }, status: :unprocessable_entity
    end
  end

  def roles_select
    render json: Role.all.as_json(only: %i[id name]), status: :ok
  end

  def permissions_select
    render json: Permission.all.as_json(only: %i[id name action subject_class]), status: :ok
  end

  private

  def roles_scope
    # para que no devuelva TrustLevels, no sé si es la mejor forma pero por ahora lo dejo así
    Role.where(type: nil)
  end

  def role_params
    params.require(:role).permit(:name, permission_ids: [])
  end
end
