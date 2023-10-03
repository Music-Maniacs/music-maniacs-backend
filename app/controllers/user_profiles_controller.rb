class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show reviews]
  USER_TO_JSON_UPDATE = { include: { links: { only: %i[id url title] },
                                     role: { only: %i[id name] },
                                     profile_image: {
                                       only: %i[id created_at],
                                       methods: :full_url
                                     },
                                     cover_image: {
                                       only: %i[id created_at],
                                       methods: :full_url
                                     } } }.freeze

  USER_TO_JSON = { only: %i[username full_name biography email],
                   include: { links: { only: %i[id url title] },
                              last_reviews: { only: %i[id rating description created_at reviewable_type],
                                              include: { user: { only: %i[id full_name] } },
                                              methods: :anonymous },
                              user_stat: { except: %i[id user_id created_at updated_at] },
                              profile_image: {
                                only: %i[id created_at],
                                methods: :full_url
                              },
                              cover_image: {
                                only: %i[id created_at],
                                methods: :full_url
                              },
                              role: { only: %i[id name] } } }.freeze

  def info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def change_password
    if current_user.update(user_params_change_password)
      render head: :no_content, status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.destroy
      head :no_content, status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    user = User.find(params[:id])
    render json: user.as_json(USER_TO_JSON), status: :ok
  end

  def reviews
    user = User.find(params[:id])
    reviews = user.reviews.page(params[:page]).per(params[:per_page])

    render json: { data: reviews.as_json(Review::TO_JSON), pagination: pagination_info(reviews) }
  end

  %w[artist producer venue event].each do |entity|
    define_method "show_followed_#{entity.pluralize}" do
      followed_entities_search = current_user.send("followed_#{entity.pluralize}").ransack(params[:q])
      followed_entities = followed_entities_search.result(distinct: true).page(params[:page]).per(params[:per_page])

      render json: { data: followed_entities.as_json(only: %i[id name]),
                     pagination: pagination_info(followed_entities) }
    end
  end

  def update
    # Recuperacion de imagen desde params
    image_params_cover = params[:cover_image] if params[:cover_image].present?
    image_params_profile = params[:profile_image] if params[:profile_image].present?

    #### CREATE UPDATE IMAGES ####
    update_image(current_user, image_params_cover, 'cover') if image_params_cover.present?
    update_image(current_user, image_params_profile, 'profile') if image_params_profile.present?

    #### DESTROY IMAGES ####
    current_user.cover_image.destroy if params[:destroy_cover_image].present? && current_user.cover_image.present?
    current_user.profile_image.destroy if params[:destroy_profile_image].present? && current_user.profile_image.present?

    if current_user.update(user_params_update)
      render json: current_user.reload.as_json(USER_TO_JSON_UPDATE), status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_params_update
    JSON.parse(params.require(:user)).deep_symbolize_keys.slice(:username,
                                                                :email,
                                                                :full_name,
                                                                :biography,
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

