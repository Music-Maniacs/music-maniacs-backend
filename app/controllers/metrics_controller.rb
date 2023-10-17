class MetricsController < ApplicationController
  def show_metrics
    metrics = {
      videos: {
        today: count_today(Video),
        days7: count_7days(Video),
        days30: count_30days(Video)
      },
      likes: {
        today: count_today(Like),
        days7: count_7days(Like),
        days30: count_30days(Like)
      },
      events: {
        today: count_today(Event),
        days7: count_7days(Event),
        days30: count_30days(Event)
      }
    }
    render json: metrics, status: :ok
  end

  def show_type_users
    roles = Role.pluck(:id, :name)

    role_counts = roles.map do |role_id, role_name|
      count = User.active.where(role_id: role_id).count
      { role_name: role_name, count: count }
    end

    render json: role_counts, status: :ok
  end

  def show_visits
    # u
  end

  %w[reports reviews comments users events].each do |klass_name|
    define_method "show_#{klass_name}" do
      start_date = params[:startDate]
      end_date = params[:endDate]
      klass = klass_name.classify.constantize
      results = klass.where(created_at: start_date..end_date)
                     .group('DATE(created_at)')
                     .order('DATE(created_at)')
                     .count
      render json: results
    end
  end

  private

  def count_today(entity)
    entity.where('DATE(created_at) = ?', Time.zone.now.to_date).count
  end

  def count_7days(entity)
    entity.where('created_at >= ?', Time.zone.now - 7.days).count
  end

  def count_30days(entity)
    entity.where('created_at >= ?', Time.zone.now - 30.days).count
  end
end
