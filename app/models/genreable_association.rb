class GenreableAssociation < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :genre
  belongs_to :genreable, polymorphic: true
end
