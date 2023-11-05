class Genre < ApplicationRecord
  include Versionable
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
