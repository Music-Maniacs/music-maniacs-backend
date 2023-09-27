class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:user_info]

  USER_TO_JSON = { only: %i[username full_name biography],
                   include: { links: { only: %i[id url title] },
                              # images: { only: %i[id],
                              #           methods: %i[full_url] },
                              role: { only: %i[id name] } # ,
                              # user_stat: { only: %i[id days_visited viewed_events likes_given
                              #                       likes_received comments_count last_session penalty_score] }
                            },
                   methods: %i[reviews] }.freeze

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def show
    render json: current_user.as_json(USER_TO_JSON), status: :ok
  end
end
