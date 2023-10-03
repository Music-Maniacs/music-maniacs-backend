class TrustLevel < Role
  self.ignored_columns = %w[]
  REQUIREMENTS = %i[days_visited viewed_events likes_received likes_given comments_count].freeze
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :days_visited, :viewed_events, :likes_received, :likes_given, :comments_count,
            presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :order, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def requirements_met_by_user?(user)
    user_stat = user.user_stat
    return false if REQUIREMENTS.any? { |requirement| user_stat.send(requirement) < send(requirement) }

    true
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.default_trust_level
    find_by(order: 1)
  end
end
