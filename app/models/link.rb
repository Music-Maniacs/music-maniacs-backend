class Link < ApplicationRecord
  include Versionable
  belongs_to :linkeable, polymorphic: true
end
