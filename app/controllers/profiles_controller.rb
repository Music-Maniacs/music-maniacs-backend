class ProfilesController < ApplicationController
  before_action :authenticate_user!
  USER_TO_JSON_UPDATE = { include: { links: {},
                                     role: {},
                                     profile_image: {
                                       only: %i[id created_at image_type],
                                       methods: :full_url
                                     },
                                     cover_image: {
                                       only: %i[id created_at image_type],
                                       methods: :full_url
                                     } } }.freeze

  def info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user

    # Recuperacion de imagen desde params
    image_params_cover = params[:cover_image] if params[:cover_image].present?
    image_params_profile = params[:profile_image] if params[:profile_image].present?

    #### CREATE UPDATE IMAGES ####
    update_image(user, image_params_cover, 'cover') if image_params_cover.present?
    update_image(user, image_params_profile, 'profile') if image_params_profile.present?

    #### DESTROY IMAGES #### (con comprobacion de permiso para borrar)
    if params[:destroy_cover_image].present? && user.cover_image.present?
      user.cover_image.destroy
      user.update(cover_image: nil)
    end

    if params[:destroy_profile_image].present? && user.profile_image.present?
      user.profile_image.destroy
      user.update(profile_image: nil)
    end

    if user.update(user_params_update)
      render json: user.as_json(USER_TO_JSON_UPDATE), status: :ok
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
                                                                :links_attributes)
  end

  def update_image(user, image_params, image_type)
    if user.public_send("#{image_type}_image").present?
      user.public_send("#{image_type}_image").file.purge
      user.public_send("#{image_type}_image").file.attach(image_params)
    else
      user.public_send("#{image_type}_image=", Image.new(file: image_params, image_type: image_type))
    end
  end
end
