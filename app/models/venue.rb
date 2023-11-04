class Venue < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  include Reportable
  include Versionable
  acts_as_paranoid

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_one :location
  accepts_nested_attributes_for :location # con esto se puede crear una ubicacion al crear un lugar

  has_one :image, as: :imageable

  has_many :events
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :description, :location, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def address
    "#{location.street} #{location.number}, #{location.city}, #{location.province}, #{location.country}"
  end

  def short_address
    "#{location.province}, #{location.country}"
  end

  def author_id
    author_id_by_versions
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[location]
  end
end
