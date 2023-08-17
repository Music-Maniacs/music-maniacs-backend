class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation full_name]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
  end

  private

  def record_not_found
    render json: { error: :record_not_found }, status: :not_found
  end
end
