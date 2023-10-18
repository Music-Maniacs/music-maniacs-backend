class MetricsController < ApplicationController
  def index
    start_date = params[:startDate]
    end_date = params[:endDate]
    metrics = {
      metrics: generate_metrics(Video, Like, Event),
      users_type: users_type,
      visits: visits(start_date, end_date),
      # reports: show_metrics('Report', start_date, end_date),
      reviews: show_metrics('Review', start_date, end_date),
      new_comments: show_metrics('Comment', start_date, end_date),
      new_users: show_metrics('User', start_date, end_date),
      new_events: show_metrics('Event', start_date, end_date)
    }
    render json: metrics, status: :ok
  end

  private

  def users_type
    roles = Role.pluck(:id, :name)
    roles.map do |role_id, role_name|
      count = User.active.where(role_id: role_id).count
      { role_name: role_name, count: count }
    end
  end

  def visits(start_date, end_date)
    User.active
        .joins(:user_stat)
        .where('user_stats.created_at >= ? AND user_stats.created_at <= ?', start_date, end_date)
        .sum('user_stats.days_visited')
  end

  def show_metrics(klass_name, start_date, end_date)
    klass = klass_name.classify.constantize
    klass.where('created_at >= ? AND created_at <= ?', start_date, end_date)
         .group('DATE(created_at)')
         .order('DATE(created_at)')
         .count
  end

  ##########
  def count_by_date(entity, days_ago)
    entity.where('created_at >= ?', Time.zone.now - days_ago.days).count
  end

  def count_today(entity)
    start_of_day = Time.zone.now.beginning_of_day
    end_of_day = Time.zone.now.end_of_day
    entity.where('created_at >= ? AND created_at <= ?', start_of_day, end_of_day).count
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
