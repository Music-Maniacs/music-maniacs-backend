class Admin::TrustLevelsController < ApplicationController
  before_action :validate_user_is_admin

  def index
    trust_levels = TrustLevel.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: trust_levels, pagination: pagination_info(trust_levels) }
  end

  def create
    trust_level = TrustLevel.new(trust_level_params)

    if trust_level.save
      render json: trust_level, status: :ok
    else
      render json: { errors: trust_level.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    trust_level = TrustLevel.find(params[:id])
    render json: trust_level.as_json(methods: :permission_ids)
  end

  def update
    trust_level = TrustLevel.find(params[:id])

    if trust_level.update(trust_level_params)
      render json: trust_level, status: :ok
    else
      render json: { errors: trust_level.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    trust_level = TrustLevel.find(params[:id])

    if trust_level.destroy
      head :no_content, status: :ok
    else
      render json: { errors: trust_level.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def trust_level_params
    params.require(:trust_level).permit(:name, :order, :days_visited, :viewed_events, :likes_received, :likes_given, :comments_count, permission_ids: [])
  end
end
