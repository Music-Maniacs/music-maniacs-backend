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
    # u
  end

  def show_new_users
    # u
  end

  def show_new_events
    # u
  end

  def show_visits
    # u
  end

  def show_comments
    # u
  end

  def show_reviews
    # u
  end

  def show_reports
    # u
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

  def count_users
    # u
  end
end
