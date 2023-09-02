class Venue < ApplicationRecord
  has_paper_trail # para soporte de versionado
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true
  has_one :location, dependent: :destroy
  accepts_nested_attributes_for :location # con esto se puede crear una ubicacion al crear un lugar
  has_one :image, as: :imageable, dependent: :destroy
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :description, :location, presence: true
  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def address
    location_info = location.attributes.slice('zip_code', 'street', 'department', 'locality',
                                              'latitude', 'longitude', 'number', 'country', 'province')
    "#{location_info['street']} #{location_info['number']}, #{location_info['locality']}, #{location_info['province']}, #{location_info['country']}"
  end
  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
