class CommentsController < ApplicationController
  before_action :authenticate_user!, except: %i[index]

  def index
    event = Event.find(params[:event_id])
    comments = event.comments.page(params[:page]).per(params[:per_page]).order(created_at: :asc)

    render json: { data: comments.as_json, pagination: pagination_info(comments) }
  end

  def create
    event = Event.find(params[:event_id])
    comment = event.comments.create(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment.as_json, status: :ok
    else
      render json: { errors: comment.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    comment = current_user.comments.find(params[:id])
    if comment.update(comment_params)
      render json: comment.as_json, status: :ok
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