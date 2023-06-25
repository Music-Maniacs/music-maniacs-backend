class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {}, status: :ok
    else
      render json: { errors: resource.errors.details }, status: :unprocessable_entity
    end
  end
end
