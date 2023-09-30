class CommentsController < ApplicationController
  include LikeableActions
  COMMENT_TO_JSON = { only: %i[id body created_at],
                      include: { user: { only: %i[id full_name] } },
                      methods: %i[anonymous likes_count] }.freeze

  before_action :authenticate_user!, except: %i[index]

  def index
    event = Event.find(params[:event_id])
    comments = event.comments.page(params[:page]).per(params[:per_page]).order(created_at: :asc)

    comment_json = comments.as_json(COMMENT_TO_JSON)
    verify_like(comment_json, comments)
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

  def verify_like(entity_json ,pagination_entity)
    if current_user.present?
      entity_json.each do |data|
        entity = Comment.find(data['id'])
        data['liked_by_current_user'] = current_user.likes?(entity) if entity.present?
      end
    end
    comment_json = entity_json
    render json: { data: comment_json, pagination: pagination_info(pagination_entity) }
  end
end
