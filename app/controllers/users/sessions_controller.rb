class Users::SessionsController < Devise::SessionsController
  include RackSessionFixController
  respond_to :json

  def create
    super do |resource|
      current_user.user_stat.increment_days_visited_once_per_day if resource.persisted? && current_user.present?
    end
  end

  private

  def respond_with(_resource, _opts = {})
    render json: { message: :logged_in, user: current_user.as_json(include: :role) }, status: :ok
  end

  def respond_to_on_destroy
    current_user ? log_out_success : log_out_failure
  end

  def log_out_success
    render json: { message: :logged_out }, status: :ok
  end

  def log_out_failure
    render json: { message: :unable_to_find_session }, status: :unauthorized
  end
end
