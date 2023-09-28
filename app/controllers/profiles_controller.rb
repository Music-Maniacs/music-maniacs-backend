class ProfilesController < ApplicationController
  before_action :authenticate_user!
  def info
    render json: current_user.as_json(include: :role), status: :ok
  end
end
