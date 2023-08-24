class Admin::PenaltyThresholdsController < ApplicationController
  def index
    penalty_hresholds = PenaltyThreshold.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: penalty_hresholds, pagination: pagination_info(penalty_hresholds) }
  end

  def create
    penalty_threshold = PenaltyThreshold.new(penalty_threshold_params)

    if penalty_threshold.save
      render json: penalty_threshold, status: :ok
    else
      render json: { errors: penalty_threshold.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    penalty_threshold = PenaltyThreshold.find(params[:id])
    render json: penalty_threshold.as_json
  end

  def update
    penalty_threshold = PenaltyThreshold.find(params[:id])

    if penalty_threshold.update(penalty_threshold_params)
      render json: penalty_threshold, status: :ok
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
    byebug
    attrs
  end
end
