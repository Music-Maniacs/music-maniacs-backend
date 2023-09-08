class Location < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :venue

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[zip_code street department locality latitude longitude number country province]
  end
end
