class Location < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :venue , inverse_of: :location ,optional: true #para crear el location y pasarlo al venue
end
