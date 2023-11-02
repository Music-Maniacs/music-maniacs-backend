class ReportsController < ApplicationController
  before_action :authenticate_user!, only: %i[resolve]

  REPORTS_TO_JSON = { include: { reporter: { only: %i[id full_name] },
                                 resolver: { only: %i[id full_name] } } }.freeze

  REPORTS_TO_JSON_SHOW = { include: { reporter: { only: %i[id full_name] },
                                      resolver: { only: %i[id full_name] } } }.freeze

  ARTIST_TO_JSON = { only: %i[id name created_at], include: { image: { methods: %i[full_url] } } }.freeze
  VENUE_TO_JSON = { only: %i[id name created_at], include: { image: { methods: %i[full_url] } } }.freeze
  PRODUCER_TO_JSON = { only: %i[id name created_at], include: { image: { methods: %i[full_url] } } }.freeze
  EVENT_TO_JSON = { only: %i[id name created_at], include: { image: { methods: %i[full_url] },
                                                             artist: { only: %i[id name] },
                                                             producer: { only: %i[id name] },
                                                             venue: { only: %i[id name] } } }.freeze

  COMMENT_TO_JSON = { only: %i[id body created_at],
                      include: { user: { only: %i[id full_name], methods: :profile_image_full_url } },
                      methods: %i[anonymous] }.freeze

  VIDEO_TO_JSON = { only: %i[id name created_at recorded_at], methods: %i[full_url] }.freeze
  REVIEW_TO_JSON = Review::TO_JSON

  VERSION_TO_JSON = { except: :object_changes,
                      methods: %i[anonymous named_object_changes],
                      include: { user: { only: %i[id full_name] } } }.freeze

  AUTHOR_TO_JSON = { only: %i[id email username full_name] }.freeze

  def index
    reports = Report.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
    render json: { data: reports.as_json(REPORTS_TO_JSON), pagination: pagination_info(reports) }
  end

  def show
    report = Report.find(params[:id])
    result = report.as_json(REPORTS_TO_JSON_SHOW.deep_merge({ include: { reportable: reportable_serializer(report.reportable_type) } }))
    result.merge!(author: report.author.as_json(AUTHOR_TO_JSON))
    render json: result
  end

  def reportable_serializer(reportable_type)
    self.class.const_get("#{reportable_type.upcase}_TO_JSON")
  end

  def resolve
    report = Report.find(params[:id])
    report.resolver = current_user

    render json: { error: :already_resolved }, status: :unprocessable_entity and return if report.resolved?

    if report.resolve(action: params[:report_action], resolver: current_user,
                      penalization_score: params[:penalization_score], moderator_comment: params[:moderator_comment])
      render json: report.as_json(REPORTS_TO_JSON_SHOW)
    else
      render json: { errors: report.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def resolve_report_params
    params.require(:report).permit(:moderator_comment, :penalization_score)
  end
end
