class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: %i[add_review update_review destroy_review]

  def create
    event = Event.find(params[:event_id])
    reviewable = params[:rewviewable_klass].find(params[:reviewable_id])
    review = event.reviews.create(review_params.merge(user: current_user, reviewable:))

    if review.save
      render json: review.as_json, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    review = current_user.reviews.find(params[:id])

    if review.update(review_params)
      render json: review.as_json, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  # TODO: que los admin puedan borrar reviews
  def destroy
    review = current_user.reviews.find(params[:id])

    if review.destroy
      head :no_content, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :description)
  end
end
