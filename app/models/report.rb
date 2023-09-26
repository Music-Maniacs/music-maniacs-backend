class Report < ApplicationRecord
  enum status: { pending: 0, resolved: 1, ignored: 2 }
  enum category: { inappropriate_content: 0, spam: 1, other: 2 }

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :reporter, class_name: 'User'
  belongs_to :resolver, class_name: 'User', optional: true
  belongs_to :reportable, -> { with_deleted }, polymorphic: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  before_create :set_default_status

  def set_default_status
    self.status ||= :pending
  end

  def resolve(action:, resolver:, penalization_score: nil, moderator_comment: nil)
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
        resolve_comment_report(category)
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

  def resolve_comment_report(category)
    # no importa la categoría hay que destruirlo
    reportable.destroy!
  end
end
