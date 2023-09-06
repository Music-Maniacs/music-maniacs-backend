module FollowableActions
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: %i[follow unfollow]
  end

  def follow
    followable = search_model_scope.find(params[:id])
    followable.add_follower(current_user) unless current_user.follows?(followable)

    head :no_content, status: :ok
  end

  def unfollow
    followable = search_model_scope.find(params[:id])
    followable.remove_follower(current_user)

    head :no_content, status: :ok
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.constantize
  end
end
