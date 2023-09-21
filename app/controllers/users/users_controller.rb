class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update destroy]
  USER_TO_JSON = { include: { links: { only: %i[id url title] },
                              images: { methods: %i[full_url] },
                              role: {} } }.freeze
  def user_info
    render json: current_user.as_json(USER_TO_JSON), status: :ok
  end

  def update
    user = current_user
    images_params = params[:images] if params[:images].present?

    if images_params.present?
      images_params.each do |image_param|
        user.images.create(file: image_param)
      end
    end

    if user.update(user_params_update)
      render json: user.as_json(methods: :state, include: %i[links role images]), status: :ok
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
    JSON.parse(params.require(:user)).deep_symbolize_keys.slice(:username,
                                                                :email,
                                                                :full_name,
                                                                :biography,
                                                                :role_id,
                                                                links_attributes: %i[url title _destroy id])
  end
end
