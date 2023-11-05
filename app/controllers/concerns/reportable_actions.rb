module ReportableActions
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: %i[report]
  end

  def report
    reportable = search_model_scope.find(params[:id])
    report = reportable.reports.new(report_params)
    report.reporter = current_user

    if report.save
      render json: { data: report.as_json }
    else
      render json: { errors: report.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(:category, :user_comment, :original_reportable_id)
  end

  def search_model_scope
    controller_path.classify.constantize
  end
end
