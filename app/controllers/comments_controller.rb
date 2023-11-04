class CommentsController < ApplicationController
  include LikeableActions

  before_action :authenticate_user!, except: %i[index]
  before_action :authorize_action, except: %i[index like unlike]

  COMMENT_TO_JSON = { only: %i[id body created_at],
                      include: { user: { only: %i[id full_name], methods: :profile_image_full_url } },
                      methods: %i[anonymous likes_count liked_by_current_user] }.freeze

  def index
    event = Event.find(params[:event_id])
    comments = event.comments.page(params[:page]).per(params[:per_page]).order(created_at: :asc)

    comments_json = if current_user.present?
                      comments.with_liked_by_user(current_user).as_json(COMMENT_TO_JSON)
                    else
                      comments.as_json(COMMENT_TO_JSON)
                    end
    render json: { data: comments_json, pagination: pagination_info(comments) }
  end

  def create
    event = Event.find(params[:event_id])
    comment = event.comments.create(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment.as_json(COMMENT_TO_JSON), status: :ok
    else
      render json: { errors: comment.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    comment = current_user.comments.find(params[:id])
    if comment.update(comment_params)
      render json: comment.as_json(COMMENT_TO_JSON), status: :ok
    else
      render json: { errors: @comment.errors.details }, status: :unprocessable_entity
    end
  end

  # TODO: que los admin puedan borrar comentarios
  def destroy
    comment = current_user.comments.find(params[:id])

    if comment.destroy
      head :no_content, status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
