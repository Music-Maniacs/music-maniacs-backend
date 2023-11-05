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

  def self.permission
    self
  end

  def self.authorizable_endpoints
    self.class.action_methods.to_a.map(&:to_sym) - (controller.try(:public_endpoints) || [])
  end

  def self.controllers
    subclasses.map do |controller|
      next unless controller.respond_to?(:permission)
      next if controller.name.include?('Devise')
      next if controller.name.include?('Profile')
      next if controller.name.include?('Policies')
    end.compact
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

  def authorize_action
    authorize!(params[:action].to_sym, self.class.permission)
  end
end
