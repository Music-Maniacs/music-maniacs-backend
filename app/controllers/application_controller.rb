class ApplicationController < ActionController::API
  # before_action :set_default_request_format
  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from CanCan::AccessDenied do |_exception|
    render json: { error: :unauthorized }, status: :forbidden
  end

  # def set_default_request_format
  #   request.format = :json unless params[:format]
  # end

  # Derive the model name from the controller. UsersController will return User
  def self.permission
    controller_name.classify.constantize
  end

  protected

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation full_name]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
  end

  def pagination_info(scope)
    { total: scope.total_count }
  end

  private

  def record_not_found
    render json: { error: :record_not_found }, status: :not_found
  end

  def validate_user_is_admin
    return if current_user.admin?

    render json: { errors: :unauthorized }, status: :forbidden
  end

  def authorize_action
    authorize!(params[:action].to_sym, controller_name.classify.constantize) unless current_user&.admin?
  end
end
