class Link < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  include Versionable
  has_paper_trail versions: { class_name: 'Version' }, ignore: %i[linkeable_id linkeable_type id created_at updated_at]
  belongs_to :linkeable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :url, :title, presence: true

  # Scope que valida la unicidad de la URL por linkeable_id
  validates_uniqueness_of :url, scope: [:linkeable_id]
end
