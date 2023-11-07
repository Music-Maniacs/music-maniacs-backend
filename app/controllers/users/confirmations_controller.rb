class Users::ConfirmationsController < Devise::ConfirmationsController

  protected

  def after_confirmation_path_for(resource_name, resource)
    "#{REACT_HOST}/login"
  end
end
