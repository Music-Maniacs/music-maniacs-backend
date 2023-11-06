class Genre < ApplicationRecord
  include Versionable
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :genreable_associations, dependent: :restrict_with_error

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
