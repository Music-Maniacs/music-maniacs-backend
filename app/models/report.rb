class Report < ApplicationRecord
  enum status: { pending: 0, resolved: 1, ignored: 2 }
  enum category: { inappropriate_content: 0, spam: 1, other: 2, fake: 3, duplicated: 4 }

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
      self.status = :resolved
      self.resolver = resolver
      self.penalization_score = penalization_score
      self.moderator_comment = moderator_comment
      # TODO: penalizar usuario

      case reportable.class.to_s
      when 'Comment'
        resolve_comment_report
      when 'Artist', 'Venue', 'Producer'
        resolve_event_profile_report
      else
        raise 'Invalid reportable'
      end
      save!
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
  end

  def reject
    self.status = :ignored
    self.resolver = resolver
    self.moderator_comment = moderator_comment
    save!
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
  end

  def resolve_comment_report
    # no importa la categoría hay que eliminarlo
    reportable.destroy!
    reportable.reports.update_all(status: :resolved, resolver_id: resolver.id)
  end

  def resolve_event_profile_report
    case category
    when 'fake' || 'spam' || 'other'
      reportable.destroy!
      reportable.reports.where(category:).update_all(status: :resolved, resolver_id: resolver.id)
    when 'duplicated'
      # TODO: ver que hacer cuando no existe mas el sugerido como duplicado
      merge_profile(duplicated: reportable, original: reportable.class.find(original_reportable_id).id)
      reportable.reports.where(category:, original_reportable_id:).update_all(status: :resolved, resolver_id: resolver.id)
    end
  end

  def resolve_event_report
    case category
    when 'fake' || 'spam' || 'other'
      reportable.destroy!
      reportable.reports.where(category:).update_all(status: :resolved, resolver_id: resolver.id)
    when 'duplicated'
      # TODO: validar que el evento tenga asociado los mismos perfiles
      merge_events(duplicated: reportable, original: Event.find(original_reportable_id))
      reportable.destroy!
    end
  end

  def merge_profile(duplicated:, original:)
    duplicated.events.update_all(artist_id: original)
    duplicated.reviews.update_all(reviewable_id: original)
    duplicated.follows.update_all(followable_id: original)
    duplicated.reports.pending.destroy_all # reportes pendientes asociados al duplicado chau
    duplicated.destroy!
  end

  def merge_events(duplicated:, original:)
    duplicated.reviews.update_all(reviewable_id: original)
    duplicated.follows.update_all(followable_id: original)
    duplicated.videos.update_all(event: original)
    duplicated.reports.pending.destroy_all # reportes pendientes asociados al duplicado chau
    duplicated.destroy!
  end
end
