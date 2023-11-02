class Report < ApplicationRecord
  enum status: { pending: 0, resolved: 1, ignored: 2 }
  enum category: { inappropriate_content: 0, spam: 1, other: 2, fake: 3, duplicated: 4, incorrect_artist: 5, incorrect_venue: 6, incorrect_producer: 7, does_not_belong_to_event: 8 }

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :reporter, class_name: 'User'
  belongs_to :resolver, class_name: 'User', optional: true
  belongs_to :reportable, -> { with_deleted }, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  # que el original_reportable_id sea distinto que el reportable_id
  # que la categoría sea valida para el reportable
  # que el reportador no pueda resolver su propio reporte

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  before_create :set_default_status

  def set_default_status
    self.status ||= :pending
  end

  def resolve(action:, resolver:, penalization_score: nil, moderator_comment: nil)
    raise 'already resolved' if resolved? || ignored?

    case action
    when 'accept'
      accept(resolver, penalization_score, moderator_comment)
    when 'reject'
      reject(resolver, moderator_comment)
    else
      raise 'Invalid action'
    end
  end

  def accept(resolver, penalization_score, moderator_comment)
    ActiveRecord::Base.transaction do
      update!(status: :resolved, resolver:, penalization_score:, moderator_comment:)

      # cuando la categoría es incorrect_profile, siempre se va a penalizar al autor (creador) y quizá otro usuario fue el que hizo el cambio de perfil
      penalize_author if penalization_score.present?

      send("resolve_#{reportable.class.to_s.downcase}_report")
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  def penalize_author
    # si el reportable se crea por consola no va a tener whodunnit y por ende tampoco autor a penalizar
    author&.increment_penalization_score!(penalization_score)
  end

  def author
    User.with_deleted.find_by(id: reportable.author_id)
  end

  def reject(resolver, moderator_comment)
    update!(status: :ignored, resolver:, moderator_comment:)
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  def resolve_comment_report
    # no importa la categoría hay que eliminarlo
    reportable.reports.pending.update_all(status: :resolved, resolver_id: resolver.id)
    reportable.destroy!
  end

  def resolve_event_profile_report
    case category
    when 'fake', 'spam', 'other'
      reportable.events.destroy_all
      reportable.destroy!
      reportable.reports.where(category:).update_all(status: :resolved, resolver_id: resolver.id)
    when 'duplicated'
      # TODO: ver que hacer cuando no existe mas el sugerido como duplicado
      reportable.reports.where(category:, original_reportable_id:).update_all(status: :resolved, resolver_id: resolver.id)
      merge_profile(duplicated: reportable, original: reportable.class.find(original_reportable_id).id)
    end
  end

  def resolve_event_report
    case category
    when 'fake', 'spam', 'other'
      reportable.reports.where(category:).update_all(status: :resolved, resolver_id: resolver.id)
      reportable.destroy!
    when 'incorrect_artist', 'incorrect_venue', 'incorrect_producer'
      # TODO: ver que hacer cuando no existe mas el sugerido como duplicado
      reportable.reports.where(category:, original_reportable_id:).update_all(status: :resolved, resolver_id: resolver.id)
      reportable.update!("#{category.split('_').last}_id" => original_reportable_id)
    when 'duplicated'
      # TODO: validar que el evento tenga asociado los mismos perfiles
      merge_events(duplicated: reportable, original: Event.find(original_reportable_id))
      reportable.destroy!
    end
  end

  def resolve_video_report
    # no importa la categoría hay que eliminarlo
    reportable.reports.pending.update_all(status: :resolved, resolver_id: resolver.id)
    reportable.destroy!
  end

  # no se hace nada, solo se penaliza
  def resolve_version_report
    reportable.reports.pending.update_all(status: :resolved, resolver_id: resolver.id)
  end

  def merge_profile(duplicated:, original:)
    profile_type = reportble.class.to_s.downcase # artist, venue, producer
    duplicated.events.update_all("#{profile_type}_id" => original.id)
    duplicated.reviews.update_all(reviewable_id: original.id)
    duplicated.follows.update_all(followable_id: original.id)
    duplicated.destroy!
  end

  def merge_events(duplicated:, original:)
    duplicated.reviews.update_all(reviewable_id: original.id)
    duplicated.follows.update_all(followable_id: original.id)
    duplicated.videos.update_all(event_id: original.id)
    duplicated.destroy!
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[category reportable_type status created_at]
  end
end
