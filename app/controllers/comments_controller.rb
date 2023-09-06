class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    event = Event.find(params[:event_id])
    comment = event.comments.create(comment_params)
    comment.user = current_user

    if @comment.save
      render json: comment.as_json, status: :ok
    else
      render json: { errors: comment.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    comment = current_user.comments.find(params[:id])
    if comment.update(comment_params)
      render json: @comment.as_json, status: :ok
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
    params.require(:comment).permit(:content)
  end
end
