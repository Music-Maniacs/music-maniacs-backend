class Artist < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :genreable_associations, as: :genreable
  has_many :genres, through: :genreable_associations

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
