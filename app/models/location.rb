class Location < ApplicationRecord
  include Versionable
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :venue
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :latitude, :longitude, presence: true

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[zip_code street city latitude longitude number country province]
  end
end
