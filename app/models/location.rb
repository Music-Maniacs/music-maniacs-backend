class Location < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :venue , optional: true #para crear el location y pasarlo al venue
end
