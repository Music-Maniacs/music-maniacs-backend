class TrustLevel < Role
  self.ignored_columns = %w[]
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :days_visited, :viewed_events, :likes_received, :likes_given, :comments_count,
            presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :order, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }, presence: true

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.default_trust_level
    find_by(order: 1)
  end
end
