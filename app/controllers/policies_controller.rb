class PoliciesController < ApplicationController
  def check_policy
    begin
      render json: resolve_policy(params[:class].constantize, params[:action]), status: 200
    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  private

  def resolve_policy(klass, action)
    can?(action.to_sym, klass)
  end
end
