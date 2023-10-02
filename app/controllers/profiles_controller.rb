class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show reviews]

  USER_TO_JSON = { only: %i[username full_name biography email],

                   include: { links: { only: %i[id url title] },
                              last_reviews: { only: %i[id rating description created_at reviewable_type],
                                              include: { user: { only: %i[id full_name] } },
                                              methods: :anonymous },
                              # images: { only: %i[id], methods: %i[full_url] },
                              user_stat: { except: %i[id user_id created_at updated_at] },
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

  def index_followed
    followed_entities = current_user.follows.includes(:followable)
                                    .ransack(params[:q])
                                    .result(distinct: true)
                                    .page(params[:page])
                                    .per(params[:per_page])
                                    .order(created_at: :desc)

    data = followed_entities.map do |entity_followed|
      entity_show = Artist.find_by(id: entity_followed.followable_id) ||
                    Producer.find_by(id: entity_followed.followable_id) ||
                    Venue.find_by(id: entity_followed.followable_id) ||
                    Event.find_by(id: entity_followed.followable_id)
      {
        id: entity_show.id,
        name: entity_show.name,
        followable_type: entity_followed.followable_type
      }
    end

    render json: { data: data, pagination: pagination_info(followed_entities) }
  end

  %w[artist producer venue event].each do |entity|
    define_method "show_followed_#{entity.pluralize}" do
      followed_entities_search = current_user.send("followed_#{entity.pluralize}").ransack(params[:q])
      followed_entities = followed_entities_search.result(distinct: true).page(params[:page]).per(params[:per_page])

      render json: { data: followed_entities.as_json(only: %i[id name]),
                     pagination: pagination_info(followed_entities) }
    end
  end

  private

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end