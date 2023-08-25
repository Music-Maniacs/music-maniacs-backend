class Venue < ApplicationRecord
      
  
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true
  has_one :location, inverse_of: :venue
  accepts_nested_attributes_for :location #con esto se puede crear una ubicacion al crear un lugar
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :venue_name, presence: true

end
