class Event < ApplicationRecord
  has_paper_trail
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_one :image, as: :imageable, dependent: :destroy

  belongs_to :artist
  belongs_to :producer
  belongs_to :venue

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, :datetime, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name datetime artist_id venue_id producer_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
