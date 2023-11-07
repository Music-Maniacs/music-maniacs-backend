class TrustLevel < Role
  self.ignored_columns = %w[]
  REQUIREMENTS = %i[days_visited viewed_events likes_received likes_given comments_count].freeze
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :days_visited, :viewed_events, :likes_received, :likes_given, :comments_count,
            presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :order, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }, presence: true

  validate :permissions_are_valid

  def permissions_are_valid
    lower_levels = TrustLevel.where("roles.order < ?", order)
    lower_permissions = lower_levels.map { |level| level.permissions.map { |permission| "#{permission.subject_class}_#{I18n.t(permission.action, scope: [:activerecord, :attributes, :permissions, :actions])}" } }.uniq.flatten
    actual_permissions = permissions.map { |permission| "#{permission.subject_class}_#{I18n.t(permission.action, scope: [:activerecord, :attributes, :permissions, :actions])}" }.flatten
    missing_permissions = lower_permissions - actual_permissions

    actual_permissions.select { |permission| permission.to_s.match?(/Todas las operaciones/) }.each do |manage_permission|
      missing_permissions.delete_if { |permission| permission.to_s.match?(/#{manage_permission.split('_').first}/) }
    end

    unless missing_permissions.empty?
      errors.add(:base, :missing_permission_from_lower_trust_level, permissions: missing_permissions.map)
    end
  end

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
