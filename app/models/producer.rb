class Producer < ApplicationRecord
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
  has_many :genreable_associations, as: :genreable
  has_many :genres, through: :genreable_associations,autosave: true

  has_one :image, as: :imageable

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :events
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, uniqueness: true
  validates :name, :nationality, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def author_id
    author_id_by_versions
  end

  def links_versions
    Version.where(item_type: 'Link')
           .joins(:version_associations)
           .where(version_associations: { foreign_key_name: 'linkeable_id', foreign_key_id: id })
  end

  def history
    links_versions_ids = links_versions.pluck(:id)
    version_ids = versions.pluck(:id)
    Version.where(id: version_ids + links_versions_ids).order(created_at: :desc)
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
