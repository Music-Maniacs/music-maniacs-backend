class Venue < ApplicationRecord
  include Reviewable
  include Followable
  include ProfileCommonMethods
  include Reportable
  include Versionable

  has_paper_trail versions: { class_name: 'Version' }, ignore: %i[id created_at updated_at deleted_at]
  acts_as_paranoid

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable, autosave: true
  accepts_nested_attributes_for :links, allow_destroy: true

  has_one :location
  accepts_nested_attributes_for :location, update_only: true # con esto se puede crear una ubicacion al crear un lugar

  has_one :image, as: :imageable

  has_many :events
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :location, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def address
    "#{location.street} #{location.number}, #{location.city}, #{location.province}, #{location.country}"
  end

  def short_address
    "#{location.province}, #{location.country}"
  end

  def author_id
    author_id_by_versions
  end

  def location_versions
    Version.where(item_type: 'Location')
           .joins(:version_associations)
           .where(version_associations: { foreign_key_name: 'venue_id', foreign_key_id: id })
  end

  def links_versions
    Version.where(item_type: 'Link')
           .joins(:version_associations)
           .where(version_associations: { foreign_key_name: 'linkeable_id', foreign_key_id: id })
  end

  def history
    location_versions_ids = location_versions.pluck(:id)
    links_versions_ids = links_versions.pluck(:id)
    version_ids = versions.pluck(:id)
    Version.where(id: version_ids + location_versions_ids + links_versions_ids).order(created_at: :desc)
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[location]
  end
end
