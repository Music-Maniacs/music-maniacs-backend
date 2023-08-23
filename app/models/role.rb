class Role < ApplicationRecord
  self.ignored_columns = %w[order]
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_and_belongs_to_many :permissions

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
end
