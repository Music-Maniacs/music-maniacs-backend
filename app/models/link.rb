class Link < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :linkeable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :url, presence: true, uniqueness: true
  validates :title, presence: true
end
