class Role < ApplicationRecord
  # estas columnas solo se usan en los trust levels
  self.ignored_columns = %w[order days_visited viewed_events likes_received likes_given comments_count]
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_and_belongs_to_many :permissions
  has_many :users, dependent: :restrict_with_error

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
end
