class Venue < ApplicationRecord
      
  
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :venue_name, presence: true

end
