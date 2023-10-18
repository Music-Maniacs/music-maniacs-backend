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
    users_type_info = Hash.new(0) # Hash para contar las users_type
    roles.map do |role_id, role_name|
      count = User.active.where(role_id: role_id).count
      users_type_info[role_name] = count
    end
    users_type_info
  end

  def visits(start_date, end_date)
    users = User.active
    visit_info = Hash.new(0) # Hash para contar las visitas por fecha

    users.each do |user|
      user_stat = user.user_stat
      visited_dates = Set.new # Conjunto para almacenar las fechas de visitas únicas por usuario

      versions = user_stat.versions.where('created_at >= ? AND created_at <= ?', start_date, end_date)

      versions.each do |version|
        created_at_date = version.created_at.to_date
        # Verifica si ya se contó una visita para este usuario en esta fecha
        unless visited_dates.include?(created_at_date)
          visited_dates.add(created_at_date) # Agrega la fecha al conjunto
          visit_info[created_at_date.strftime('%Y-%m-%d')] += 1
        end
      end
    end
    visit_info
  end

  def show_metrics(klass_name, start_date, end_date)
    klass = klass_name.classify.constantize
    klass.where('created_at >= ? AND created_at <= ?', start_date, end_date)
         .group('DATE(created_at)')
         .order('DATE(created_at)')
         .count
  end

  ########## Metodos apartado metricas
  def count_by_date(entity, days_ago)
    entity.where('created_at >= ?', Time.zone.now - days_ago.days).count
  end

  def count_today(entity)
    start_of_day = Time.zone.now.beginning_of_day
    end_of_day = Time.zone.now.end_of_day
    entity.where('created_at >= ? AND created_at <= ?', start_of_day, end_of_day).count
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
