class Location < ApplicationRecord
  include Versionable
  has_paper_trail versions: { class_name: 'Version' }, ignore: %i[id created_at updated_at deleted_at]
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :venue
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :latitude, :longitude, presence: true
  validates :number, numericality: { greater_than: 0, allow_blank: true }

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[zip_code street city latitude longitude number country province]
  end
end
