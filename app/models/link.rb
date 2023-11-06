class Link < ApplicationRecord
  include Versionable
  has_paper_trail versions: { class_name: 'Version' }, ignore: %i[linkeable_id linkeable_type id created_at updated_at]
  belongs_to :linkeable, polymorphic: true
end
