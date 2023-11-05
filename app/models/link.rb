class Link < ApplicationRecord
  has_paper_trail
  belongs_to :linkeable, polymorphic: true
end
