class Admin::PenaltyThresholdsController < ApplicationController
  before_action :validate_user_is_admin

  def index
    penalty_thresholds = PenaltyThreshold.all

    render json: { data: penalty_thresholds.as_json(methods: :permanent_block) }
  end

  def create
    penalty_threshold = PenaltyThreshold.new(penalty_threshold_params)

    if penalty_threshold.save
      render json: penalty_threshold.as_json(methods: :permanent_block), status: :ok
    else
      render json: { errors: penalty_threshold.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    penalty_threshold = PenaltyThreshold.find(params[:id])

    if penalty_threshold.update(penalty_threshold_params)
      render json: penalty_threshold.as_json(methods: :permanent_block), status: :ok
    else
      render json: { errors: penalty_threshold.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    penalty_threshold = PenaltyThreshold.find(params[:id])

    if penalty_threshold.destroy
      head :no_content, status: :ok
    else
      render json: { errors: penalty_threshold.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def penalty_threshold_params
    attrs = params.require(:penalty_threshold).permit(:penalty_score, :days_blocked, :permanent_block).to_h
    attrs[:days_blocked] = PenaltyThreshold.permanent_block_days if attrs.delete(:permanent_block)
    attrs
  end
end
