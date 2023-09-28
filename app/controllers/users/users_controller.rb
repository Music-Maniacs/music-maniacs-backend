class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info reviews]

  USER_TO_JSON = { only: %i[username full_name biography],
                   include: { links: { only: %i[id url title] },
                              # images: { only: %i[id],
                              #           methods: %i[full_url] },
                              role: { only: %i[id name] } # ,
                              # user_stat: { only: %i[id days_visited viewed_events likes_given
                              #                       likes_received comments_count last_session penalty_score] }
                            } }.freeze

  REVIEW_TO_JSON = { only: %i[id rating description created_at reviewable_type],
                     include: { user: { only: %i[id full_name] } },
                     methods: :anonymous }.freeze

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def show
    user = params[:id].present? ? User.find(params[:id]) : current_user
    render json: user.as_json(USER_TO_JSON), status: :ok
  end

  def reviews
    user = params[:id].present? ? User.find(params[:id]) : current_user
    reviews = user.reviews.page(params[:page]).per(params[:per_page])

    render json: { data: reviews.as_json(REVIEW_TO_JSON), pagination: pagination_info(reviews) }
  end
end
