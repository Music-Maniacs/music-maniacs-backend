class ReportsController < ApplicationController
  before_action :authenticate_user!, only: %i[resolve]

  def resolve
    report = Report.find(params[:id])
    report.resolver = current_user

    render json: { error: :already_resolved }, status: :unprocessable_entity and return if report.resolved?

    if report.resolve(action: params[:report_action], resolver: current_user,
                      penalization_score: params[:penalization_score], moderator_comment: params[:moderator_comment])
      render json: { data: report.as_json }
    else
      render json: { errors: report.errors.details }, status: :unprocessable_entity
    end
  end

  def resolve_report_params
    params.require(:report).permit(:moderator_comment, :penalization_score)
  end
end
