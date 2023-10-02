module LikeableActions
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: %i[like dislike]
  end

  def like
    likeable = search_model_scope.find(params[:id])
    likeable.add_like(current_user) unless current_user.likes?(likeable)

    head :no_content, status: :ok
  end

  def remove_like
    likeable = search_model_scope.find(params[:id])
    likeable.remove_like(current_user)

    head :no_content, status: :ok
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.constantize
  end
end
