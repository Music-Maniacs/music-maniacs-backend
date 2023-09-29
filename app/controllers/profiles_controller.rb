class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show reviews]

  USER_TO_JSON = { only: %i[username full_name biography email],
                   include: { links: { only: %i[id url title] },
                              last_reviews: { only: %i[id rating description created_at reviewable_type],
                                              include: { user: { only: %i[id full_name] } },
                                              methods: :anonymous },
                              # images: { only: %i[id], methods: %i[full_url] },
                              # user_stat: { only: %i[id days_visited viewed_events likes_given likes_received comments_count last_session penalty_score] }
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

  def show
    user = User.find(params[:id])
    render json: user.as_json(USER_TO_JSON), status: :ok
  end

  def reviews
    user = User.find(params[:id])
    reviews = user.reviews.page(params[:page]).per(params[:per_page])

    render json: { data: reviews.as_json(Review::TO_JSON), pagination: pagination_info(reviews) }
  end

  private

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end
