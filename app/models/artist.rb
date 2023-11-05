class Artist < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  has_paper_trail ignore: %i[id created_at updated_at deleted_at]

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :genreable_associations, as: :genreable
  has_many :genres, through: :genreable_associations,autosave: true

  has_one :image, as: :imageable, dependent: :destroy

  has_many :links, as: :linkeable, autosave: true
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :events, dependent: :restrict_with_error
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, uniqueness: true
  validates :name, :nationality, presence: true

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
