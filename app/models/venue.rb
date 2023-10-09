class Venue < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  include Reportable
  has_paper_trail # para soporte de versionado
  acts_as_paranoid

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_one :location, dependent: :destroy
  accepts_nested_attributes_for :location # con esto se puede crear una ubicacion al crear un lugar

  has_one :image, as: :imageable, dependent: :destroy

  has_many :events, dependent: :restrict_with_error
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :description, :location, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def address
    "#{location.street} #{location.number}, #{location.locality}, #{location.province}, #{location.country}"
  end

  def short_address
    "#{location.province}, #{location.country}"
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
