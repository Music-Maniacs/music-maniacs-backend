module ReviewableActions
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: %i[add_review update_review destroy_review]
  end

  def add_review
    reviewable = search_model_scope.find(params[:id])
    review = reviewable.reviews.create(review_params.merge(user: current_user))

    if review.save
      render json: review.as_json, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  def update_review
    review = current_user.reviews.find(params[:review_id])

    if review.update(review_params)
      render json: review.as_json, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  # TODO: que los admin puedan borrar reviews
  def destroy_review
    review = current_user.reviews.find(params[:review_id])

    if review.destroy
      head :no_content, status: :ok
    else
      render json: { errors: review.errors.details }, status: :unprocessable_entity
    end
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.constantize
  end

  def review_params
    params.require(:review).permit(:rating, :description)
  end
end
