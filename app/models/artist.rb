class Artist < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  include Reportable
  include Versionable
  acts_as_paranoid

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :genreable_associations, as: :genreable
  has_many :genres, through: :genreable_associations

  has_one :image, as: :imageable, dependent: :destroy

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :events, dependent: :restrict_with_error
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, uniqueness: true
  validates :name, :nationality, :description, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def author_id
    author_by_versions
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
