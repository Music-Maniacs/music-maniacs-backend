class Producer < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  include Reportable

  def self.ignored_version_attrs
    %i[id created_at updated_at deleted_at]
  end

  include Versionable
  acts_as_paranoid

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :genreable_associations, as: :genreable
  has_many :genres, through: :genreable_associations,autosave: true

  has_one :image, as: :imageable

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :events
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, uniqueness: true
  validates :name, :nationality, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def author_id
    author_id_by_versions
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
