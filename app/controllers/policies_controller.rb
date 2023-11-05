class PoliciesController < ApplicationController
  def check_policy
    begin
      render json: resolve_policy(params[:class].constantize), status: 200
    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def navigation_policy
    render json: resolve_navigation_policy
  end

  private

  def resolve_policy(klass)
    result = {}
    klass.authorizable_endpoints.each do |action|
      result[action] = can?(action.to_sym, klass)
    end
    result
  end

  def resolve_navigation_policy
    return [] if current_user.blank?

    self.class.controllers.map do |controller|
      can?(:index, controller.permission)
    end
  end
end
