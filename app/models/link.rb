class Link < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :linkeable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :url, :title, presence: true

  # Scope que valida la unicidad de la URL por linkeable_id
  validates_uniqueness_of :url, scope: [:linkeable_id]
end
