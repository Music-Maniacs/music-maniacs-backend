class MetricsController < ApplicationController
  def index
    start_date = params[:startDate]
    end_date = params[:endDate]
    metrics = {
      metricas: generate_metrics(Video, Like, Event),
      users_type: type_users,
      visits: visits(start_date, end_date),
      # reports: show_metrics('Report', start_date, end_date),
      reviews: show_metrics('Review', start_date, end_date),
      comments: show_metrics('Comment', start_date, end_date),
      users: show_metrics('User', start_date, end_date),
      events: show_metrics('Event', start_date, end_date)
    }
    render json: metrics, status: :ok
  end

  private

  def type_users
    roles = Role.pluck(:id, :name)
    roles.map do |role_id, role_name|
      count = User.active.where(role_id: role_id).count
      { role_name: role_name, count: count }
    end
  end

  def visits(start_date, end_date)
    User.active
        .joins(:user_stat)
        .where(created_at: start_date..end_date)
        .sum('days_visited')
  end

  def show_metrics(klass_name, start_date, end_date)
    klass = klass_name.classify.constantize
    results = klass.where(created_at: start_date..end_date)
                   .group('DATE(created_at)')
                   .order('DATE(created_at)')
                   .count
    results
  end

  ##########
  def count_by_date(entity, days_ago)
    entity.where('created_at >= ?', Time.zone.now - days_ago.days).count
  end

  def count_today(entity)
    count_by_date(entity, 0)
  end

  def count_7days(entity)
    count_by_date(entity, 7)
  end

  def count_30days(entity)
    count_by_date(entity, 30)
  end

  def generate_metrics(*models)
    metrics = {}

    models.each do |model|
      model_name = model.name.underscore.pluralize.to_sym
      metrics[model_name] = {
        today: count_today(model),
        days7: count_7days(model),
        days30: count_30days(model)
      }
    end
    metrics
  end
end
