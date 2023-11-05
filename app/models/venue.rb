class Venue < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable, autosave: true
  accepts_nested_attributes_for :links, allow_destroy: true

  has_one :location, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :location # con esto se puede crear una ubicacion al crear un lugar

  has_one :image, as: :imageable, dependent: :destroy

  has_many :events, dependent: :restrict_with_error

  has_paper_trail ignore: %i[id created_at updated_at deleted_at] # para soporte de versionado
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :location, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def address
    "#{location.street} #{location.number}, #{location.city}, #{location.province}, #{location.country}"
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
