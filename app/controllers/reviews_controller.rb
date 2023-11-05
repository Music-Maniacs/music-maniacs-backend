class ReviewsController < ApplicationController
  include ReportableActions
  before_action :authenticate_user!

  def create
    event = Event.find(params[:event_id])
    review = event.reviews.build(review_params)
    review.user = current_user
    review.reviewable = event.send(params[:reviewable_klass])

    if review.save
      render json: review.as_json(Review::TO_JSON), status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    review = current_user.reviews.find(params[:id])

    if review.update(review_params)
      render json: review.as_json(Review::TO_JSON), status: :ok
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
